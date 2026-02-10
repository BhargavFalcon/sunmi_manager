import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../constants/api_constants.dart';
import '../constants/color_constant.dart';
import '../constants/sizeConstant.dart';
import '../constants/translation_keys.dart';
import '../data/NetworkClient.dart';
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
  final Function({
    required String name,
    required String phone,
    required String email,
    required String phoneCode,
    String? zipcode,
    String? houseNumber,
    String? address,
  })
  onSave;

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
  /// After selecting a customer, don't show list again until user changes the name.
  bool _suppressResults = false;

  @override
  void initState() {
    super.initState();
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
  }

  void _onNameChanged() {
    _suppressResults = false; // User is typing → allow list to show on next search
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
    _hideOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlayLayer(),
    );
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
          child: _isSearching && _searchResults.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(MySize.getHeight(24)),
                  child: Center(
                    child: SizedBox(
                      width: MySize.getHeight(24),
                      height: MySize.getHeight(24),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _resultsScrollController,
                  padding: EdgeInsets.symmetric(vertical: MySize.getHeight(6)),
                  itemCount: _searchResults.length + (_isSearching ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _searchResults.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MySize.getHeight(8)),
                        child: Center(
                          child: SizedBox(
                            width: MySize.getHeight(20),
                            height: MySize.getHeight(20),
                            child: const CircularProgressIndicator(
                                strokeWidth: 2),
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

  Future<void> _fetchCustomers({required int page, required bool append}) async {
    final query = nameController.text.trim();
    if (query.length < 2) return;
    if (!append) {
      setState(() {
        _isSearching = true;
        if (page == 1) _searchResults.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showOverlay();
      });
    } else {
      setState(() => _isSearching = true);
    }
    try {
      final response = await NetworkClient().get(
        ArgumentConstant.customersEndpoint,
        queryParameters: {
          'search': query,
          'page': page,
          'per_page': 20,
        },
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
        if (mounted) _showOverlay();
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          if (!append) _searchResults.clear();
        });
      }
    }
  }

  /// Get flag emoji from phone code (e.g. "+49" or "49" → 🇩🇪). Empty/null → default DE.
  String _flagFromPhoneCode(String? phoneCode) {
    final code = phoneCode?.replaceFirst(RegExp(r'^\+\s*'), '').trim();
    if (code == null || code.isEmpty) return "🇩🇪";
    final country = CountryParser.tryParsePhoneCode(code);
    return country?.flagEmoji ?? "🇩🇪";
  }

  void _prefillFromCustomer(CustomerListItem customer) {
    _hideOverlay();
    nameController.text = customer.name ?? '';
    emailController.text = customer.email ?? '';
    final phoneCode = (customer.phoneCode ?? '').toString().trim();
    if (phoneCode.isNotEmpty && !phoneCode.startsWith('+')) {
      _selectedPhoneCode = '+$phoneCode';
    } else if (phoneCode.isNotEmpty) {
      _selectedPhoneCode = phoneCode;
    } else {
      _selectedPhoneCode = widget.initialPhoneCode.isNotEmpty
          ? widget.initialPhoneCode
          : "+49";
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
    }
    setState(() {
      _searchResults.clear();
      _currentPage = 1;
      _lastPage = null;
    });
    _suppressResults = true; // Don't show list again until user changes the name
  }

  @override
  void dispose() {
    _hideOverlay();
    _searchDebounce?.cancel();
    nameController.removeListener(_onNameChanged);
    _resultsScrollController.removeListener(_onResultsScroll);
    _resultsScrollController.dispose();
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

              // Customer Name label + search field (key for overlay positioning)
              SizedBox(
                key: _nameFieldKey,
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.customerName.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(13),
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(6)),
                    _buildTextField(
                      controller: nameController,
                      placeholder: TranslationKeys.enterCustomerName.tr,
                      keyboardType: TextInputType.name,
                    ),
                  ],
                ),
              ),
              SizedBox(height: MySize.getHeight(12)),

              // Phone Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _onShowCountryPicker,
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

              // Email Field
              _buildTextField(
                controller: emailController,
                placeholder: TranslationKeys.enterCustomerEmail.tr,
                keyboardType: TextInputType.emailAddress,
              ),

              if (widget.isDelivery) ...[
                SizedBox(height: MySize.getHeight(12)),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: zipcodeController,
                        placeholder: TranslationKeys.zipcode.tr,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    SizedBox(width: MySize.getWidth(12)),
                    Expanded(
                      child: _buildTextField(
                        controller: houseNumberController,
                        placeholder: TranslationKeys.houseNumber.tr,
                        keyboardType: TextInputType.text,
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
                ),
              ],

              SizedBox(height: MySize.getHeight(20)),

              // Buttons
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
                    onPressed: () {
                      widget.onSave(
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                        phoneCode: _selectedPhoneCode,
                        zipcode: zipcodeController.text,
                        houseNumber: houseNumberController.text,
                        address: addressController.text,
                      );
                      Get.back();
                    },
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
    final initial = (customer.name?.isNotEmpty == true)
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
                backgroundColor: ColorConstants.primaryColor.withValues(alpha: 0.85),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required TextInputType keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: MySize.getHeight(12), color: Colors.black87),
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
