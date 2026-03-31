import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/routes/app_pages.dart';
import 'package:managerapp/app/utils/language_utils.dart';

import '../controllers/setting_screen_controller.dart';

class SettingScreenView extends GetWidget<SettingScreenController> {
  const SettingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
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
                padding: EdgeInsets.only(
                  top:
                      MediaQuery.of(context).padding.top + MySize.getHeight(12),
                  left: MySize.getWidth(8),
                  right: MySize.getWidth(8),
                  bottom: MySize.getHeight(12),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: Obx(() {
                  final hasBranchDetails = controller.branchName.value.isNotEmpty;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (controller.branchLogo.value.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(right: MySize.getWidth(12)),
                          height: MySize.getHeight(44),
                          width: MySize.getHeight(44),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: ColorConstants.primaryColor.withValues(alpha: 0.3),
                              width: MySize.getWidth(1.5),
                            ),
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: EdgeInsets.all(MySize.getWidth(2)),
                              child: Image.network(
                                controller.branchLogo.value,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasBranchDetails)
                              Text(
                                controller.branchName.value,
                                style: TextStyle(
                                  fontSize: MySize.getHeight(20),
                                  color: ColorConstants.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(8),
                      vertical: MySize.getHeight(16),
                    ),
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
                        SizedBox(height: MySize.getHeight(8)),
                        Obx(
                          () => _buildLanguageSettingItem(
                            controller: controller,
                            onTap: () {
                              showLanguageDialog(context: context);
                            },
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(8)),
                        Obx(
                          () => _buildToggleSettingItem(
                            icon: Icons.vibration,
                            title: TranslationKeys.hapticFeedback.tr,
                            color: ColorConstants.primaryColor,
                            value: controller.hapticFeedbackEnabled.value,
                            onToggle: () => controller.toggleHapticFeedback(),
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(8)),
                        Obx(
                          () => _buildToggleSettingItem(
                            icon: Icons.volume_up,
                            title: TranslationKeys.beepSound.tr,
                            color: ColorConstants.primaryColor,
                            value: controller.beepSoundEnabled.value,
                            onToggle: () => controller.toggleBeepSound(),
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(8)),
                        _buildSettingItem(
                          icon: Icons.notifications,
                          title: TranslationKeys.manageNotifications.tr,
                          color: ColorConstants.primaryColor,
                          onTap: () {
                            Get.toNamed(Routes.MANAGE_NOTIFICATION_SCREEN);
                          },
                          showArrow: true,
                        ),
                        SizedBox(height: MySize.getHeight(8)),
                        _buildSettingItem(
                          icon: Icons.storefront,
                          title: TranslationKeys.shopControls.tr,
                          color: ColorConstants.primaryColor,
                          onTap: () {
                            Get.toNamed(Routes.SHOP_CONTROLS_SCREEN);
                          },
                          showArrow: true,
                        ),
                        SizedBox(height: MySize.getHeight(8)),
                        Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(14),
                              ),
                              border: Border.all(
                                color: ColorConstants.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                width: MySize.getWidth(1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: MySize.getWidth(6),
                                  offset: Offset(0, MySize.getHeight(2)),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildSettingItemNoCard(
                                  icon: Icons.print,
                                  title: TranslationKeys.printerSettings.tr,
                                  color: ColorConstants.primaryColor,
                                  onTap:
                                      () => controller.togglePrinterSection(),
                                  showArrow: true,
                                  isExpanded:
                                      controller.isPrinterSectionExpanded.value,
                                ),
                                if (controller
                                    .isPrinterSectionExpanded
                                    .value) ...[
                                  Divider(
                                    height: 1,
                                    color: ColorConstants.primaryColor
                                        .withValues(alpha: 0.1),
                                    indent: MySize.getWidth(10),
                                    endIndent: MySize.getWidth(10),
                                  ),
                                  _buildSettingItemNoCardIndented(
                                    title: TranslationKeys.managePrinters.tr,
                                    color: ColorConstants.primaryColor,
                                    onTap: () {
                                      Get.toNamed(Routes.MANAGE_PRINTER_SCREEN);
                                    },
                                  ),
                                  Divider(
                                    height: 1,
                                    color: ColorConstants.primaryColor
                                        .withValues(alpha: 0.1),
                                    indent: MySize.getWidth(10),
                                    endIndent: MySize.getWidth(10),
                                  ),
                                  _buildSettingItemNoCardIndented(
                                    title: TranslationKeys.printService.tr,
                                    color: ColorConstants.primaryColor,
                                    onTap: () {
                                      Get.toNamed(Routes.PRINT_SERVICE);
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(8)),
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
              borderRadius: BorderRadius.circular(MySize.getHeight(12)),
              side: BorderSide(color: ColorConstants.bgColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(MySize.getWidth(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.logout.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(12)),
                  Text(
                    TranslationKeys.areYouSureLogout.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MySize.getHeight(14),
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(24)),
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
                            padding: EdgeInsets.symmetric(
                              vertical: MySize.getHeight(12),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                TranslationKeys.cancel.tr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: MySize.getHeight(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MySize.getWidth(12)),
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
                            padding: EdgeInsets.symmetric(
                              vertical: MySize.getHeight(12),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  controller.isLoading.value
                                      ? Colors.grey
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(8),
                              ),
                            ),
                            child: Center(
                              child:
                                  controller.isLoading.value
                                      ? SizedBox(
                                        width: MySize.getHeight(20),
                                        height: MySize.getHeight(20),
                                        child: CircularProgressIndicator(
                                          strokeWidth: MySize.getWidth(2),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        TranslationKeys.logout.tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MySize.getHeight(14),
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
              borderRadius: BorderRadius.circular(MySize.getHeight(12)),
              side: BorderSide(color: ColorConstants.bgColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(MySize.getWidth(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.syncMenu.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(12)),
                  Text(
                    TranslationKeys.syncMenuMessage.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MySize.getHeight(14),
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(24)),
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
                            padding: EdgeInsets.symmetric(
                              vertical: MySize.getHeight(12),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                TranslationKeys.cancel.tr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: MySize.getHeight(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MySize.getWidth(12)),
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
                            padding: EdgeInsets.symmetric(
                              vertical: MySize.getHeight(12),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  controller.isSyncingMenu.value
                                      ? Colors.grey
                                      : ColorConstants.primaryColor,
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(8),
                              ),
                            ),
                            child: Center(
                              child:
                                  controller.isSyncingMenu.value
                                      ? SizedBox(
                                        width: MySize.getHeight(20),
                                        height: MySize.getHeight(20),
                                        child: CircularProgressIndicator(
                                          strokeWidth: MySize.getWidth(2),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        TranslationKeys.sync.tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MySize.getHeight(14),
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
        borderRadius: BorderRadius.circular(MySize.getHeight(16)),
        child: Container(
          height: MySize.getHeight(50),
          padding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(10),
            vertical: MySize.getHeight(6),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MySize.getHeight(14)),
            border: Border.all(
              color: ColorConstants.primaryColor.withValues(alpha: 0.2),
              width: MySize.getWidth(1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: MySize.getWidth(6),
                offset: Offset(0, MySize.getHeight(2)),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(MySize.getHeight(6)),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
                child: Icon(
                  Icons.language,
                  color: ColorConstants.primaryColor,
                  size: MySize.getHeight(24),
                ),
              ),
              SizedBox(width: MySize.getWidth(12)),
              Expanded(
                child: Text(
                  languageName,
                  style: TextStyle(
                    fontSize: MySize.getHeight(12),
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(flagEmoji, style: TextStyle(fontSize: MySize.getHeight(18))),
              SizedBox(width: MySize.getWidth(8)),
              Icon(
                Icons.arrow_forward_ios,
                size: MySize.getHeight(14),
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
            borderRadius: BorderRadius.circular(MySize.getHeight(12)),
            side: BorderSide(color: ColorConstants.bgColor),
          ),
          child: Padding(
            padding: EdgeInsets.all(MySize.getWidth(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TranslationKeys.selectLanguage.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: MySize.getHeight(16)),
                ...languages.map(
                  (lang) => Obx(
                    () => InkWell(
                      onTap: () {
                        controller.changeLanguage(lang['code']!);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(16),
                          vertical: MySize.getHeight(8),
                        ),
                        margin: EdgeInsets.only(bottom: MySize.getHeight(8)),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedLanguage.value == lang['code']
                                  ? ColorConstants.primaryColor.withValues(
                                    alpha: 0.1,
                                  )
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          border: Border.all(
                            color:
                                controller.selectedLanguage.value ==
                                        lang['code']
                                    ? ColorConstants.primaryColor
                                    : Colors.transparent,
                            width: MySize.getWidth(1.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              LanguageUtils.getFlagEmoji(lang['code']!),
                              style: TextStyle(fontSize: MySize.getHeight(18)),
                            ),
                            SizedBox(width: MySize.getWidth(12)),
                            Expanded(
                              child: Text(
                                lang['name']!,
                                style: TextStyle(
                                  fontSize: MySize.getHeight(14),
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
                                size: MySize.getHeight(18),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MySize.getHeight(8)),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: MySize.getHeight(12),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    ),
                    child: Center(
                      child: Text(
                        TranslationKeys.close.tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MySize.getHeight(14),
                        ),
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
        borderRadius: BorderRadius.circular(MySize.getHeight(16)),
        child: Container(
          height: MySize.getHeight(50),
          padding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(10),
            vertical: MySize.getHeight(6),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MySize.getHeight(14)),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: MySize.getWidth(1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: MySize.getWidth(6),
                offset: Offset(0, MySize.getHeight(2)),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(MySize.getHeight(6)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
                child: Icon(icon, color: color, size: MySize.getHeight(24)),
              ),
              SizedBox(width: MySize.getWidth(12)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: MySize.getHeight(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: color.withValues(alpha: 0.6),
                  size: MySize.getHeight(14),
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
        borderRadius: BorderRadius.circular(MySize.getHeight(16)),
        child: Container(
          height: MySize.getHeight(50),
          padding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(10),
            vertical: MySize.getHeight(6),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MySize.getHeight(14)),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: MySize.getWidth(1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: MySize.getWidth(6),
                offset: Offset(0, MySize.getHeight(2)),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(MySize.getHeight(6)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
                child: Icon(icon, color: color, size: MySize.getHeight(24)),
              ),
              SizedBox(width: MySize.getWidth(12)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: MySize.getHeight(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isLoading)
                CupertinoActivityIndicator(
                  radius: MySize.getHeight(8),
                  color: color,
                )
              else if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: color.withValues(alpha: 0.6),
                  size: MySize.getHeight(14),
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
        borderRadius: BorderRadius.circular(MySize.getHeight(16)),
        child: Container(
          height: MySize.getHeight(50),
          padding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(10),
            vertical: MySize.getHeight(6),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MySize.getHeight(14)),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: MySize.getWidth(1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: MySize.getWidth(6),
                offset: Offset(0, MySize.getHeight(2)),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(MySize.getHeight(6)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
                child: Icon(icon, color: color, size: MySize.getHeight(24)),
              ),
              SizedBox(width: MySize.getWidth(12)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: MySize.getHeight(12),
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

  Widget _buildSettingItemNoCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool showArrow,
    bool isExpanded = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: MySize.getHeight(50),
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(10),
          vertical: MySize.getHeight(6),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(MySize.getHeight(6)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MySize.getHeight(8)),
              ),
              child: Icon(icon, color: color, size: MySize.getHeight(24)),
            ),
            SizedBox(width: MySize.getWidth(12)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: MySize.getHeight(12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: color.withValues(alpha: 0.6),
                size: MySize.getHeight(18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemNoCardIndented({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: MySize.getHeight(50),
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(10),
          vertical: MySize.getHeight(6),
        ),
        child: Row(
          children: [
            SizedBox(
              width: MySize.getWidth(42),
            ), // Indent to align with text above
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: MySize.getHeight(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withValues(alpha: 0.6),
              size: MySize.getHeight(14),
            ),
          ],
        ),
      ),
    );
  }
}
