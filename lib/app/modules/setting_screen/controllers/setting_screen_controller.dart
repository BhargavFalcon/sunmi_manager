import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/menuItemsModel.dart';
import '../../../utils/language_utils.dart';
import '../../../routes/app_pages.dart';

class SettingScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final isSyncingMenu = false.obs;
  final hapticFeedbackEnabled = true.obs;
  final beepSoundEnabled = true.obs;
  final newShopOrderNotificationsEnabled = true.obs;
  final selectedLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    hapticFeedbackEnabled.value =
        box.read(ArgumentConstant.hapticFeedbackKey) ?? true;
    beepSoundEnabled.value = box.read(ArgumentConstant.beepSoundKey) ?? true;
    newShopOrderNotificationsEnabled.value =
        box.read(ArgumentConstant.newShopOrderNotificationsKey) ?? true;
    selectedLanguage.value = LanguageUtils.getLanguage();
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

  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    box.write(ArgumentConstant.selectedLanguageKey, languageCode);
    LanguageUtils.updateLocale(languageCode);
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
            safeGetSnackbar(
              TranslationKeys.success.tr,
              TranslationKeys.menuSyncedSuccessfully.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            return;
          }
        } catch (e) {
          // Parse error, continue to show error message
        }
      }

      isSyncingMenu.value = false;
      safeGetSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.failedToSyncMenu.tr,
        snackPosition: SnackPosition.TOP,
      );
    } on ApiException catch (e) {
      isSyncingMenu.value = false;
      safeGetSnackbar(
        TranslationKeys.error.tr,
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      isSyncingMenu.value = false;
      safeGetSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.failedToSyncMenu.tr,
        snackPosition: SnackPosition.TOP,
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
      safeGetSnackbar(
        TranslationKeys.error.tr,
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      isLoading.value = false;
      _clearUserData();
    }
  }

  void _clearUserData() {
    networkClient.removeAuthToken();
    box.remove(ArgumentConstant.loginModelKey);
    box.remove(ArgumentConstant.menuItemsKey);
    Get.offAllNamed(Routes.LOGIN_SCREEN);
  }
}
