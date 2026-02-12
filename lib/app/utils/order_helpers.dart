import 'package:get/get.dart';
import 'package:managerapp/app/model/RestaurantDetailsModel.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import '../../main.dart';

/// Shared business logic helpers for order-related functionality.
/// Extracted from order_screen_view.dart and new_order_details_bottom_sheet.dart
/// to eliminate code duplication.

/// Formats the order type string for display.
String formatOrderType(String? orderType) {
  if (orderType == null || orderType.isEmpty) {
    return TranslationKeys.na.tr;
  }
  switch (orderType.toLowerCase()) {
    case 'dine_in':
      return TranslationKeys.dineIn.tr;
    case 'pickup':
      return TranslationKeys.pickup.tr;
    case 'delivery':
      return TranslationKeys.delivery.tr;
    default:
      return TranslationKeys.na.tr;
  }
}

/// Returns a time label based on order type (delivery/pickup).
String? getTimeLabel(String orderType) {
  if (orderType == 'delivery' || orderType == 'delivery_order') {
    return TranslationKeys.deliveryTime.tr;
  } else if (orderType == 'pickup' || orderType == 'pickup_order') {
    return TranslationKeys.pickupTime.tr;
  }
  return null;
}

/// Checks if the order type is dine-in.
bool isDineInOrder(String? orderType) {
  if (orderType == null) return false;
  final type = orderType.toLowerCase().replaceAll(' ', '_');
  return type == 'dine_in' || type == 'dinein' || type == 'dine in';
}

/// Checks if customer information is available.
/// Works with any Customer object that has name, email, phoneNumber fields.
bool hasCustomerInfo(dynamic customer) {
  if (customer == null) return false;
  return (customer.name != null && customer.name!.isNotEmpty) ||
      (customer.email != null && customer.email!.isNotEmpty) ||
      (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty);
}

/// Checks if waiter information is available.
/// Works with any Waiter object that has name, id, email, phoneNumber fields.
bool hasWaiterInfo(dynamic waiter) {
  if (waiter == null) return false;
  return (waiter.name != null && waiter.name!.trim().isNotEmpty) ||
      waiter.id != null ||
      (waiter.email != null && waiter.email!.trim().isNotEmpty) ||
      (waiter.phoneNumber != null && waiter.phoneNumber!.trim().isNotEmpty);
}

/// Validates if a given string can be parsed as a positive amount.
bool isValidAmount(String? amount) {
  if (amount == null ||
      amount.isEmpty ||
      amount == 'null' ||
      amount == '0' ||
      amount == '0.0' ||
      amount == '0.00') {
    return false;
  }
  final value = double.tryParse(amount);
  return value != null && value > 0;
}

/// Retrieves branch information from local storage.
Branches? getBranch() {
  try {
    final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
    if (storedData == null || storedData is! Map<String, dynamic>) {
      return null;
    }
    final restaurantDetails = RestaurantModel.fromJson(storedData);
    if (restaurantDetails.data?.branches == null ||
        restaurantDetails.data!.branches!.isEmpty) {
      return null;
    }
    return restaurantDetails.data!.branches!.first;
  } catch (e) {
    return null;
  }
}

/// Determines if tax is included based on order data or branch settings.
/// Works with any order data object that has taxInclusive field.
bool isTaxIncluded(dynamic orderData) {
  if (orderData.taxInclusive != null) {
    return orderData.taxInclusive == true;
  }
  final branch = getBranch();
  return branch?.taxesIncluded == true;
}

/// Checks if a status code indicates success (used in API responses).
bool isSuccessStatus(int? statusCode) =>
    statusCode == 200 || statusCode == 201 || statusCode == 204;
