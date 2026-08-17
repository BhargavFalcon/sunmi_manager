import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/pusher_service.dart';
import '../../../data/NetworkClient.dart';
import '../../order_screen/controllers/order_screen_controller.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../model/login_models.dart';
import '../../../model/mobile_app_modules_model.dart';
import '../../../model/restaurant_details_model.dart';
import '../../../services/printer_service.dart';

class MainHomeScreenController extends GetxController {
  final selectedIndex = 0.obs;
  final PageController pageController = PageController(initialPage: 0);
  final networkClient = NetworkClient();

  @override
  void onInit() {
    super.onInit();
    _fetchRestaurantDetails();
    _subscribeToPusher();
    _fetchMobileAppModules();

    // Ensure printer settings are loaded
    Future.delayed(const Duration(seconds: 3), () {
      try {
        if (Get.isRegistered<PrinterService>()) {
          Get.find<PrinterService>().loadGeneralSettings();
        }
      } catch (_) {}
    });
  }

  Future<void> _subscribeToPusher() async {
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData != null && loginModelData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        final branchId = loginModel.data?.user?.branchId;

        if (branchId != null) {
          final pusherService = Get.find<PusherService>();
          await pusherService.subscribeToOrders(branchId);
        }
      }
    } catch (_) {
      // Pusher subscribe failed
    }
  }

  void changeTab(int index) {
    _performTabChange(index);
  }

  void _performTabChange(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );

    // Refresh data when switching to All Orders (index 0)
    if (index == 0) {
      try {
        if (Get.isRegistered<OrderScreenController>()) {
          Get.find<OrderScreenController>().fetchAllOrders();
        }
      } catch (_) {}
    }
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;

    if (index == 0) {
      try {
        if (Get.isRegistered<OrderScreenController>()) {
          final orderController = Get.find<OrderScreenController>();
          orderController.fetchAllOrders();
        }
      } catch (_) {}
    }
  }

  Future<void> _fetchMobileAppModules() async {
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData != null && loginModelData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        final restaurantId = loginModel.data?.user?.restaurantId;

        if (restaurantId != null) {
          final endpoint = ArgumentConstant.mobileAppModulesEndpoint.replaceAll(
            ':restaurant_id',
            restaurantId.toString(),
          );

          final response = await networkClient.get(endpoint);

          if (response.statusCode == 200 || response.statusCode == 201) {
            if (response.data != null &&
                response.data is Map<String, dynamic>) {
              try {
                final modulesModel = MobileAppModulesModel.fromJson(
                  response.data as Map<String, dynamic>,
                );
                box.write(
                  ArgumentConstant.mobileAppModulesKey,
                  modulesModel.toJson(),
                );
              } catch (_) {
                // Module parse/store failed
              }
            }
          }
        }
      }
    } catch (_) {
      // Mobile app modules fetch failed
    }
  }

  Future<void> _fetchRestaurantDetails() async {
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData != null && loginModelData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        final restaurantId = loginModel.data?.user?.restaurantId;

        if (restaurantId != null) {
          final endpoint = ArgumentConstant.restaurantDetailsEndpoint
              .replaceAll(':restaurant_id', restaurantId.toString());

          final response = await networkClient.get(endpoint);

          if (response.statusCode == 200 || response.statusCode == 201) {
            if (response.data != null &&
                response.data is Map<String, dynamic>) {
              try {
                final restaurantModel = RestaurantModel.fromJson(
                  response.data as Map<String, dynamic>,
                );
                box.write(
                  ArgumentConstant.restaurantDetailsKey,
                  restaurantModel.toJson(),
                );
              } catch (_) {
                // Restaurant model parse/store failed
              }
            }
          }
        }
      }
    } catch (_) {
      // Restaurant details fetch failed
    }
  }
}
