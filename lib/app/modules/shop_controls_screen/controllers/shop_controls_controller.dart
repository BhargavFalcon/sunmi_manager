import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../widgets/app_toast.dart';
import '../../../utils/currency_formatter.dart';

class ShopControlsController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Currency settings
  final currencySymbol = "€".obs;
  final currencyPosition = "before".obs;
  final decimalSeparator = ".".obs;

  // Form fields
  final acceptNewOrders = true.obs;
  final enableScheduleForLater = true.obs;

  final minOrderAmountController = TextEditingController();
  final deliveryFeeController = TextEditingController();
  final freeDeliveryAmountController = TextEditingController();

  @override
  void onInit() {
    fetchCurrencySettings();
    fetchShopSettings();
    super.onInit();
  }

  void fetchCurrencySettings() {
    currencySymbol.value = CurrencyFormatter.getCurrencySymbol();
    currencyPosition.value = CurrencyFormatter.getCurrencyPosition();
    decimalSeparator.value = CurrencyFormatter.getDecimalSeparator();
  }

  String _formatForField(dynamic value) {
    if (value == null) return "0${decimalSeparator.value}00";
    double doubleVal = 0.0;
    if (value is String) {
      doubleVal = double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      doubleVal = value.toDouble();
    }

    String formatted = doubleVal.toStringAsFixed(
      CurrencyFormatter.getNoOfDecimals(),
    );
    if (decimalSeparator.value != ".") {
      formatted = formatted.replaceFirst(".", decimalSeparator.value);
    }
    return formatted;
  }

  double _parseFromField(String text) {
    if (text.isEmpty) return 0.0;
    String normalized = text;
    if (decimalSeparator.value != ".") {
      normalized = normalized.replaceFirst(decimalSeparator.value, ".");
    }
    // Remove any non-numeric characters except the decimal point
    normalized = normalized.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0.0;
  }

  @override
  void onClose() {
    minOrderAmountController.dispose();
    deliveryFeeController.dispose();
    freeDeliveryAmountController.dispose();
    super.onClose();
  }

  Future<void> fetchShopSettings() async {
    try {
      isLoading.value = true;
      final response = await networkClient.get(
        ArgumentConstant.shopSettingsEndpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data != null) {
          acceptNewOrders.value =
              data[ArgumentConstant.shopAcceptNewOrdersKey] ?? true;
          enableScheduleForLater.value =
              data[ArgumentConstant.shopEnableScheduleForLaterKey] ?? true;
          minOrderAmountController.text = _formatForField(
            data[ArgumentConstant.shopMinOrderAmountKey],
          );
          deliveryFeeController.text = _formatForField(
            data[ArgumentConstant.shopDeliveryFeeKey],
          );
          freeDeliveryAmountController.text = _formatForField(
            data[ArgumentConstant.shopFreeDeliveryAmountKey],
          );
        }
      }
    } catch (e) {
      AppToast.showError("Failed to fetch shop settings");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    try {
      isSaving.value = true;

      final data = {
        ArgumentConstant.shopAcceptNewOrdersKey: acceptNewOrders.value,
        ArgumentConstant.shopEnableScheduleForLaterKey:
            enableScheduleForLater.value,
        ArgumentConstant.shopMinOrderAmountKey: _parseFromField(
          minOrderAmountController.text,
        ),
        ArgumentConstant.shopDeliveryFeeKey: _parseFromField(
          deliveryFeeController.text,
        ),
        ArgumentConstant.shopFreeDeliveryAmountKey: _parseFromField(
          freeDeliveryAmountController.text,
        ),
      };

      final response = await networkClient.post(
        ArgumentConstant.shopSettingsEndpoint,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.showSuccess(TranslationKeys.success.tr);
        Get.back();
      } else {
        AppToast.showError("Failed to save settings");
      }
    } catch (e) {
      AppToast.showError("Failed to save settings");
    } finally {
      isSaving.value = false;
    }
  }
}
