import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../constants/api_constants.dart';
import '../constants/color_constant.dart';
import '../constants/sizeConstant.dart';
import '../constants/translation_keys.dart';
import '../data/NetworkClient.dart';
import '../model/address_list_model.dart' as address_model;
import '../model/customer_list_model.dart';

class AddCustomerDialog extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialEmail;
  final String initialPhoneCode;
  final String initialZipcode;
  final String initialHouseNumber;
  final String initialAddress;
  final bool isDelivery;
  final List<address_model.AddressItem>? zipcodeList;
  final Function({
    required String name,
    required String phone,
    required String email,
    required String phoneCode,
    String? zipcode,
    String? houseNumber,
    String? address,
    int? customerId,
  })
  onSave;

  final void Function(CustomerListItem customer)? onCustomerSelected;

  const AddCustomerDialog({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.initialEmail,
    required this.initialPhoneCode,
    required this.initialZipcode,
    required this.initialHouseNumber,
    required this.initialAddress,
    required this.isDelivery,
    required this.onSave,
    this.zipcodeList,
    this.onCustomerSelected,
  });

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController zipcodeController;
  late TextEditingController houseNumberController;
  late TextEditingController addressController;
  late String _selectedPhoneCode;
  late String _selectedCountryFlag;

  final List<CustomerListItem> _searchResults = [];
  bool _isSearching = false;
  int _currentPage = 1;
  int? _lastPage;
  final ScrollController _resultsScrollController = ScrollController();
  Timer? _searchDebounce;
  final GlobalKey _nameFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _suppressResults = false;
  int? selectedCustomerId;
  bool _isPrefillingFromSelection = false;

  final GlobalKey _zipcodeFieldKey = GlobalKey();
  OverlayEntry? _zipcodeOverlayEntry;
  final List<address_model.AddressItem> _filteredZipcodes = [];
  final FocusNode _zipcodeFocusNode = FocusNode();
  List<address_model.AddressItem> _zipcodeList = [];

  @override
  void initState() {
    super.initState();
    _zipcodeList = List.from(widget.zipcodeList ?? []);
    if (_zipcodeList.isEmpty && widget.isDelivery) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchZipcodes());
    }
    nameController = TextEditingController(text: widget.initialName);
    phoneController = TextEditingController(text: widget.initialPhone);
    emailController = TextEditingController(text: widget.initialEmail);
    zipcodeController = TextEditingController(text: widget.initialZipcode);
    houseNumberController = TextEditingController(
      text: widget.initialHouseNumber,
    );
    addressController = TextEditingController(text: widget.initialAddress);
    _selectedPhoneCode = widget.initialPhoneCode;
    _selectedCountryFlag = _flagFromPhoneCode(widget.initialPhoneCode);
    nameController.addListener(_onNameChanged);
    _resultsScrollController.addListener(_onResultsScroll);
    zipcodeController.addListener(_onZipcodeChanged);
    _zipcodeFocusNode.addListener(_onZipcodeFocusChanged);
  }

  Future<void> _fetchZipcodes() async {
    if (!mounted || !widget.isDelivery) return;
    try {
      final response = await NetworkClient().get(ArgumentConstant.zipcodesEndpoint);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          final model = address_model.AddressListModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          if (mounted && model.success == true && model.data != null) {
            setState(() {
              _zipcodeList = List.from(model.data!);
            });
            _filterZipcodes(zipcodeController.text);
            if (_zipcodeFocusNode.hasFocus && zipcodeController.text.isNotEmpty) {
              _showZipcodeOverlay();
            }
          }
        }
      }
    } catch (_) {}
  }

  void _onZipcodeFocusChanged() {
    if (_zipcodeFocusNode.hasFocus && _hasZipcodeList) {
      _filterZipcodes(zipcodeController.text);
      _showZipcodeOverlay();
    } else {
      _hideZipcodeOverlay();
    }
  }

  bool get _hasZipcodeList => _zipcodeList.isNotEmpty;

  bool get _isSelectedFromList => selectedCustomerId != null;

  void _onSaveSelectedCustomer() {
    widget.onSave(
      name: nameController.text,
      phone: phoneController.text,
      email: emailController.text,
      phoneCode: _selectedPhoneCode,
      zipcode: zipcodeController.text,
      houseNumber: houseNumberController.text,
      address: addressController.text,
      customerId: selectedCustomerId,
    );
    Get.back();
  }

  Future<void> _onSaveNewCustomer() async {
      if (widget.isDelivery && _hasZipcodeList) {
        final entered = zipcodeController.text.trim();
        final validZipcodes = _zipcodeList
          .map((e) => (e.zipcode ?? '').trim())
          .where((s) => s.isNotEmpty)
          .toSet();
      if (entered.isEmpty || !validZipcodes.contains(entered)) {
        Get.snackbar(
          TranslationKeys.error.tr,
          TranslationKeys.validZipcodeRequired.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }
    final newCustomerId = await _createCustomerViaApi();
    if (newCustomerId == null || !mounted) return;
    widget.onSave(
      name: nameController.text,
      phone: phoneController.text,
      email: emailController.text,
      phoneCode: _selectedPhoneCode,
      zipcode: zipcodeController.text,
      houseNumber: houseNumberController.text,
      address: addressController.text,
      customerId: newCustomerId,
    );
    setState(() => selectedCustomerId = newCustomerId);
  }

  Future<int?> _createCustomerViaApi() async {
    try {
      final body = <String, dynamic>{
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'phone_code': _selectedPhoneCode.trim().isEmpty ? '+31' : _selectedPhoneCode.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'house_number': houseNumberController.text.trim(),
        'zip_code': zipcodeController.text.trim(),
      };
      final response = await NetworkClient().post(
        ArgumentConstant.customersEndpoint,
        data: body,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        Get.snackbar(
          TranslationKeys.error.tr,
          TranslationKeys.failedToSubmitOrder.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
      if (response.data is Map<String, dynamic>) {
        final res = response.data as Map<String, dynamic>;
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          final id = data['id'];
          if (id is int) return id;
          if (id != null) return int.tryParse(id.toString());
        }
      }
    } catch (_) {
      Get.snackbar(
        TranslationKeys.error.tr,
        TranslationKeys.failedToSubmitOrder.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return null;
  }

  void _onZipcodeChanged() {
    if (!_hasZipcodeList) return;
    _filterZipcodes(zipcodeController.text);
    if (_filteredZipcodes.isEmpty) {
      _hideZipcodeOverlay();
    } else if (_zipcodeOverlayEntry != null) {
      _zipcodeOverlayEntry!.markNeedsBuild();
    } else if (_zipcodeFocusNode.hasFocus) {
      _showZipcodeOverlay();
    }
  }

  void _filterZipcodes(String query) {
    _filteredZipcodes.clear();
    final list = _zipcodeList;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredZipcodes.addAll(list);
    } else {
      for (final item in list) {
        final zip = (item.zipcode ?? '').toLowerCase();
        final city = (item.city ?? '').toLowerCase();
        final street = (item.street ?? '').toLowerCase();
        if (zip.contains(q) || city.contains(q) || street.contains(q)) {
          _filteredZipcodes.add(item);
        }
      }
    }
    if (_filteredZipcodes.isEmpty) {
      _hideZipcodeOverlay();
    } else if (_zipcodeOverlayEntry != null) {
      _zipcodeOverlayEntry!.markNeedsBuild();
    }
  }

  void _showZipcodeOverlay() {
    if (!_hasZipcodeList) return;
    _filterZipcodes(zipcodeController.text);
    if (_filteredZipcodes.isEmpty) return;
    _hideZipcodeOverlay();
    final overlay = Overlay.of(context);
    _zipcodeOverlayEntry = OverlayEntry(builder: (context) => _buildZipcodeOverlay());
    overlay.insert(_zipcodeOverlayEntry!);
  }

  void _hideZipcodeOverlay() {
    _zipcodeOverlayEntry?.remove();
    _zipcodeOverlayEntry = null;
  }

  Widget _buildZipcodeOverlay() {
    final box = _zipcodeFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return const SizedBox.shrink();
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    const maxHeight = 220.0;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _hideZipcodeOverlay();
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 6,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxHeight: MySize.getHeight(maxHeight)),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _filteredZipcodes.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(MySize.getHeight(16)),
                      child: Text(
                        TranslationKeys.noOrdersFound.tr,
                        style: TextStyle(
                          fontSize: MySize.getHeight(12),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: MySize.getHeight(6)),
                      itemCount: _filteredZipcodes.length,
                      itemBuilder: (context, index) {
                        final item = _filteredZipcodes[index];
                        final line = item.zipcode ?? '';
                        return InkWell(
                          onTap: () {
                            zipcodeController.text = item.zipcode ?? '';
                            _hideZipcodeOverlay();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(12),
                              vertical: MySize.getHeight(10),
                            ),
                            child: Text(
                              line.trim(),
                              style: TextStyle(
                                fontSize: MySize.getHeight(12),
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _onNameChanged() {
    if (_isPrefillingFromSelection) return;
    _suppressResults = false;
    if (selectedCustomerId != null) {
      setState(() => selectedCustomerId = null);
    }
    final query = nameController.text.trim();
    if (query.length < 2) {
      _searchDebounce?.cancel();
      setState(() {
        _searchResults.clear();
        _currentPage = 1;
        _lastPage = null;
      });
      _hideOverlay();
      return;
    }
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (nameController.text.trim().length >= 2) {
        _fetchCustomers(page: 1, append: false);
      }
    });
  }

  void _showOverlay() {
    if (_suppressResults) return;
    if (_searchResults.isEmpty) {
      _hideOverlay();
      return;
    }
    _hideOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) => _buildOverlayLayer());
    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlayLayer() {
    final box = _nameFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return const SizedBox.shrink();
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    const maxHeight = 220.0;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _hideOverlay,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 6,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MySize.getHeight(maxHeight),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  _isSearching && _searchResults.isEmpty
                      ? Padding(
                        padding: EdgeInsets.all(MySize.getHeight(24)),
                        child: Center(
                          child: SizedBox(
                            width: MySize.getHeight(24),
                            height: MySize.getHeight(24),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      )
                      : ListView.builder(
                        controller: _resultsScrollController,
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(6),
                        ),
                        itemCount:
                            _searchResults.length + (_isSearching ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _searchResults.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: MySize.getHeight(8),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: MySize.getHeight(20),
                                  height: MySize.getHeight(20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final customer = _searchResults[index];
                          return _buildCustomerResultTile(customer);
                        },
                      ),
            ),
          ),
        ),
      ],
    );
  }

  void _onResultsScroll() {
    if (!_resultsScrollController.hasClients || _isSearching) return;
    final meta = _lastPage;
    if (meta == null || _currentPage >= meta) return;
    final pos = _resultsScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 80) {
      _fetchCustomers(page: _currentPage + 1, append: true);
    }
  }

  Future<void> _fetchCustomers({
    required int page,
    required bool append,
  }) async {
    final query = nameController.text.trim();
    if (query.length < 2) return;
    if (!append) {
      setState(() {
        _isSearching = true;
        if (page == 1) _searchResults.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hideOverlay();
      });
    } else {
      setState(() => _isSearching = true);
    }
    try {
      final response = await NetworkClient().get(
        ArgumentConstant.customersEndpoint,
        queryParameters: {'search': query, 'page': page, 'per_page': 20},
      );
      final model = CustomerListModel.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {},
      );
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _currentPage = page;
        _lastPage = model.data?.meta?.lastPage;
        if (model.data?.data != null) {
          if (append) {
            _searchResults.addAll(model.data!.data!);
          } else {
            _searchResults
              ..clear()
              ..addAll(model.data!.data!);
          }
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (_searchResults.isNotEmpty) {
            _showOverlay();
          } else {
            _hideOverlay();
          }
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          if (!append) _searchResults.clear();
        });
        _hideOverlay();
      }
    }
  }

  String _flagFromPhoneCode(String? phoneCode) {
    final code = phoneCode?.replaceFirst(RegExp(r'^\+\s*'), '').trim();
    if (code == null || code.isEmpty) return "🇩🇪";
    final country = CountryParser.tryParsePhoneCode(code);
    return country?.flagEmoji ?? "🇩🇪";
  }

  void _prefillFromCustomer(CustomerListItem customer) {
    _hideOverlay();
    selectedCustomerId = customer.id;
    widget.onCustomerSelected?.call(customer);
    _isPrefillingFromSelection = true;
    nameController.text = customer.name ?? '';
    emailController.text = customer.email ?? '';
    final phoneCode = (customer.phoneCode ?? '').toString().trim();
    if (phoneCode.isNotEmpty && !phoneCode.startsWith('+')) {
      _selectedPhoneCode = '+$phoneCode';
    } else if (phoneCode.isNotEmpty) {
      _selectedPhoneCode = phoneCode;
    } else {
      _selectedPhoneCode =
          widget.initialPhoneCode.isNotEmpty ? widget.initialPhoneCode : "+49";
    }
    _selectedCountryFlag = _flagFromPhoneCode(_selectedPhoneCode);
    phoneController.text = customer.phoneNumber ?? '';
    CustomerAddress? addr;
    if (customer.addresses != null && customer.addresses!.isNotEmpty) {
      addr = customer.addresses!.firstWhere(
        (a) => a.isDefault == true,
        orElse: () => customer.addresses!.first,
      );
    }
    if (addr != null) {
      addressController.text = addr.address ?? '';
      zipcodeController.text = addr.zipCode ?? '';
      houseNumberController.text = addr.houseNumber ?? '';
    }
    setState(() {
      _searchResults.clear();
      _currentPage = 1;
      _lastPage = null;
    });
    _suppressResults = true;
    _isPrefillingFromSelection = false;
  }

  @override
  void dispose() {
    _hideOverlay();
    _hideZipcodeOverlay();
    _searchDebounce?.cancel();
    nameController.removeListener(_onNameChanged);
    zipcodeController.removeListener(_onZipcodeChanged);
    _zipcodeFocusNode.removeListener(_onZipcodeFocusChanged);
    _resultsScrollController.removeListener(_onResultsScroll);
    _resultsScrollController.dispose();
    _zipcodeFocusNode.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    zipcodeController.dispose();
    houseNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _onShowCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedPhoneCode = "+${country.phoneCode}";
          _selectedCountryFlag = country.flagEmoji;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
      ),
      child: SingleChildScrollView(
        child: Container(
          width: MySize.screenWidth * 0.95,
          padding: EdgeInsets.all(MySize.getHeight(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationKeys.addCustomer.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(15),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: MySize.getHeight(4)),
              const Divider(),
              SizedBox(height: MySize.getHeight(12)),

              SizedBox(
                key: _nameFieldKey,
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(TranslationKeys.customerName.tr),
                    SizedBox(height: MySize.getHeight(6)),
                    _buildTextField(
                      controller: nameController,
                      placeholder: TranslationKeys.enterCustomerName.tr,
                      keyboardType: TextInputType.name,
                      readOnly: false,
                    ),
                  ],
                ),
              ),
              SizedBox(height: MySize.getHeight(12)),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _isSelectedFromList ? null : _onShowCountryPicker,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(12),
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountryFlag,
                              style: TextStyle(fontSize: MySize.getHeight(18)),
                            ),
                            SizedBox(width: MySize.getWidth(4)),
                            Text(
                              _selectedPhoneCode,
                              style: TextStyle(
                                fontSize: MySize.getHeight(12),
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        readOnly: _isSelectedFromList,
                        style: TextStyle(
                          fontSize: MySize.getHeight(12),
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: TranslationKeys.enterCustomerPhone.tr,
                          hintStyle: TextStyle(
                            color: ColorConstants.grey600,
                            fontSize: MySize.getHeight(12),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: MySize.getWidth(12),
                            vertical: MySize.getHeight(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MySize.getHeight(12)),

              _buildTextField(
                controller: emailController,
                placeholder: TranslationKeys.enterCustomerEmail.tr,
                keyboardType: TextInputType.emailAddress,
                readOnly: _isSelectedFromList,
              ),

              if (widget.isDelivery) ...[
                SizedBox(height: MySize.getHeight(12)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        key: _zipcodeFieldKey,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                        ),
                        child: TextField(
                          controller: zipcodeController,
                          focusNode: _zipcodeFocusNode,
                          readOnly: _isSelectedFromList,
                          onTap: () {
                            if (!_isSelectedFromList && _hasZipcodeList) {
                              _filterZipcodes(zipcodeController.text);
                              _showZipcodeOverlay();
                            }
                          },
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                            fontSize: MySize.getHeight(12),
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: TranslationKeys.zipcode.tr,
                            hintStyle: TextStyle(
                              color: ColorConstants.grey600,
                              fontSize: MySize.getHeight(12),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(12),
                              vertical: MySize.getHeight(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MySize.getWidth(12)),
                    Expanded(
                      child: _buildTextField(
                        controller: houseNumberController,
                        placeholder: TranslationKeys.houseNumber.tr,
                        keyboardType: TextInputType.text,
                        readOnly: _isSelectedFromList,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MySize.getHeight(8)),
                Text(
                  TranslationKeys.deliveryDisclaimer.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(11),
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: MySize.getHeight(12)),
                _buildTextField(
                  controller: addressController,
                  placeholder: TranslationKeys.enterCustomerAddress.tr,
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  readOnly: _isSelectedFromList,
                ),
              ],

              SizedBox(height: MySize.getHeight(20)),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(8),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.getWidth(20),
                        vertical: MySize.getHeight(12),
                      ),
                    ),
                    child: Text(
                      TranslationKeys.cancel.tr,
                      style: TextStyle(fontSize: MySize.getHeight(12)),
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(12)),
                  ElevatedButton(
                    onPressed: _isSelectedFromList ? _onSaveSelectedCustomer : _onSaveNewCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(8),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.getWidth(24),
                        vertical: MySize.getHeight(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      TranslationKeys.save.tr,
                      style: TextStyle(fontSize: MySize.getHeight(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerResultTile(CustomerListItem customer) {
    final initial =
        (customer.name?.isNotEmpty == true)
            ? (customer.name!.substring(0, 1).toUpperCase())
            : '?';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _prefillFromCustomer(customer),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(8),
            vertical: MySize.getHeight(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: MySize.getHeight(14),
                backgroundColor: ColorConstants.primaryColor.withValues(
                  alpha: 0.85,
                ),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MySize.getHeight(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: MySize.getWidth(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      customer.name ?? '',
                      style: TextStyle(
                        fontSize: MySize.getHeight(13),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(2)),
                    Row(
                      children: [
                        if (customer.email != null &&
                            customer.email!.isNotEmpty) ...[
                          Icon(
                            Icons.mail_outline,
                            size: MySize.getHeight(12),
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: MySize.getWidth(4)),
                          Expanded(
                            child: Text(
                              customer.email!,
                              style: TextStyle(
                                fontSize: MySize.getHeight(11),
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (customer.phoneNumber != null &&
                              customer.phoneNumber!.isNotEmpty)
                            SizedBox(width: MySize.getWidth(8)),
                        ],
                        if (customer.phoneNumber != null &&
                            customer.phoneNumber!.isNotEmpty) ...[
                          Icon(
                            Icons.phone_outlined,
                            size: MySize.getHeight(12),
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: MySize.getWidth(4)),
                          Expanded(
                            child: Text(
                              customer.phoneNumber!,
                              style: TextStyle(
                                fontSize: MySize.getHeight(11),
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: MySize.getHeight(13),
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required TextInputType keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade100 : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        style: TextStyle(
          fontSize: MySize.getHeight(12),
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: ColorConstants.grey600,
            fontSize: MySize.getHeight(12),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(12),
            vertical: MySize.getHeight(10),
          ),
        ),
      ),
    );
  }
}
