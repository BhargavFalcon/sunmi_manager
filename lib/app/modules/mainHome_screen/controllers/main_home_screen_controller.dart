import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../table_screen/controllers/table_screen_controller.dart';

class MainHomeScreenController extends GetxController {
  final selectedIndex = 0.obs;
  final PageController pageController = PageController(initialPage: 0);

  void changeTab(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
    // Refresh table screen when it becomes active (index 1)
    if (index == 1) {
      try {
        final tableController = Get.find<TableScreenController>();
        tableController.fetchTablesAreas();
      } catch (e) {
        // Controller might not be initialized yet
        print('Table controller not found: $e');
      }
    }
  }
}
