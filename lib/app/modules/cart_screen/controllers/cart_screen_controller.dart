import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/LoginModels.dart';
import '../../../model/menuItemsModel.dart';
import '../../../model/RestaurantDetailsModel.dart';
import '../../../model/tableModel.dart' as table_model;
import '../../../model/getorderModel.dart' as order_model;
import '../../../modules/mainHome_screen/controllers/main_home_screen_controller.dart';
import '../../../modules/order_screen/controllers/order_screen_controller.dart';
import '../../../modules/take_order_screen/controllers/take_order_controller.dart';
import '../../../routes/app_pages.dart';

class CartScreenController extends GetxController {
  final networkClient = NetworkClient();
  final AudioPlayer _audioPlayer = AudioPlayer();

  RxList<Items> cartItems = <Items>[].obs;
  RxDouble discountValue = 0.0.obs;
  RxString discountType = 'Fixed'.obs;
  RxBool isTaxIncluded = false.obs;
  final Rx<table_model.Tables?> selectedTable = Rx<table_model.Tables?>(null);
  String? existingOrderId;
  order_model.GetOrderModel? existingOrder;
  String? sourceScreen;
  final RxInt pax = 1.obs;
  final TextEditingController paxController = TextEditingController();
  final RxList<table_model.Data> tableAreasList = <table_model.Data>[].obs;
  final RxBool isSubmittingOrder = false.obs;
  RxString currentOrderType = 'Pickup'.obs;
  bool hideTableSection = false;
  int? deliveryCustomerId;
  String? deliveryPreOrderDateTime;
  double deliveryTipAmount = 0.0;
  String? deliveryAddress;

  bool get hasTable => selectedTable.value != null;

  bool get isDeliveryOrder =>
      currentOrderType.value.toLowerCase() == 'delivery';

  bool get isPickupOrder => currentOrderType.value.toLowerCase() == 'pickup';

  bool get showTableSection => hasTable && !hideTableSection;

  @override
  void onInit() {
    super.onInit();
    fetchTableFromArguments();
    fetchTablesAreas();
    _checkTaxIncluded();
    syncOrderTypeFromCartItems();
  }

  void fetchTableFromArguments() {
    final arguments = Get.arguments;
    if (arguments == null || arguments is! Map) {
      _resetTableData();
      return;
    }

    final sourceScreenValue = arguments[ArgumentConstant.sourceScreenKey];
    sourceScreen = sourceScreenValue is String ? sourceScreenValue : null;

    final hideTableSectionValue =
        arguments[ArgumentConstant.hideTableSectionKey];
    hideTableSection = hideTableSectionValue == true;

    final table = arguments[ArgumentConstant.tableKey];
    final order = arguments[ArgumentConstant.orderKey];
    existingOrderId = null;
    existingOrder = null;

    if (table is table_model.Tables) {
      selectedTable.value = table;
      final capacity = table.seatingCapacity ?? 1;
      pax.value = capacity;
      paxController.text = capacity.toString();
    } else {
      _resetTableData(clearSourceScreen: false);
    }

    if (order is order_model.GetOrderModel) {
      existingOrder = order;
      existingOrderId =
          order.data?.order?.uuid?.toString() ??
          order.data?.order?.id?.toString();
    }

    _parseDeliveryArgsFromMap(arguments);
  }

  void _refreshDeliveryArgsFromArguments() {
    final arguments = Get.arguments;
    if (arguments == null || arguments is! Map) return;
    _parseDeliveryArgsFromMap(arguments);
  }

  void _parseDeliveryArgsFromMap(Map<dynamic, dynamic> args) {
    if (args.containsKey(ArgumentConstant.deliveryCustomerIdKey)) {
      final v = args[ArgumentConstant.deliveryCustomerIdKey];
      deliveryCustomerId = v is int ? v : (v is num ? v.toInt() : null);
    }
    if (args.containsKey(ArgumentConstant.deliveryPreOrderDateTimeKey)) {
      deliveryPreOrderDateTime = _argString(
        args[ArgumentConstant.deliveryPreOrderDateTimeKey],
      );
    }
    if (args.containsKey(ArgumentConstant.deliveryTipAmountKey)) {
      deliveryTipAmount =
          _argDouble(args[ArgumentConstant.deliveryTipAmountKey]) ?? 0.0;
    }
    if (args.containsKey(ArgumentConstant.deliveryAddressKey)) {
      deliveryAddress = _argString(args[ArgumentConstant.deliveryAddressKey]);
    }
  }

  static String? _argString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }

  static double? _argDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  Map<String, String>? get _discountPayload =>
      discountValue.value > 0
          ? {
            'discount_type': discountType.value.toLowerCase(),
            'discount_value': discountValue.value.toString(),
          }
          : null;

  void _showErrorSnackbar(String message) {
    AppToast.showError(message, title: TranslationKeys.error.tr);
  }

  void _resetTableData({bool clearSourceScreen = true}) {
    selectedTable.value = null;
    pax.value = 1;
    paxController.text = '1';
    if (clearSourceScreen) sourceScreen = null;
  }

  void updatePax(int value) {
    if (value > 0) {
      pax.value = value;
      paxController.text = value.toString();
    }
  }

  Future<void> fetchTablesAreas() async {
    tableAreasList.clear();
    try {
      final response = await networkClient.get(
        ArgumentConstant.tablesAreasEndpoint,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        final tableModelData = table_model.TableModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (tableModelData.data != null) {
          tableAreasList.assignAll(tableModelData.data!);
        }
      }
    } catch (_) {
      // Tables fetch failed; tableAreasList remains empty
    }
  }

  String? _validateForSubmit(bool isExistingOrder, int? waiterId) {
    if (cartItems.isEmpty) return TranslationKeys.cartIsEmpty.tr;
    if (!isExistingOrder && !isDeliveryOrder && !isPickupOrder && !hasTable) {
      return TranslationKeys.pleaseSelectTableFirst.tr;
    }
    if (!isExistingOrder && isDeliveryOrder) {
      _refreshDeliveryArgsFromArguments();
      if (deliveryCustomerId == null)
        return TranslationKeys.pleaseSelectCustomerFirst.tr;
      if (deliveryAddress == null || deliveryAddress!.trim().isEmpty) {
        return TranslationKeys.deliveryAddressRequired.tr;
      }
    }
    if (!isExistingOrder && isPickupOrder) {
      _refreshDeliveryArgsFromArguments();
      if (deliveryCustomerId == null)
        return TranslationKeys.pleaseSelectCustomerFirstPickup.tr;
    }
    if (waiterId == null) return TranslationKeys.unableToGetUserInfo.tr;
    if (!isExistingOrder &&
        !isDeliveryOrder &&
        !isPickupOrder &&
        selectedTable.value?.id == null) {
      return TranslationKeys.tableInformationMissing.tr;
    }
    return null;
  }

  List<Map<String, dynamic>> _buildOrderItemsList() {
    return cartItems.map((item) {
      final itemData = <String, dynamic>{
        'menu_item_id': item.id,
        'quantity': item.quantity.value,
      };
      if (item.selectedVariation != null)
        itemData['menu_item_variation_id'] = item.selectedVariation!.id;
      final optionIds =
          item.selectedExtras
              ?.where((o) => o.id != null)
              .map((o) => o.id!)
              .toList();
      if (optionIds != null && optionIds.isNotEmpty)
        itemData['modifier_option_ids'] = optionIds;
      if (item.cartNote != null && item.cartNote!.isNotEmpty)
        itemData['note'] = item.cartNote;
      if (existingOrderId != null &&
          existingOrderId!.isNotEmpty &&
          item.cartKotItemId != null) {
        itemData['kot_item_id'] = item.cartKotItemId;
      }
      return itemData;
    }).toList();
  }

  /// Parses order id from API response (supports dine-in, delivery and pickup response shapes).
  String? _parseOrderIdFromResponse(Map<String, dynamic> res) {
    final data = res['data'];
    if (data != null && data is Map<String, dynamic>) {
      final order = data['order'];
      if (order != null && order is Map<String, dynamic>) {
        final id = order['uuid']?.toString() ?? order['id']?.toString();
        if (id != null && id.isNotEmpty) return id;
      }
      final id = data['uuid']?.toString() ?? data['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }
    final id =
        res['order_id']?.toString() ??
        res['uuid']?.toString() ??
        res['id']?.toString();
    return (id != null && id.isNotEmpty) ? id : null;
  }

  ({Map<String, dynamic> body, String endpoint}) _buildRequestAndEndpoint({
    required List<Map<String, dynamic>> itemsList,
    required String status,
    required int waiterId,
  }) {
    final isExisting = existingOrderId != null && existingOrderId!.isNotEmpty;
    if (isExisting) {
      return (
        body: {'items': itemsList},
        endpoint: ArgumentConstant.addOrderItemsEndpoint.replaceAll(
          ':order_uuid',
          existingOrderId!,
        ),
      );
    }
    if (isDeliveryOrder) {
      final body = <String, dynamic>{
        'order_type': 'delivery',
        'customer_id': deliveryCustomerId!,
        'via': 'pos',
        'items': itemsList,
        'status': status,
        'delivery_address': (deliveryAddress ?? '').trim(),
      };
      if (deliveryPreOrderDateTime != null &&
          deliveryPreOrderDateTime!.isNotEmpty)
        body['date_time'] = deliveryPreOrderDateTime;
      if (deliveryTipAmount > 0)
        body['tip_amount'] = deliveryTipAmount.toStringAsFixed(2);
      if (_discountPayload != null) body.addAll(_discountPayload!);
      return (body: body, endpoint: ArgumentConstant.deliveryOrdersEndpoint);
    }
    if (isPickupOrder) {
      final body = <String, dynamic>{
        'order_type': 'pickup',
        'customer_id': deliveryCustomerId!,
        'via': 'pos',
        'items': itemsList,
        'status': status,
      };
      if (deliveryPreOrderDateTime != null &&
          deliveryPreOrderDateTime!.isNotEmpty)
        body['date_time'] = deliveryPreOrderDateTime;
      if (deliveryTipAmount > 0)
        body['tip_amount'] = deliveryTipAmount.toStringAsFixed(2);
      if (_discountPayload != null) body.addAll(_discountPayload!);
      return (body: body, endpoint: ArgumentConstant.pickupOrdersEndpoint);
    }
    final body = <String, dynamic>{
      'order_type': 'dine_in',
      'table_id': selectedTable.value!.id,
      'waiter_id': waiterId,
      'number_of_pax': pax.value,
      'items': itemsList,
      'status': status,
    };
    if (_discountPayload != null) body.addAll(_discountPayload!);
    return (body: body, endpoint: ArgumentConstant.ordersEndpoint);
  }

  Future<void> submitOrder({
    bool createPayment = false,
    String status = 'kot',
  }) async {
    try {
      final isExistingOrder =
          existingOrderId != null && existingOrderId!.isNotEmpty;
      int? waiterId;
      try {
        final loginData = box.read(ArgumentConstant.loginModelKey);
        if (loginData is Map<String, dynamic>) {
          waiterId = LoginModel.fromJson(loginData).data?.user?.id;
        }
      } catch (_) {}

      final validationError = _validateForSubmit(isExistingOrder, waiterId);
      if (validationError != null) {
        _showErrorSnackbar(validationError);
        return;
      }

      if (createPayment &&
          existingOrderId != null &&
          ((existingOrder?.data?.order?.status ?? '')
                  .toString()
                  .toLowerCase() ==
              'billed')) {
        _navigateToOrderScreenAndOpenPayment(existingOrderId!);
        return;
      }

      isSubmittingOrder.value = true;

      final itemsList = _buildOrderItemsList();
      final request = _buildRequestAndEndpoint(
        itemsList: itemsList,
        status: status,
        waiterId: waiterId!,
      );

      final response =
          isExistingOrder
              ? await networkClient.put(request.endpoint, data: request.body)
              : await networkClient.post(request.endpoint, data: request.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        _showErrorSnackbar(TranslationKeys.failedToSubmitOrder.tr);
        return;
      }

      String? orderId = existingOrderId;
      if (!isExistingOrder && response.data is Map<String, dynamic>) {
        orderId = _parseOrderIdFromResponse(
          response.data as Map<String, dynamic>,
        );
      }

      final isBilledStatus = status.toLowerCase() == 'billed';
      if (isBilledStatus) {
        cartItems.clear();
        _resetTakeOrderDeliveryPickupIfNeeded();
      }

      if (createPayment && orderId != null) {
        _navigateToOrderScreenAndOpenPayment(orderId);
      } else {
        if (!isBilledStatus) {
          cartItems.clear();
          _resetTakeOrderDeliveryPickupIfNeeded();
        }
        _navigateBackAfterSubmit();
      }
    } on ApiException catch (e) {
      _showErrorSnackbar(e.message);
    } catch (e) {
      _showErrorSnackbar(TranslationKeys.failedToSubmitOrder.tr);
    } finally {
      isSubmittingOrder.value = false;
    }
  }

  void _resetTakeOrderDeliveryPickupIfNeeded() {
    final orderType = currentOrderType.value.toLowerCase();
    if (orderType != 'delivery' && orderType != 'pickup') return;
    try {
      if (Get.isRegistered<TakeOrderController>()) {
        Get.find<TakeOrderController>().resetDeliveryPickupOrderState();
      }
    } catch (_) {}
  }

  void _navigateToMainHomeWithTab(
    int tabIndex, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    Get.offAllNamed(Routes.MAIN_HOME_SCREEN);
    Future.delayed(delay, () {
      try {
        Get.find<MainHomeScreenController>().changeTab(tabIndex);
      } catch (_) {}
    });
  }

  void _navigateToOrderScreenAndOpenPayment(String orderId) {
    box.write(ArgumentConstant.pendingPaymentOrderIdKey, orderId);
    try {
      if (Get.isRegistered<OrderScreenController>()) {
        Get.delete<OrderScreenController>(force: true);
      }
    } catch (_) {}
    _navigateToMainHomeWithTab(0, delay: const Duration(milliseconds: 150));
  }

  void _navigateBackAfterSubmit() {
    if (sourceScreen != null && sourceScreen!.isNotEmpty) {
      if (sourceScreen == Routes.ORDER_SCREEN) {
        _navigateToMainHomeWithTab(0);
      } else if (sourceScreen == Routes.TABLE_SCREEN) {
        _navigateToMainHomeWithTab(1);
      } else {
        Get.back();
      }
    } else {
      Get.back();
    }
  }

  void _checkTaxIncluded() {
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData != null && storedData is Map<String, dynamic>) {
        final restaurantModel = RestaurantModel.fromJson(storedData);
        if (restaurantModel.data?.branches != null &&
            restaurantModel.data!.branches!.isNotEmpty) {
          final taxesIncludedValue =
              restaurantModel.data!.branches!.first.taxesIncluded;
          isTaxIncluded.value = taxesIncludedValue ?? false;
        } else {
          isTaxIncluded.value = false;
        }
      } else {
        isTaxIncluded.value = false;
      }
    } catch (e) {
      isTaxIncluded.value = false;
    }
  }

  void syncOrderTypeFromCartItems() {
    if (cartItems.isNotEmpty) {
      final firstItem = cartItems.first;
      if (firstItem.cartOrderType != null &&
          firstItem.cartOrderType!.isNotEmpty &&
          currentOrderType.value != firstItem.cartOrderType!) {
        currentOrderType.value = firstItem.cartOrderType!;
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    fetchTableFromArguments();
    fetchTablesAreas();
  }

  @override
  void onClose() {
    paxController.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }

  void updateItemQuantity(String cartItemId, int newQuantity) {
    final item = cartItems.firstWhereOrNull(
      (item) => item.cartItemId == cartItemId,
    );
    if (item != null) {
      item.quantity.value = newQuantity;
      cartItems.refresh();
      update([]);
    }
  }

  void removeItem(String cartItemId) {
    cartItems.removeWhere((item) => item.cartItemId == cartItemId);
    update([]);
  }

  bool _itemMatches(Items existing, Items newItem) {
    if (existing.id != newItem.id) return false;
    if (existing.selectedVariation?.id != newItem.selectedVariation?.id)
      return false;
    final existingExtras = existing.selectedExtras;
    final newExtras = newItem.selectedExtras;
    if ((existingExtras == null || existingExtras.isEmpty) &&
        (newExtras == null || newExtras.isEmpty)) {
      return true;
    }
    if (existingExtras != null &&
        newExtras != null &&
        existingExtras.length == newExtras.length) {
      final a = existingExtras.map((e) => e.id).toList()..sort();
      final b = newExtras.map((e) => e.id).toList()..sort();
      return a.toString() == b.toString();
    }
    return false;
  }

  Items? findExistingCartItem(Items newItem) {
    for (var existingItem in cartItems) {
      if (_itemMatches(existingItem, newItem)) return existingItem;
    }
    return null;
  }

  Items? _findNewlyAddedMatchingItem(Items newItem) {
    for (var existingItem in cartItems) {
      if (existingItem.cartKotItemId != null) continue;
      if (_itemMatches(existingItem, newItem)) return existingItem;
    }
    return null;
  }

  void addToCart(Items item) {
    final isExistingOrder =
        existingOrderId != null && existingOrderId!.isNotEmpty;
    final existingItem =
        isExistingOrder
            ? _findNewlyAddedMatchingItem(item)
            : findExistingCartItem(item);
    if (existingItem != null) {
      existingItem.quantity.value = existingItem.quantity.value + 1;
      cartItems.refresh();
    } else {
      cartItems.add(item);
    }

    if (box.read(ArgumentConstant.hapticFeedbackKey) ?? true) {
      HapticFeedback.vibrate();
      HapticFeedback.heavyImpact();
    }

    if (box.read(ArgumentConstant.beepSoundKey) ?? true) {
      _playBeepSound();
    }

    if (item.cartOrderType != null &&
        item.cartOrderType!.isNotEmpty &&
        currentOrderType.value != item.cartOrderType!) {
      currentOrderType.value = item.cartOrderType!;
    }
  }

  double get totalPrice {
    return cartItems.fold<double>(
      0.0,
      (sum, item) => sum + ((item.cartTotalPrice ?? 0.0) * item.quantity.value),
    );
  }

  int get totalItems {
    return cartItems.fold<int>(0, (sum, item) => sum + item.quantity.value);
  }

  int get lineItemCount => cartItems.length;

  Items? _findItemById(String cartItemId) {
    return cartItems.firstWhereOrNull((item) => item.cartItemId == cartItemId);
  }

  void startEditingNote(String cartItemId) {
    final item = _findItemById(cartItemId);
    if (item != null) {
      item.cartNoteDraft = item.cartNote ?? '';
      item.cartEditingNote = true;
      cartItems.refresh();
    }
  }

  void updateNoteDraft(String cartItemId, String value) {
    final item = _findItemById(cartItemId);
    if (item != null) {
      item.cartNoteDraft = value;
      cartItems.refresh();
    }
  }

  void saveNote(String cartItemId) {
    final item = _findItemById(cartItemId);
    if (item != null) {
      item.cartNote = item.cartNoteDraft ?? '';
      item.cartEditingNote = false;
      cartItems.refresh();
    }
  }

  void cancelEditingNote(String cartItemId) {
    final item = _findItemById(cartItemId);
    if (item != null) {
      item.cartNoteDraft = item.cartNote ?? '';
      item.cartEditingNote = false;
      cartItems.refresh();
    }
  }

  void setDiscount(double value, String type) {
    if (value <= 0) {
      discountValue.value = 0.0;
      discountType.value = type;
      return;
    }

    final maxDiscount = type == 'Fixed' ? totalPrice : 100.0;
    discountValue.value = value > maxDiscount ? maxDiscount : value;
    discountType.value = type;
  }

  void removeDiscount() {
    discountValue.value = 0.0;
    discountType.value = 'Fixed';
  }

  void clearCart() {
    cartItems.clear();
    discountValue.value = 0.0;
    discountType.value = 'Fixed';
    existingOrderId = null;
    existingOrder = null;
    _resetTableData(clearSourceScreen: true);
  }

  void applyArguments(Map<String, dynamic>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      _resetTableData();
      return;
    }

    final sourceScreenValue = arguments[ArgumentConstant.sourceScreenKey];
    sourceScreen = sourceScreenValue is String ? sourceScreenValue : null;

    final hideTableSectionValue =
        arguments[ArgumentConstant.hideTableSectionKey];
    hideTableSection = hideTableSectionValue == true;

    final table = arguments[ArgumentConstant.tableKey];
    final order = arguments[ArgumentConstant.orderKey];
    existingOrderId = null;
    existingOrder = null;

    if (table is table_model.Tables) {
      selectedTable.value = table;
      final capacity = table.seatingCapacity ?? 1;
      pax.value = capacity;
      paxController.text = capacity.toString();
    } else {
      _resetTableData(clearSourceScreen: false);
    }

    if (order is order_model.GetOrderModel) {
      existingOrder = order;
      existingOrderId =
          order.data?.order?.uuid?.toString() ??
          order.data?.order?.id?.toString();
    }

    _parseDeliveryArgsFromMap(arguments);
  }

  double get discountAmount {
    if (discountValue.value == 0.0) return 0.0;

    final calculatedDiscount =
        discountType.value == 'Fixed'
            ? discountValue.value
            : (totalPrice * discountValue.value) / 100;

    return calculatedDiscount > totalPrice ? totalPrice : calculatedDiscount;
  }

  double get subTotalAfterDiscount {
    final result = totalPrice - discountAmount;
    return result < 0 ? 0.0 : result;
  }

  void setOrderType(String orderType) {
    currentOrderType.value = orderType;
  }

  String get _orderTypeTaxKey {
    final t = currentOrderType.value.toLowerCase();
    if (t == 'dine in') return 'dine_in';
    if (t == 'delivery') return 'delivery';
    return 'pickup';
  }

  Map<String, double> get groupedTaxes {
    if (cartItems.isNotEmpty) {
      final taxMap = <String, double>{};
      final taxKey = _orderTypeTaxKey;
      for (var item in cartItems) {
        final itemPrice = item.cartTotalPrice ?? 0.0;
        final quantity = item.quantity.value;
        final taxesList = item.taxes?[taxKey];

        if (taxesList != null && taxesList.isNotEmpty) {
          for (var tax in taxesList) {
            if (tax.taxPercent != null && tax.taxPercent!.isNotEmpty) {
              try {
                final taxPercent = double.parse(tax.taxPercent!);
                final taxName = tax.taxName ?? 'Tax';
                final taxMapKey =
                    '$taxName (${taxPercent.toStringAsFixed(2)}%)';
                final taxForThisItem =
                    itemPrice * (taxPercent / (100 + taxPercent));
                taxMap[taxMapKey] =
                    (taxMap[taxMapKey] ?? 0.0) + (taxForThisItem * quantity);
              } catch (_) {}
            }
          }
        }
      }
      return taxMap;
    }

    if (existingOrder != null) {
      final orderData = existingOrder!.data!;
      if (orderData.taxes != null && orderData.taxes!.isNotEmpty) {
        final taxMap = <String, double>{};
        for (var tax in orderData.taxes!) {
          final taxAmount =
              tax.amount is num
                  ? (tax.amount as num).toDouble()
                  : double.tryParse(tax.amount?.toString() ?? '0') ?? 0.0;
          if (taxAmount > 0) {
            final percent = tax.percent?.toString() ?? '';
            final taxName = tax.taxName ?? 'Tax';
            final taxKey =
                percent.isNotEmpty ? '$taxName ($percent%)' : taxName;
            taxMap[taxKey] = taxAmount;
          }
        }
        return taxMap;
      }
    }

    return {};
  }

  List<order_model.Charges> get orderCharges {
    if (existingOrder != null) {
      final orderData = existingOrder!.data?.order;
      return orderData?.charges ?? [];
    }
    return [];
  }

  String get _orderTypeForCharges => currentOrderType.value.toLowerCase();

  List<({String label, double amount})> get _restaurantAdditionalCharges {
    if (_orderTypeForCharges == 'dine in') return [];
    final raw = <({String label, double amount})>[];
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData == null || storedData is! Map<String, dynamic>)
        return _mergeChargesByLabel(raw);
      final restaurantModel = RestaurantModel.fromJson(storedData);
      final branches = restaurantModel.data?.branches;
      if (branches == null || branches.isEmpty)
        return _mergeChargesByLabel(raw);
      final additionalCharges = branches.first.additionalCharges;
      if (additionalCharges == null || additionalCharges.isEmpty)
        return _mergeChargesByLabel(raw);
      final orderType = _orderTypeForCharges;
      final baseAmount = subTotalAfterDiscount;
      for (final charge in additionalCharges) {
        if (charge.isEnabled != 1) continue;
        final orderTypes = charge.orderTypes;
        if (orderTypes != null &&
            orderTypes.isNotEmpty &&
            !orderTypes.any((t) => t.toLowerCase() == orderType))
          continue;
        final rate = double.tryParse(charge.rate?.toString() ?? '') ?? 0.0;
        final amount =
            (charge.type?.toLowerCase() == 'percent')
                ? (baseAmount * rate / 100)
                : rate;
        if (amount > 0) {
          raw.add((label: charge.name ?? 'Charge', amount: amount));
        }
      }
    } catch (_) {}
    return _mergeChargesByLabel(raw);
  }

  List<({String label, double amount})> _mergeChargesByLabel(
    List<({String label, double amount})> charges,
  ) {
    if (charges.isEmpty) return [];
    final map = <String, double>{};
    for (final c in charges) {
      map[c.label] = (map[c.label] ?? 0) + c.amount;
    }
    return map.entries.map((e) => (label: e.key, amount: e.value)).toList();
  }

  List<({String label, double amount})> get displayCharges {
    if (existingOrder != null) {
      final list = <({String label, double amount})>[];
      for (final c in orderCharges) {
        final amount = c.amount ?? 0.0;
        if (amount > 0)
          list.add((label: c.chargeName ?? 'Charge', amount: amount));
      }
      return list;
    }
    return _restaurantAdditionalCharges;
  }

  double get totalTax {
    return groupedTaxes.values.fold<double>(0.0, (sum, value) => sum + value);
  }

  double get totalChargesAmount {
    if (existingOrder != null) {
      return orderCharges.fold<double>(0.0, (sum, charge) {
        final amount =
            charge.amount is num
                ? (charge.amount as num).toDouble()
                : double.tryParse(charge.amount?.toString() ?? '0') ?? 0.0;
        return sum + amount;
      });
    }
    return _restaurantAdditionalCharges.fold<double>(
      0.0,
      (sum, c) => sum + c.amount,
    );
  }

  double get finalTotal =>
      subTotalAfterDiscount +
      totalChargesAmount +
      (isTaxIncluded.value ? 0.0 : totalTax);

  Future<void> _playBeepSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/sound_beep.mp3'), volume: 0.2);
    } catch (e) {
      if (kDebugMode) {
        print('Error playing beep sound: $e');
      }
    }
  }
}
