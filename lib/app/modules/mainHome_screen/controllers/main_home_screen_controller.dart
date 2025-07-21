import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  }
}
