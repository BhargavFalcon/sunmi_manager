import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../utils/language_utils.dart';
import '../../../routes/app_pages.dart';
import '../../../model/login_models.dart';
import '../../../model/restaurant_details_model.dart';
import '../../../utils/currency_formatter.dart';

class SettingScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final hapticFeedbackEnabled = true.obs;
  final beepSoundEnabled = true.obs;
  final selectedLanguage = 'en'.obs;
  final branchName = ''.obs;
  final branchLogo = ''.obs;
  final themeHex = ''.obs;
  final newShopOrderNotificationsEnabled = true.obs;
  final isShopSettingsExpanded = false.obs;

  // Shop Settings Fields
  final isShopSettingsLoading = false.obs;
  final isSavingShopSettings = false.obs;
  final acceptNewOrders = true.obs;
  final enableScheduleForLater = true.obs;
  final minOrderAmountController = TextEditingController();
  final deliveryFeeController = TextEditingController();
  final freeDeliveryAmountController = TextEditingController();

  // Currency settings
  final decimalSeparator = ".".obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _fetchShopSettings();
  }

  void _loadSettings() {
    hapticFeedbackEnabled.value =
        box.read(ArgumentConstant.hapticFeedbackKey) ?? true;
    beepSoundEnabled.value = box.read(ArgumentConstant.beepSoundKey) ?? true;
    selectedLanguage.value = LanguageUtils.getLanguage();
    newShopOrderNotificationsEnabled.value =
        box.read(ArgumentConstant.newShopOrderNotificationsKey) ?? true;
    decimalSeparator.value = CurrencyFormatter.getDecimalSeparator();

    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);

      if (loginModelData != null &&
          loginModelData is Map<String, dynamic> &&
          storedData != null &&
          storedData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        final restaurantModel = RestaurantModel.fromJson(storedData);
        final branchId = loginModel.data?.user?.branchId;

        if (branchId != null) {
          final branches = restaurantModel.data?.branches;
          if (branches != null) {
            Branches? currentBranch;
            for (var b in branches) {
              if (b.id == branchId) {
                currentBranch = b;
                break;
              }
            }
            if (currentBranch != null) {
              branchName.value = currentBranch.name ?? '';
              branchLogo.value = currentBranch.logo ?? '';
              themeHex.value = currentBranch.themeHex ?? '';
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchShopSettings() async {
    try {
      isShopSettingsLoading.value = true;
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
    } catch (_) {
      // Silently fail or show warning
    } finally {
      isShopSettingsLoading.value = false;
    }
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
    normalized = normalized.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0.0;
  }

  Future<void> saveShopSettings() async {
    try {
      isSavingShopSettings.value = true;

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
      } else {
        AppToast.showError(TranslationKeys.error.tr);
      }
    } catch (e) {
      AppToast.showError(TranslationKeys.error.tr);
    } finally {
      isSavingShopSettings.value = false;
    }
  }

  void toggleHapticFeedback() {
    hapticFeedbackEnabled.value = !hapticFeedbackEnabled.value;
    box.write(ArgumentConstant.hapticFeedbackKey, hapticFeedbackEnabled.value);
    if (hapticFeedbackEnabled.value) {
      HapticFeedback.lightImpact();
    }
  }

  void toggleBeepSound() {
    beepSoundEnabled.value = !beepSoundEnabled.value;
    box.write(ArgumentConstant.beepSoundKey, beepSoundEnabled.value);
  }

  void toggleNewShopOrderNotifications() {
    newShopOrderNotificationsEnabled.value =
        !newShopOrderNotificationsEnabled.value;
    box.write(
      ArgumentConstant.newShopOrderNotificationsKey,
      newShopOrderNotificationsEnabled.value,
    );
  }

  Future<void> changeLanguage(String languageCode) async {
    selectedLanguage.value = languageCode;
    box.write(ArgumentConstant.selectedLanguageKey, languageCode);
    await LanguageUtils.updateLocale(languageCode);
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await networkClient.post(ArgumentConstant.logoutEndpoint);
      _clearUserData();
    } on ApiException catch (e) {
      isLoading.value = false;
      AppToast.showError(e.message, title: TranslationKeys.error.tr);
    } catch (e) {
      isLoading.value = false;
      _clearUserData();
    }
  }

  void _clearUserData() {
    networkClient.removeAuthToken();
    box.erase();
    Get.offAllNamed(Routes.LOGIN_SCREEN);
  }

  @override
  void onClose() {
    minOrderAmountController.dispose();
    deliveryFeeController.dispose();
    freeDeliveryAmountController.dispose();
    super.onClose();
  }
}
