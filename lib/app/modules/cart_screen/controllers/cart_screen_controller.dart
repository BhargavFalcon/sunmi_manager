import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../model/menuItemsModel.dart';
import '../../../model/RestaurantDetailsModel.dart';

class CartScreenController extends GetxController {
  // Cart items list - using Items model directly
  RxList<Items> cartItems = <Items>[].obs;

  // Discount fields
  RxDouble discountValue = 0.0.obs;
  RxString discountType = 'Fixed'.obs; // 'Fixed' or 'Percent'

  // Tax included flag
  RxBool isTaxIncluded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkTaxIncluded();
    _syncOrderTypeFromCartItems();
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
  }

  @override
  void onClose() {
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
    final existingItem = findExistingCartItem(item);

    if (existingItem != null) {
      // Same item exists - increase quantity
      existingItem.quantity.value = existingItem.quantity.value + 1;
      cartItems.refresh();
    } else {
      // New item - add to cart
      cartItems.add(item);
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
