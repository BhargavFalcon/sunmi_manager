import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/pusher_service.dart';
import '../../../data/NetworkClient.dart';
import '../../table_screen/controllers/table_screen_controller.dart';
import '../../cart_screen/controllers/cart_screen_controller.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../model/LoginModels.dart';
import '../../../model/MobileAppModulesModel.dart';
import '../../../model/RestaurantDetailsModel.dart';

class MainHomeScreenController extends GetxController {
  final selectedIndex = 0.obs;
  final PageController pageController = PageController(initialPage: 0);
  int _previousIndex = 0;
  final networkClient = NetworkClient();

  @override
  void onInit() {
    super.onInit();
    _fetchRestaurantDetails();
    _subscribeToPusher();
    _fetchMobileAppModules();
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
        }
      }
    } catch (e) {}
  }

  void changeTab(int index) {
    if (index == 2 && selectedIndex.value != 2) {
      _clearCartIfExists();
    }

    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );

    _previousIndex = index;
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  void onPageChanged(int index) {
    if (index == 2 && _previousIndex != 2) {
      _clearCartIfExists();
    }

    selectedIndex.value = index;

    if (index == 1) {
      try {
        final tableController = Get.find<TableScreenController>();
        tableController.fetchTablesAreas();
      } catch (e) {}
    }

    _previousIndex = index;
  }

  void _clearCartIfExists() {
    try {
      if (Get.isRegistered<CartScreenController>()) {
        final cartController = Get.find<CartScreenController>();
        cartController.clearCart();
      }
    } catch (e) {}
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
              } catch (e) {
                // Handle parsing error
              }
            }
          }
        }
      }
    } catch (e) {
      // Handle error
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
              } catch (e) {
                // Handle parsing error silently
              }
            }
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
