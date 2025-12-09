import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
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

  // Cart items list - using Items model directly
  RxList<Items> cartItems = <Items>[].obs;

  // Discount fields
  RxDouble discountValue = 0.0.obs;
  RxString discountType = 'Fixed'.obs; // 'Fixed' or 'Percent'

  // Tax included flag
  RxBool isTaxIncluded = false.obs;

  // Table from arguments
  final Rx<tableModel.Tables?> selectedTable = Rx<tableModel.Tables?>(null);

  // Existing order (when coming from Continue to order)
  String? existingOrderId;
  orderModel.GetOrderModel? existingOrder;

  // Getter to check if table exists
  bool get hasTable => selectedTable.value != null;

  // Pax (number of people) - editable
  final RxInt pax = 1.obs;
  final TextEditingController paxController = TextEditingController();

  // Table areas list
  final RxList<tableModel.Data> tableAreasList = <tableModel.Data>[].obs;

  // Loading state for order submission
  final RxBool isSubmittingOrder = false.obs;

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
    if (arguments != null && arguments is Map) {
      final table = arguments[ArgumentConstant.tableKey];
      final order = arguments[ArgumentConstant.orderKey];

      if (table != null && table is tableModel.Tables) {
        selectedTable.value = table;
        // Set initial pax to table capacity
        final capacity = table.seatingCapacity ?? 1;
        pax.value = capacity;
        paxController.text = capacity.toString();
      } else {
        // Clear table if not in arguments
        selectedTable.value = null;
        pax.value = 1;
        paxController.text = '1';
      }

      if (order != null && order is orderModel.GetOrderModel) {
        existingOrder = order;
        existingOrderId =
            order.data?.uuid?.toString() ?? order.data?.id?.toString();
      }
    } else {
      // Clear table if no arguments
      selectedTable.value = null;
      pax.value = 1;
      paxController.text = '1';
    }
  }

  void updatePax(int value) {
    if (value > 0) {
      pax.value = value;
      paxController.text = value.toString();
    }
  }

  Future<void> fetchTablesAreas() async {
    // Clear existing list before fetching
    tableAreasList.clear();
    try {
      final response = await networkClient.get(
        ArgumentConstant.tablesAreasEndpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          final tableModelData = tableModel.TableModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          if (tableModelData.data != null) {
            tableAreasList.assignAll(tableModelData.data!);
          }
        }
      }
    } catch (e) {
      print('Error fetching table areas: $e');
    }
  }

  Future<void> submitOrder({
    bool createPayment = false,
    String status = 'kot',
  }) async {
    try {
      if (!hasTable) {
        return;
      }

      if (cartItems.isEmpty) {
        return;
      }

      // Show loader
      isSubmittingOrder.value = true;

      int? waiterId;
      try {
        final loginData = box.read(ArgumentConstant.loginModelKey);
        if (loginData != null && loginData is Map<String, dynamic>) {
          final loginModel = LoginModel.fromJson(loginData);
          waiterId = loginModel.data?.user?.id;
        }
      } catch (e) {
        print('Error getting user id: $e');
      }

      if (waiterId == null) {
        return;
      }

      final tableId = selectedTable.value?.id;
      if (tableId == null) {
        return;
      }

      final bool isExistingOrder =
          existingOrderId != null && existingOrderId!.isNotEmpty;

      final List<Map<String, dynamic>> itemsList = [];

      if (isExistingOrder && existingOrder != null) {
        // For existing orders, use kot_item_id only if cart item already has it
        // (meaning it came from the existing order)
        // Items added from menu won't have cartKotItemId and will be added as new items
        for (var cartItem in cartItems) {
          final itemData = <String, dynamic>{
            'menu_item_id': cartItem.id,
            'quantity': cartItem.quantity.value,
          };

          if (cartItem.selectedVariation != null) {
            itemData['menu_item_variation_id'] = cartItem.selectedVariation!.id;
          }

          if (cartItem.selectedExtras != null &&
              cartItem.selectedExtras!.isNotEmpty) {
            final optionIds =
                cartItem.selectedExtras!
                    .where((option) => option.id != null)
                    .map((option) => option.id!)
                    .toList();
            if (optionIds.isNotEmpty) {
              itemData['modifier_option_ids'] = optionIds;
            }
          }

          if (cartItem.cartNote != null && cartItem.cartNote!.isNotEmpty) {
            itemData['note'] = cartItem.cartNote;
          }

          // Add kot_item_id only if cart item has it (loaded from existing order)
          // Items added from menu won't have cartKotItemId and will be added as new items
          if (cartItem.cartKotItemId != null) {
            itemData['kot_item_id'] = cartItem.cartKotItemId;
          }
          // If no cartKotItemId, it's a new item added from menu (no kot_item_id)

          itemsList.add(itemData);
        }
      } else {
        // For new orders, build items list normally
        for (var item in cartItems) {
          final itemData = <String, dynamic>{
            'menu_item_id': item.id,
            'quantity': item.quantity.value,
          };

          if (item.selectedVariation != null) {
            itemData['menu_item_variation_id'] = item.selectedVariation!.id;
          }

          if (item.selectedExtras != null && item.selectedExtras!.isNotEmpty) {
            final optionIds =
                item.selectedExtras!
                    .where((option) => option.id != null)
                    .map((option) => option.id!)
                    .toList();
            if (optionIds.isNotEmpty) {
              itemData['modifier_option_ids'] = optionIds;
            }
          }

          if (item.cartNote != null && item.cartNote!.isNotEmpty) {
            itemData['note'] = item.cartNote;
          }

          itemsList.add(itemData);
        }
      }

      Map<String, dynamic> requestBody;
      String endpoint;

      if (isExistingOrder) {
        // Sync items to existing order
        requestBody = {'items': itemsList};
        endpoint = ArgumentConstant.addOrderItemsEndpoint.replaceAll(
          ':order_uuid',
          existingOrderId!,
        );
      } else {
        // Create new order
        requestBody = {
          'order_type': 'dine_in',
          'table_id': tableId,
          'waiter_id': waiterId,
          'number_of_pax': pax.value,
          'items': itemsList,
          'status': status,
        };

        // Add discount if applied
        if (discountValue.value > 0) {
          requestBody['discount_type'] = discountType.value.toLowerCase();
          requestBody['discount_value'] = discountValue.value.toString();
        }

        endpoint = ArgumentConstant.ordersEndpoint;
      }

      // Call Order API (create or append items)
      // Use PUT for sync endpoint, POST for new orders
      final response =
          isExistingOrder
              ? await networkClient.put(endpoint, data: requestBody)
              : await networkClient.post(endpoint, data: requestBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract order_id from response (for new orders) or use existing
        String? orderId = existingOrderId;

        if (!isExistingOrder) {
          if (response.data != null && response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            if (responseData['data'] != null &&
                responseData['data'] is Map<String, dynamic>) {
              final data = responseData['data'] as Map<String, dynamic>;
              // Prefer UUID, fallback to ID
              orderId = data['uuid']?.toString() ?? data['id']?.toString();
            } else {
              // Fallback to direct keys
              orderId =
                  responseData['order_id']?.toString() ??
                  responseData['uuid']?.toString() ??
                  responseData['id']?.toString();
            }
          }
        }

        if (createPayment && orderId != null) {
          await _createPayment(orderId);
        } else {
          cartItems.clear();
          Get.offAllNamed(Routes.MAIN_HOME_SCREEN);
          Future.delayed(const Duration(milliseconds: 100), () {
            try {
              final mainHomeController = Get.find<MainHomeScreenController>();
              mainHomeController.changeTab(1);
            } catch (e) {
              print('Main home controller not found: $e');
            }
          });
        }
      }
    } catch (e) {
      print('Error submitting order: $e');
    } finally {
      // Hide loader
      isSubmittingOrder.value = false;
    }
  }

  Future<void> _createPayment(String orderId) async {
    try {
      // Keep loader visible during payment
      final paymentBody = {
        'order_id': orderId,
        'amount': finalTotal.toStringAsFixed(2),
        'payment_method': 'cash',
      };

      // Call Payment API
      final paymentResponse = await networkClient.post(
        ArgumentConstant.paymentsEndpoint,
        data: paymentBody,
      );

      if (paymentResponse.statusCode == 200 ||
          paymentResponse.statusCode == 201) {
        cartItems.clear();
        Get.offAllNamed(Routes.MAIN_HOME_SCREEN);
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            final mainHomeController = Get.find<MainHomeScreenController>();
            mainHomeController.changeTab(1);
          } catch (e) {
            print('Main home controller not found: $e');
          }
        });
      }
    } catch (e) {
      print('Error creating payment: $e');
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
      // Get order type from first cart item
      final firstItem = cartItems.first;
      if (firstItem.cartOrderType != null &&
          firstItem.cartOrderType!.isNotEmpty) {
        final orderType = firstItem.cartOrderType!;
        if (currentOrderType.value != orderType) {
          currentOrderType.value = orderType;
        }
      }
    }
  }

  void _syncOrderTypeFromCartItems() {
    syncOrderTypeFromCartItems();
  }

  @override
  void onReady() {
    super.onReady();
    // Fetch table arguments again in onReady to ensure fresh data
    fetchTableFromArguments();
    // Refresh table areas list every time screen is opened
    fetchTablesAreas();
  }

  @override
  void onClose() {
    paxController.dispose();
    super.onClose();
  }

  // Update quantity for a specific item
  void updateItemQuantity(String cartItemId, int newQuantity) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i].cartItemId == cartItemId) {
        cartItems[i].quantity.value = newQuantity;
        cartItems.refresh();
        break;
      }
    }
  }

  // Remove item from cart
  void removeItem(String cartItemId) {
    cartItems.removeWhere((item) => item.cartItemId == cartItemId);
  }

  // Check if same item already exists in cart
  Items? findExistingCartItem(Items newItem) {
    for (var existingItem in cartItems) {
      // Check if same item id
      if (existingItem.id != newItem.id) continue;

      // Check if same variation
      final existingVariationId = existingItem.selectedVariation?.id;
      final newVariationId = newItem.selectedVariation?.id;
      if (existingVariationId != newVariationId) continue;

      // Check if same extras
      final existingExtras = existingItem.selectedExtras;
      final newExtras = newItem.selectedExtras;

      // Both null or both empty
      if ((existingExtras == null || existingExtras.isEmpty) &&
          (newExtras == null || newExtras.isEmpty)) {
        return existingItem;
      }

      // Both have extras - check if same
      if (existingExtras != null &&
          newExtras != null &&
          existingExtras.length == newExtras.length) {
        final existingExtrasIds =
            existingExtras.map((e) => e.id).toList()..sort();
        final newExtrasIds = newExtras.map((e) => e.id).toList()..sort();

        bool extrasMatch = true;
        for (int i = 0; i < existingExtrasIds.length; i++) {
          if (existingExtrasIds[i] != newExtrasIds[i]) {
            extrasMatch = false;
            break;
          }
        }

        if (extrasMatch) {
          return existingItem;
        }
      }
    }
    return null;
  }

  // Add item to cart (with duplicate check)
  void addToCart(Items item) {
    // Check if this is an existing order
    final bool isExistingOrder =
        existingOrderId != null && existingOrderId!.isNotEmpty;

    // For existing orders, always add as new item (don't merge with existing items)
    if (isExistingOrder) {
      // Always add as new item - don't check for duplicates
      cartItems.add(item);
    } else {
      // For new orders, check for duplicates and merge if found
      final existingItem = findExistingCartItem(item);

      if (existingItem != null) {
        // Same item exists - increase quantity
        existingItem.quantity.value = existingItem.quantity.value + 1;
        cartItems.refresh();
      } else {
        // New item - add to cart
        cartItems.add(item);
      }
    }

    // Trigger haptic feedback if enabled
    final hapticEnabled = box.read(ArgumentConstant.hapticFeedbackKey) ?? true;
    if (hapticEnabled) {
      HapticFeedback.heavyImpact();
    }

    // Sync order type from the item (restaurant settings based)
    if (item.cartOrderType != null && item.cartOrderType!.isNotEmpty) {
      final newOrderType = item.cartOrderType!;
      if (currentOrderType.value != newOrderType) {
        currentOrderType.value = newOrderType;
        print('Order type updated to: $newOrderType for additional charges');
      }
    }
  }

  // Get total price
  double get totalPrice {
    double total = 0.0;
    for (var item in cartItems) {
      double price = item.cartTotalPrice ?? 0.0;
      int quantity = item.quantity.value;
      total += (price * quantity);
    }
    return total;
  }

  // Get total items count
  int get totalItems {
    int total = 0;
    for (var item in cartItems) {
      total += item.quantity.value;
    }
    return total;
  }

  // --- Notes handling per item ---
  void startEditingNote(String cartItemId) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i].cartItemId == cartItemId) {
        cartItems[i].cartNoteDraft = cartItems[i].cartNote ?? '';
        cartItems[i].cartEditingNote = true;
        cartItems.refresh();
        break;
      }
    }
  }

  void updateNoteDraft(String cartItemId, String value) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i].cartItemId == cartItemId) {
        cartItems[i].cartNoteDraft = value;
        cartItems.refresh();
        break;
      }
    }
  }

  void saveNote(String cartItemId) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i].cartItemId == cartItemId) {
        cartItems[i].cartNote = cartItems[i].cartNoteDraft ?? '';
        cartItems[i].cartEditingNote = false;
        cartItems.refresh();
        break;
      }
    }
  }

  void cancelEditingNote(String cartItemId) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i].cartItemId == cartItemId) {
        cartItems[i].cartNoteDraft = cartItems[i].cartNote ?? '';
        cartItems[i].cartEditingNote = false;
        cartItems.refresh();
        break;
      }
    }
  }

  // Discount methods
  void setDiscount(double value, String type) {
    // Validate discount - cannot exceed sub total
    if (value <= 0) {
      discountValue.value = 0.0;
      discountType.value = type;
      return;
    }

    double maxDiscount = 0.0;
    if (type == 'Fixed') {
      // For fixed discount, max is sub total
      maxDiscount = totalPrice;
    } else {
      // For percent discount, max is 100%
      maxDiscount = 100.0;
    }

    // Limit discount to maximum allowed
    if (value > maxDiscount) {
      discountValue.value = maxDiscount;
    } else {
      discountValue.value = value;
    }
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

  // Get discount amount (applied on sub total)
  double get discountAmount {
    if (discountValue.value == 0.0) return 0.0;

    double calculatedDiscount = 0.0;
    if (discountType.value == 'Fixed') {
      calculatedDiscount = discountValue.value;
    } else {
      // Percent - applied on sub total
      calculatedDiscount = (totalPrice * discountValue.value) / 100;
    }

    // Discount cannot exceed sub total
    if (calculatedDiscount > totalPrice) {
      return totalPrice;
    }
    return calculatedDiscount;
  }

  // Get sub total after discount (cannot be negative)
  double get subTotalAfterDiscount {
    final result = totalPrice - discountAmount;
    return result < 0 ? 0.0 : result;
  }

  // Get current order type (default to Pickup, can be updated)
  RxString currentOrderType = 'Pickup'.obs;

  void setOrderType(String orderType) {
    currentOrderType.value = orderType;
  }

  // Get grouped taxes with their amounts
  // Returns a map where key is "taxName (taxPercent%)" and value is the total tax amount
  // Different tax types will show as separate lines
  // Same tax types from different items will be grouped together
  Map<String, double> get groupedTaxes {
    Map<String, double> taxMap = {};

    for (var item in cartItems) {
      double itemPrice = item.cartTotalPrice ?? 0.0;
      int quantity = item.quantity.value;

      // Get taxes for this item
      if (item.taxes != null && item.taxes!.isNotEmpty) {
        // Calculate tax for each tax type in this item
        for (var tax in item.taxes!) {
          if (tax.taxPercent != null && tax.taxPercent!.isNotEmpty) {
            try {
              double taxPercent = double.parse(tax.taxPercent!);
              String taxName = tax.taxName ?? 'Tax';

              // Create unique key for grouping (tax name + percentage)
              // Same tax name and percentage will be grouped together
              // Different tax types will have different keys and show separately
              String taxKey = '$taxName (${taxPercent.toStringAsFixed(2)}%)';

              // Since tax is included in price, extract it
              // Formula: tax = price * (taxPercent / (100 + taxPercent))
              double taxForThisItem =
                  itemPrice * (taxPercent / (100 + taxPercent));

              // Add to map (sum if same tax type exists in multiple items)
              // If different tax types, they will have different keys
              taxMap[taxKey] =
                  (taxMap[taxKey] ?? 0.0) + (taxForThisItem * quantity);
            } catch (e) {
              // If parsing fails, skip this tax
            }
          }
        }
      }
    }

    return taxMap;
  }

  // Get total tax amount (calculated from each item's taxes)
  double get totalTax {
    double totalTaxAmount = 0.0;
    groupedTaxes.forEach((key, value) {
      totalTaxAmount += value;
    });
    return totalTaxAmount;
  }

  // Get final total
  double get finalTotal {
    return subTotalAfterDiscount;
  }
}
