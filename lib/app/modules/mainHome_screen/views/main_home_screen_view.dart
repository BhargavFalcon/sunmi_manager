import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/modules/order_screen/views/order_screen_view.dart';
import 'package:managerapp/app/modules/setting_screen/views/setting_screen_view.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/image_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../constants/translation_keys.dart';
import '../controllers/main_home_screen_controller.dart';

class MainHomeScreenView extends GetWidget<MainHomeScreenController> {
  const MainHomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        children: [
          OrderScreenView(),
          SettingScreenView(),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                spreadRadius: 0,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: _CustomBottomNavBar(
            selectedIndex: controller.selectedIndex.value,
            onTabChange: (index) {
              controller.changeTab(index);
            },
          ),
        );
      }),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const _CustomBottomNavBar({
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MySize.getHeight(68),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Divider for clean separation
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            Expanded(
              child: Stack(
                children: [
                  // Selection Indicator Line (Top)
                  Row(
                    children: [
                      _IndicatorLine(isSelected: selectedIndex == 0),
                      _IndicatorLine(isSelected: selectedIndex == 1),
                    ],
                  ),
                  // Icons and Labels with more breathing room from the top
                  Padding(
                    padding: EdgeInsets.only(top: MySize.getHeight(12)),
                    child: Row(
                      children: [
                        _FullWidthNavItem(
                          icon: ImageConstant.order,
                          label: TranslationKeys.allOrders.tr,
                          isSelected: selectedIndex == 0,
                          onTap: () => onTabChange(0),
                        ),
                        _FullWidthNavItem(
                          icon: ImageConstant.setting,
                          label: TranslationKeys.settings.tr,
                          isSelected: selectedIndex == 1,
                          onTap: () => onTabChange(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorLine extends StatelessWidget {
  final bool isSelected;
  const _IndicatorLine({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isSelected ? 1 : 0,
        child: Container(
          height: 3,
          margin: EdgeInsets.symmetric(horizontal: MySize.getWidth(40)),
          decoration: BoxDecoration(
            color: ColorConstants.primaryColor,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
          ),
        ),
      ),
    );
  }
}

class _FullWidthNavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FullWidthNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: ColorConstants.primaryColor.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: MySize.getHeight(22),
              color: isSelected ? ColorConstants.primaryColor : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: MySize.getHeight(13),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? ColorConstants.primaryColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
