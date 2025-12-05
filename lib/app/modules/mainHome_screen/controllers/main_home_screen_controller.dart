import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/pusher_service.dart';
import '../../table_screen/controllers/table_screen_controller.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../model/LoginModels.dart';

class MainHomeScreenController extends GetxController {
  final selectedIndex = 0.obs;
  final PageController pageController = PageController(initialPage: 0);

  @override
  void onInit() {
    super.onInit();
    _subscribeToPusher();
  }

  Future<void> _subscribeToPusher() async {
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData != null && loginModelData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        final restaurantId = loginModel.data?.user?.restaurantId;
        
        if (restaurantId != null) {
          final pusherService = PusherService();
          await pusherService.subscribeToOrders(restaurantId);
          print('✅ Subscribed to Pusher channel in MainHomeScreen for restaurant: $restaurantId');
        } else {
          print('⚠️ Restaurant ID not found, cannot subscribe to Pusher');
        }
      } else {
        print('⚠️ Login model not found, cannot subscribe to Pusher');
      }
    } catch (e) {
      print('❌ Error subscribing to Pusher channel: $e');
    }
  }

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
