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

  // Additional charges
  RxList<AdditionalCharges> additionalCharges = <AdditionalCharges>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkTaxIncluded();
    _loadAdditionalCharges();
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
          print('Tax included value: $taxesIncludedValue');
        } else {
          print('No branches found in restaurant details');
          isTaxIncluded.value = false;
        }
      } else {
        print('No restaurant details found in box');
        isTaxIncluded.value = false;
      }
    } catch (e) {
      print('Error checking tax included: $e');
      isTaxIncluded.value = false;
    }
  }

  void _loadAdditionalCharges() {
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData != null && storedData is Map<String, dynamic>) {
        final restaurantModel = RestaurantModel.fromJson(storedData);
        if (restaurantModel.data?.branches != null &&
            restaurantModel.data!.branches!.isNotEmpty) {
          final branch = restaurantModel.data!.branches!.first;
          if (branch.additionalCharges != null &&
              branch.additionalCharges!.isNotEmpty) {
            // Filter only enabled charges
            additionalCharges.value =
                branch.additionalCharges!
                    .where((charge) => charge.isEnabled == 1)
                    .toList();
            print('Additional charges loaded: ${additionalCharges.length}');
          } else {
            additionalCharges.clear();
            print('No additional charges found');
          }
        }
      }
    } catch (e) {
      print('Error loading additional charges: $e');
      additionalCharges.clear();
    }
  }

  // Get additional charges list for current order type
  List<AdditionalCharges> getAdditionalChargesForOrderType(String orderType) {
    return additionalCharges
        .where(
          (charge) =>
              charge.orderTypes != null &&
              charge.orderTypes!.contains(orderType),
        )
        .toList();
  }

  // Get additional charges total for current order type
  double getAdditionalChargesTotal(String orderType) {
    double total = 0.0;
    for (var charge in additionalCharges) {
      // Check if charge applies to this order type
      if (charge.orderTypes != null && charge.orderTypes!.contains(orderType)) {
        if (charge.type == 'fixed') {
          total += double.tryParse(charge.rate ?? '0') ?? 0.0;
        } else if (charge.type == 'percent') {
          final rate = double.tryParse(charge.rate ?? '0') ?? 0.0;
          total += (subTotalAfterDiscount * rate) / 100;
        }
      }
    }
    return total;
  }

  // Get charge amount for a specific charge
  double getChargeAmount(AdditionalCharges charge) {
    if (charge.type == 'fixed') {
      return double.tryParse(charge.rate ?? '0') ?? 0.0;
    } else if (charge.type == 'percent') {
      final rate = double.tryParse(charge.rate ?? '0') ?? 0.0;
      return (subTotalAfterDiscount * rate) / 100;
    }
    return 0.0;
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
    discountValue.value = value;
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

  // Get VAT/Tax amount from cart items
  double get vatAmount {
    if (isTaxIncluded.value && cartItems.isNotEmpty) {
      // If tax is included, calculate VAT from sub total after discount
      // We need to get tax percentage from items
      double totalTaxPercent = 0.0;

      // Get tax percentage from first item that has taxes
      for (var item in cartItems) {
        if (item.taxes != null && item.taxes!.isNotEmpty) {
          final tax = item.taxes!.first;
          totalTaxPercent = double.tryParse(tax.taxPercent ?? '0') ?? 0.0;
          if (totalTaxPercent > 0) {
            break; // Use first tax found
          }
        }
      }

      if (totalTaxPercent > 0) {
        // Calculate VAT from tax-included price
        // Formula: VAT = (Price * Tax%) / (100 + Tax%)
        // Since subTotalAfterDiscount already includes tax, we extract it
        return (subTotalAfterDiscount * totalTaxPercent) /
            (100 + totalTaxPercent);
      }
    }
    return 0.0;
  }

  // Get VAT percentage
  String get vatPercentage {
    for (var item in cartItems) {
      if (item.taxes != null && item.taxes!.isNotEmpty) {
        final tax = item.taxes!.first;
        final taxPercent = tax.taxPercent ?? '0';
        return taxPercent;
      }
    }
    return '0';
  }

  // Get VAT name
  String get vatName {
    for (var item in cartItems) {
      if (item.taxes != null && item.taxes!.isNotEmpty) {
        final tax = item.taxes!.first;
        return tax.taxName ?? 'VAT';
      }
    }
    return 'VAT';
  }

  // Get final total (including additional charges)
  double get finalTotal {
    double total = subTotalAfterDiscount;
    // Add additional charges based on order type
    total += getAdditionalChargesTotal(currentOrderType.value);
    return total;
  }
}
