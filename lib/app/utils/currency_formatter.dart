import '../../../main.dart';
import '../constants/api_constants.dart';
import '../model/restaurant_details_model.dart';

class CurrencyFormatter {
  // Get restaurant details from box
  static RestaurantModel? getRestaurantDetails() {
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData != null && storedData is Map<String, dynamic>) {
        return RestaurantModel.fromJson(storedData);
      }
    } catch (e) {}
    return null;
  }

  // Get currency symbol
  static String getCurrencySymbol() {
    final restaurantDetails = getRestaurantDetails();
    if (restaurantDetails?.data?.branches != null &&
        restaurantDetails!.data!.branches!.isNotEmpty) {
      final branch = restaurantDetails.data!.branches!.first;
      if (branch.currency != null && branch.currency!.currency != null) {
        return branch.currency!.currency!;
      }
    }
    return '€'; // Default currency
  }

  // Get currency position (before or after)
  static String getCurrencyPosition() {
    final restaurantDetails = getRestaurantDetails();
    if (restaurantDetails?.data?.branches != null &&
        restaurantDetails!.data!.branches!.isNotEmpty) {
      final branch = restaurantDetails.data!.branches!.first;
      return branch.currencyPosition ?? 'before';
    }
    return 'before'; // Default position
  }

  // Get thousand separator
  static String getThousandSeparator() {
    final restaurantDetails = getRestaurantDetails();
    if (restaurantDetails?.data?.branches != null &&
        restaurantDetails!.data!.branches!.isNotEmpty) {
      final branch = restaurantDetails.data!.branches!.first;
      return branch.thousandSeparator ?? ',';
    }
    return ','; // Default separator
  }

  // Get decimal separator
  static String getDecimalSeparator() {
    final restaurantDetails = getRestaurantDetails();
    if (restaurantDetails?.data?.branches != null &&
        restaurantDetails!.data!.branches!.isNotEmpty) {
      final branch = restaurantDetails.data!.branches!.first;
      return branch.decimalSeparator ?? '.';
    }
    return '.'; // Default separator
  }

  // Get number of decimals
  static int getNoOfDecimals() {
    final restaurantDetails = getRestaurantDetails();
    if (restaurantDetails?.data?.branches != null &&
        restaurantDetails!.data!.branches!.isNotEmpty) {
      final branch = restaurantDetails.data!.branches!.first;
      return branch.noOfDecimal ?? 2;
    }
    return 2; // Default decimals
  }

  // Format price string
  static String formatPrice(String priceString) {
    try {
      final price = double.tryParse(priceString) ?? 0.0;
      return formatPriceFromDouble(price);
    } catch (e) {
      return priceString;
    }
  }

  // Format price from double
  static String formatPriceFromDouble(double price) {
    final currencySymbol = getCurrencySymbol();
    final currencyPosition = getCurrencyPosition();
    final thousandSeparator = getThousandSeparator();
    final decimalSeparator = getDecimalSeparator();
    final noOfDecimals = getNoOfDecimals();

    // Format number with decimals
    String formattedNumber = price.toStringAsFixed(noOfDecimals);

    // Split integer and decimal parts (always use '.' as separator for parsing)
    List<String> parts = formattedNumber.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators
    String formattedInteger = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formattedInteger = thousandSeparator + formattedInteger;
      }
      formattedInteger = integerPart[i] + formattedInteger;
      count++;
    }

    // Combine integer and decimal parts
    String finalNumber =
        decimalPart.isNotEmpty
            ? '$formattedInteger$decimalSeparator$decimalPart'
            : formattedInteger;

    // Add currency symbol based on position
    if (currencyPosition.toLowerCase() == 'after') {
      return '$finalNumber $currencySymbol';
    } else {
      return '$currencySymbol$finalNumber';
    }
  }
}
