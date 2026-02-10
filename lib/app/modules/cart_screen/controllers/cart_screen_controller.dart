import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/sizeConstant.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/LoginModels.dart';
import '../../../model/menuItemsModel.dart';
import '../../../model/RestaurantDetailsModel.dart';
import '../../../model/tableModel.dart' as tableModel;
import '../../../model/getorderModel.dart' as orderModel;
import '../../../modules/mainHome_screen/controllers/main_home_screen_controller.dart';
import '../../../routes/app_pages.dart';

class CartScreenController extends GetxController {
  final networkClient = NetworkClient();
  final AudioPlayer _audioPlayer = AudioPlayer();

  RxList<Items> cartItems = <Items>[].obs;
  RxDouble discountValue = 0.0.obs;
  RxString discountType = 'Fixed'.obs;
  RxBool isTaxIncluded = false.obs;
  final Rx<tableModel.Tables?> selectedTable = Rx<tableModel.Tables?>(null);
  String? existingOrderId;
  orderModel.GetOrderModel? existingOrder;
  String? sourceScreen;
  final RxInt pax = 1.obs;
  final TextEditingController paxController = TextEditingController();
  final RxList<tableModel.Data> tableAreasList = <tableModel.Data>[].obs;
  final RxBool isSubmittingOrder = false.obs;
  RxString currentOrderType = 'Pickup'.obs;
  bool hideTableSection = false;

  bool get hasTable => selectedTable.value != null;

  /// When true, show the table/Pax row at top (hidden for delivery/pickup).
  bool get showTableSection => hasTable && !hideTableSection;

  @override
  void onInit() {
    super.onInit();
    fetchTableFromArguments();
    fetchTablesAreas();
    _checkTaxIncluded();
    _syncOrderTypeFromCartItems();
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

    if (table is tableModel.Tables) {
      selectedTable.value = table;
      final capacity = table.seatingCapacity ?? 1;
      pax.value = capacity;
      paxController.text = capacity.toString();
    } else {
      _resetTableData(clearSourceScreen: false);
    }

    if (order is orderModel.GetOrderModel) {
      existingOrder = order;
      existingOrderId =
          order.data?.order?.uuid?.toString() ??
          order.data?.order?.id?.toString();
    }
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
        final tableModelData = tableModel.TableModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (tableModelData.data != null) {
          tableAreasList.assignAll(tableModelData.data!);
        }
      }
    } catch (e) {}
  }

  Future<void> submitOrder({
    bool createPayment = false,
    String status = 'kot',
  }) async {
    try {
      final bool isExistingOrder =
          existingOrderId != null && existingOrderId!.isNotEmpty;
      if (!isExistingOrder && !hasTable) {
        safeGetSnackbar(
          TranslationKeys.error.tr,
          TranslationKeys.pleaseSelectTableFirst.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (cartItems.isEmpty) {
        safeGetSnackbar(
          TranslationKeys.error.tr,
          TranslationKeys.cartIsEmpty.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isSubmittingOrder.value = true;

      int? waiterId;
      try {
        final loginData = box.read(ArgumentConstant.loginModelKey);
        if (loginData != null && loginData is Map<String, dynamic>) {
          final loginModel = LoginModel.fromJson(loginData);
          waiterId = loginModel.data?.user?.id;
        }
      } catch (e) {}

      if (waiterId == null) {
        safeGetSnackbar(
          TranslationKeys.error.tr,
          TranslationKeys.unableToGetUserInfo.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSubmittingOrder.value = false;
        return;
      }

      final tableId = selectedTable.value?.id;
      if (!isExistingOrder && tableId == null) {
        safeGetSnackbar(
          TranslationKeys.error.tr,
          TranslationKeys.tableInformationMissing.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSubmittingOrder.value = false;
        return;
      }

      final itemsList =
          cartItems.map((item) {
            final itemData = <String, dynamic>{
              'menu_item_id': item.id,
              'quantity': item.quantity.value,
            };

            if (item.selectedVariation != null) {
              itemData['menu_item_variation_id'] = item.selectedVariation!.id;
            }

            final optionIds =
                item.selectedExtras
                    ?.where((option) => option.id != null)
                    .map((option) => option.id!)
                    .toList();
            if (optionIds != null && optionIds.isNotEmpty) {
              itemData['modifier_option_ids'] = optionIds;
            }

            if (item.cartNote != null && item.cartNote!.isNotEmpty) {
              itemData['note'] = item.cartNote;
            }

            if (isExistingOrder && item.cartKotItemId != null) {
              itemData['kot_item_id'] = item.cartKotItemId;
            }

            return itemData;
          }).toList();

      final requestBody =
          isExistingOrder
              ? {'items': itemsList}
              : {
                'order_type': 'dine_in',
                'table_id': tableId,
                'waiter_id': waiterId,
                'number_of_pax': pax.value,
                'items': itemsList,
                'status': status,
                if (discountValue.value > 0) ...{
                  'discount_type': discountType.value.toLowerCase(),
                  'discount_value': discountValue.value.toString(),
                },
              };

      final endpoint =
          isExistingOrder
              ? ArgumentConstant.addOrderItemsEndpoint.replaceAll(
                ':order_uuid',
                existingOrderId!,
              )
              : ArgumentConstant.ordersEndpoint;

      final response =
          isExistingOrder
              ? await networkClient.put(endpoint, data: requestBody)
              : await networkClient.post(endpoint, data: requestBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        String? orderId = existingOrderId;

        if (!isExistingOrder && response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          final data = responseData['data'] as Map<String, dynamic>?;
          orderId =
              data?['uuid']?.toString() ??
              data?['id']?.toString() ??
              responseData['order_id']?.toString() ??
              responseData['uuid']?.toString() ??
              responseData['id']?.toString();
        }

        if (createPayment && orderId != null) {
          await _createPayment(orderId);
        } else {
          cartItems.clear();
          _navigateBackAfterSubmit();
        }
      } else {
        safeGetSnackbar(
          TranslationKeys.error.tr,
          TranslationKeys.failedToSubmitOrder.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.failedToSubmitOrder.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmittingOrder.value = false;
    }
  }

  Future<void> _createPayment(String orderId) async {
    try {
      final paymentBody = {
        'order_id': orderId,
        'amount': finalTotal.toStringAsFixed(2),
        'payment_method': 'cash',
      };

      final paymentResponse = await networkClient.post(
        ArgumentConstant.paymentsEndpoint,
        data: paymentBody,
      );

      if (paymentResponse.statusCode == 200 ||
          paymentResponse.statusCode == 201) {
        safeGetSnackbar(
          TranslationKeys.success.tr,
          TranslationKeys.paymentCreatedSuccessfully.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: ColorConstants.successGreen,
          colorText: Colors.white,
        );
        cartItems.clear();
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateBackAfterSubmit();
      } else {
        safeGetSnackbar(
          TranslationKeys.error.tr,
          TranslationKeys.failedToCreatePayment.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.failedToCreatePayment.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateBackAfterSubmit() {
    if (sourceScreen != null && sourceScreen!.isNotEmpty) {
      if (sourceScreen == Routes.ORDER_SCREEN) {
        Get.offAllNamed(Routes.MAIN_HOME_SCREEN);
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            Get.find<MainHomeScreenController>().changeTab(0);
          } catch (_) {}
        });
      } else if (sourceScreen == Routes.TABLE_SCREEN) {
        Get.offAllNamed(Routes.MAIN_HOME_SCREEN);
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            Get.find<MainHomeScreenController>().changeTab(1);
          } catch (_) {}
        });
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

  void _syncOrderTypeFromCartItems() {
    syncOrderTypeFromCartItems();
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
    }
  }

  void removeItem(String cartItemId) {
    cartItems.removeWhere((item) => item.cartItemId == cartItemId);
  }

  Items? findExistingCartItem(Items newItem) {
    for (var existingItem in cartItems) {
      if (existingItem.id != newItem.id) continue;
      if (existingItem.selectedVariation?.id != newItem.selectedVariation?.id) {
        continue;
      }

      final existingExtras = existingItem.selectedExtras;
      final newExtras = newItem.selectedExtras;

      if ((existingExtras == null || existingExtras.isEmpty) &&
          (newExtras == null || newExtras.isEmpty)) {
        return existingItem;
      }

      if (existingExtras != null &&
          newExtras != null &&
          existingExtras.length == newExtras.length) {
        final existingIds = existingExtras.map((e) => e.id).toList()..sort();
        final newIds = newExtras.map((e) => e.id).toList()..sort();
        if (existingIds.toString() == newIds.toString()) {
          return existingItem;
        }
      }
    }
    return null;
  }

  void addToCart(Items item) {
    final isExistingOrder =
        existingOrderId != null && existingOrderId!.isNotEmpty;

    if (isExistingOrder) {
      cartItems.add(item);
    } else {
      final existingItem = findExistingCartItem(item);
      if (existingItem != null) {
        existingItem.quantity.value = existingItem.quantity.value + 1;
        cartItems.refresh();
      } else {
        cartItems.add(item);
      }
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

  Map<String, double> get groupedTaxes {
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

    final taxMap = <String, double>{};
    final orderTypeLower = currentOrderType.value.toLowerCase();
    final taxKey =
        orderTypeLower == 'dine in'
            ? 'dine_in'
            : orderTypeLower == 'pickup'
            ? 'pickup'
            : orderTypeLower == 'delivery'
            ? 'delivery'
            : 'pickup';

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
              final taxMapKey = '$taxName (${taxPercent.toStringAsFixed(2)}%)';
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

  List<orderModel.Charges> get orderCharges {
    if (existingOrder != null) {
      final orderData = existingOrder!.data?.order;
      return orderData?.charges ?? [];
    }
    return [];
  }

  double get totalTax {
    return groupedTaxes.values.fold<double>(0.0, (sum, value) => sum + value);
  }

  double get finalTotal => subTotalAfterDiscount;

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
