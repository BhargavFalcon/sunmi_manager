import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/modules/dashboard_screen/views/dashboard_screen_view.dart';
import 'package:managerapp/app/modules/order_screen/views/order_screen_view.dart';
import 'package:managerapp/app/modules/reservation_screen/views/reservation_screen_view.dart';
import 'package:managerapp/app/modules/setting_screen/views/setting_screen_view.dart';
import 'package:managerapp/app/modules/table_screen/views/table_screen_view.dart';
import 'package:managerapp/app/modules/take_order_screen/views/take_order_view.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/image_constants.dart';
import '../../../constants/sizeConstant.dart';
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
          // DashboardScreenView(),
          OrderScreenView(),
          TableScreenView(),
          TakeOrderView(),
          ReservationScreenView(),
          SettingScreenView(),
          // InventoryScreenView(),
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
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              Platform.isAndroid
                  ? MediaQuery.of(context).padding.bottom
                  : MySize.getHeight(0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // _NavBarItem(
                  //   icon: ImageConstant.dashboard,
                  //   label: "Home",
                  //   isSelected: selectedIndex == 0,
                  //   onTap: () => onTabChange(0),
                  // ),
                  _NavBarItem(
                    icon: ImageConstant.order,
                    label: "All Orders",
                    isSelected: selectedIndex == 0,
                    onTap: () => onTabChange(0),
                  ),
                  _NavBarItem(
                    icon: ImageConstant.table,
                    label: "Dine In",
                    isSelected: selectedIndex == 1,
                    onTap: () => onTabChange(1),
                  ),
                  _NavBarItem(
                    icon: ImageConstant.takeOrder,
                    label: "Take Order",
                    isSelected: selectedIndex == 2,
                    onTap: () => onTabChange(2),
                  ),
                  _NavBarItem(
                    icon: ImageConstant.tableReservation,
                    label: "Reservation",
                    isSelected: selectedIndex == 3,
                    onTap: () => onTabChange(3),
                  ),
                  _NavBarItem(
                    icon: ImageConstant.setting,
                    label: "Settings",
                    isSelected: selectedIndex == 4,
                    onTap: () => onTabChange(4),
                  ),
                  // _NavBarItem(
                  //   icon: ImageConstant.inventory,
                  //   label: "Inventory",
                  //   isSelected: selectedIndex == 3,
                  //   onTap: () => onTabChange(3),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.3, 1.0)));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withValues(
                alpha: 0.1 * _backgroundAnimation.value,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorConstants.primaryColor.withValues(
                  alpha: _backgroundAnimation.value,
                ),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    widget.icon,
                    height: MySize.getHeight(20),
                    color: Color.lerp(
                      Colors.grey[600]!,
                      ColorConstants.primaryColor,
                      _backgroundAnimation.value,
                    ),
                  ),
                ),
                SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
