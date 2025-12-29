import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/routes/app_pages.dart';
import 'package:managerapp/app/utils/language_utils.dart';

import '../controllers/setting_screen_controller.dart';

class SettingScreenView extends GetWidget<SettingScreenController> {
  const SettingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingScreenController>(
      init: SettingScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  12,
                ).copyWith(top: MediaQuery.of(context).padding.top + 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: Center(
                  child: Text(
                    TranslationKeys.setting.tr,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => _buildSettingItemWithLoader(
                            icon: Icons.sync,
                            title: TranslationKeys.syncMenu.tr,
                            color: ColorConstants.primaryColor,
                            onTap: () {
                              showSyncMenuDialog(context: context);
                            },
                            showArrow: false,
                            isLoading: controller.isSyncingMenu.value,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => _buildLanguageSettingItem(
                            controller: controller,
                            onTap: () {
                              showLanguageDialog(context: context);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => _buildToggleSettingItem(
                            icon: Icons.vibration,
                            title: TranslationKeys.hapticFeedback.tr,
                            color: ColorConstants.primaryColor,
                            value: controller.hapticFeedbackEnabled.value,
                            onToggle: () => controller.toggleHapticFeedback(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => _buildToggleSettingItem(
                            icon: Icons.volume_up,
                            title: TranslationKeys.beepSound.tr,
                            color: ColorConstants.primaryColor,
                            value: controller.beepSoundEnabled.value,
                            onToggle: () => controller.toggleBeepSound(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => _buildToggleSettingItem(
                            icon: Icons.notifications,
                            title: TranslationKeys.newShopOrderNotifications.tr,
                            color: ColorConstants.primaryColor,
                            value:
                                controller
                                    .newShopOrderNotificationsEnabled
                                    .value,
                            onToggle:
                                () =>
                                    controller
                                        .toggleNewShopOrderNotifications(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSettingItem(
                          icon: Icons.print,
                          title: TranslationKeys.printerSettings.tr,
                          color: ColorConstants.primaryColor,
                          onTap: () {
                            Get.toNamed(Routes.PRINTER_SCREEN);
                          },
                          showArrow: true,
                        ),
                        const SizedBox(height: 8),
                        _buildSettingItem(
                          icon: Icons.power_settings_new_sharp,
                          title: TranslationKeys.logout.tr,
                          color: Colors.red,
                          onTap: () {
                            showLogoutDialog(context: context);
                          },
                          showArrow: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showLogoutDialog({required BuildContext context}) {
    final controller = Get.find<SettingScreenController>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Obx(
          () => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: ColorConstants.bgColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.logout.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    TranslationKeys.areYouSureLogout.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap:
                              controller.isLoading.value
                                  ? null
                                  : () {
                                    Navigator.of(context).pop();
                                  },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                TranslationKeys.cancel.tr,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap:
                              controller.isLoading.value
                                  ? null
                                  : () {
                                    Navigator.of(context).pop();
                                    controller.logout();
                                  },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  controller.isLoading.value
                                      ? Colors.grey
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child:
                                  controller.isLoading.value
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        TranslationKeys.logout.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSyncMenuDialog({required BuildContext context}) {
    final controller = Get.find<SettingScreenController>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Obx(
          () => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: ColorConstants.bgColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.syncMenu.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    TranslationKeys.syncMenuMessage.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap:
                              controller.isSyncingMenu.value
                                  ? null
                                  : () {
                                    Navigator.of(context).pop();
                                  },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                TranslationKeys.cancel.tr,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap:
                              controller.isSyncingMenu.value
                                  ? null
                                  : () {
                                    Navigator.of(context).pop();
                                    controller.syncMenu();
                                  },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  controller.isSyncingMenu.value
                                      ? Colors.grey
                                      : ColorConstants.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child:
                                  controller.isSyncingMenu.value
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        TranslationKeys.sync.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSettingItem({
    required SettingScreenController controller,
    required VoidCallback onTap,
  }) {
    final currentLanguage = controller.selectedLanguage.value;
    final flagEmoji = LanguageUtils.getFlagEmoji(currentLanguage);
    final languageName = LanguageUtils.getLanguageName(currentLanguage);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ColorConstants.primaryColor.withValues(alpha: 0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.language,
                  color: ColorConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  languageName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(flagEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLanguageDialog({required BuildContext context}) {
    final controller = Get.find<SettingScreenController>();
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'nl', 'name': 'Nederlands'},
      {'code': 'da', 'name': 'Dansk'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ColorConstants.bgColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TranslationKeys.selectLanguage.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...languages.map(
                  (lang) => Obx(
                    () => InkWell(
                      onTap: () {
                        controller.changeLanguage(lang['code']!);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedLanguage.value == lang['code']
                                  ? ColorConstants.primaryColor.withValues(
                                    alpha: 0.1,
                                  )
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                controller.selectedLanguage.value ==
                                        lang['code']
                                    ? ColorConstants.primaryColor
                                    : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              LanguageUtils.getFlagEmoji(lang['code']!),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lang['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      controller.selectedLanguage.value ==
                                              lang['code']
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      controller.selectedLanguage.value ==
                                              lang['code']
                                          ? ColorConstants.primaryColor
                                          : Colors.black87,
                                ),
                              ),
                            ),
                            if (controller.selectedLanguage.value ==
                                lang['code'])
                              Icon(
                                Icons.check,
                                color: ColorConstants.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        TranslationKeys.close.tr,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool showArrow,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: color.withValues(alpha: 0.6),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItemWithLoader({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool showArrow,
    required bool isLoading,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isLoading)
                CupertinoActivityIndicator(radius: 8, color: color)
              else if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: color.withValues(alpha: 0.6),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSettingItem({
    required IconData icon,
    required String title,
    required Color color,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: (_) => onToggle(),
                activeThumbColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
