import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/menuItemsModel.dart';
import '../../../routes/app_pages.dart';

class SettingScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final isSyncingMenu = false.obs;
  final hapticFeedbackEnabled = true.obs;
  final beepSoundEnabled = true.obs;
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
    selectedLanguage.value =
        box.read(ArgumentConstant.selectedLanguageKey) ?? 'en';
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

  void changeLanguage(String languageCode) {
    // Language functionality disabled
  }

  Future<void> syncMenu() async {
    try {
      isSyncingMenu.value = true;

      final response = await networkClient.get(
        ArgumentConstant.menuItemsEndpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          try {
            final itemMenu = ItemMenu.fromJson(
              response.data as Map<String, dynamic>,
            );

            if (itemMenu.data?.items != null &&
                itemMenu.data!.items!.isNotEmpty) {
              final List<Map<String, dynamic>> itemsJson =
                  itemMenu.data!.items!.map((item) => item.toJson()).toList();
              final jsonString = json.encode(itemsJson);
              box.write(ArgumentConstant.menuItemsKey, jsonString);

              isSyncingMenu.value = false;
              safeGetSnackbar(
                'Success',
                'Menu synced successfully',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              return;
            }
          } catch (e) {
            print('Error parsing menu items: $e');
          }
        }
      }

      isSyncingMenu.value = false;
      safeGetSnackbar(
        'Error',
        'Failed to sync menu',
        snackPosition: SnackPosition.TOP,
      );
    } on ApiException catch (e) {
      isSyncingMenu.value = false;
      safeGetSnackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      isSyncingMenu.value = false;
      safeGetSnackbar(
        'Error',
        'Failed to sync menu',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      final response = await networkClient.post(
        ArgumentConstant.logoutEndpoint,
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        networkClient.removeAuthToken();
        box.remove(ArgumentConstant.loginModelKey);
        box.remove(ArgumentConstant.menuItemsKey);
        Get.offAllNamed(Routes.LOGIN_SCREEN);
      }
    } on ApiException catch (e) {
      isLoading.value = false;
      safeGetSnackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      isLoading.value = false;
      networkClient.removeAuthToken();
      box.remove(ArgumentConstant.loginModelKey);
      box.remove(ArgumentConstant.menuItemsKey);
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    }
  }
}
