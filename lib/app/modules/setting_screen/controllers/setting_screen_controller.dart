import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/menu_items_model.dart';
import '../../../utils/language_utils.dart';
import '../../../routes/app_pages.dart';
import '../../../model/login_models.dart';
import '../../../model/restaurant_details_model.dart';

class SettingScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final isSyncingMenu = false.obs;
  final hapticFeedbackEnabled = true.obs;
  final beepSoundEnabled = true.obs;
  final selectedLanguage = 'en'.obs;
  final isPrinterSectionExpanded = false.obs;
  final branchName = ''.obs;
  final branchLogo = ''.obs;
  final themeHex = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void togglePrinterSection() {
    isPrinterSectionExpanded.value = !isPrinterSectionExpanded.value;
  }

  void _loadSettings() {
    hapticFeedbackEnabled.value =
        box.read(ArgumentConstant.hapticFeedbackKey) ?? true;
    beepSoundEnabled.value = box.read(ArgumentConstant.beepSoundKey) ?? true;
    selectedLanguage.value = LanguageUtils.getLanguage();

    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      
      if (loginModelData != null && loginModelData is Map<String, dynamic> &&
          storedData != null && storedData is Map<String, dynamic>) {
        
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

  Future<void> changeLanguage(String languageCode) async {
    selectedLanguage.value = languageCode;
    box.write(ArgumentConstant.selectedLanguageKey, languageCode);
    await LanguageUtils.updateLocale(languageCode);
  }

  Future<void> syncMenu() async {
    try {
      isSyncingMenu.value = true;

      final response = await networkClient.get(
        ArgumentConstant.menuItemsEndpoint,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        try {
          final itemMenu = ItemMenu.fromJson(
            response.data as Map<String, dynamic>,
          );

          final items = itemMenu.data?.items;
          if (items != null && items.isNotEmpty) {
            final itemsJson = items.map((item) => item.toJson()).toList();
            box.write(ArgumentConstant.menuItemsKey, json.encode(itemsJson));

            isSyncingMenu.value = false;
            AppToast.showSuccess(
              TranslationKeys.menuSyncedSuccessfully.tr,
              title: TranslationKeys.success.tr,
            );
            return;
          }
        } catch (e) {
          // Parse error, continue to show error message
        }
      }

      isSyncingMenu.value = false;
      AppToast.showError(
        TranslationKeys.failedToSyncMenu.tr,
        title: TranslationKeys.error.tr,
      );
    } on ApiException catch (e) {
      isSyncingMenu.value = false;
      AppToast.showError(e.message, title: TranslationKeys.error.tr);
    } catch (e) {
      isSyncingMenu.value = false;
      AppToast.showError(
        TranslationKeys.failedToSyncMenu.tr,
        title: TranslationKeys.error.tr,
      );
    }
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
}
