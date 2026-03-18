import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:get/get.dart';
import '../../../data/pusher_service.dart';
import '../../../data/NetworkClient.dart';
import '../../order_screen/controllers/order_screen_controller.dart';
import '../../table_screen/controllers/table_screen_controller.dart';
import '../../cart_screen/controllers/cart_screen_controller.dart';
import '../../take_order_screen/controllers/take_order_controller.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/translation_keys.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/sizeConstant.dart';
import '../../../model/login_models.dart';
import '../../../model/mobile_app_modules_model.dart';
import '../../../model/restaurant_details_model.dart';
import '../../../services/printer_service.dart';

class MainHomeScreenController extends GetxController {
  final selectedIndex = 0.obs;
  final PageController pageController = PageController(initialPage: 0);
  int _previousIndex = 0;
  final networkClient = NetworkClient();
  
  // Ready items state: tableId -> { "items": List, "time": String }
  final readyTables = <int, Map<String, dynamic>>{}.obs;
  
  // New KOT pulse state
  final hasNewKotPulse = false.obs;

  void addReadyItems(int tableId, List<Map<String, dynamic>> items, String time, {String? tableLabel}) {
    log('[MainController] addReadyItems for table $tableId ($tableLabel), new items: ${items.length}');
    
    // As per user request: "baki pehleka deta remove kar dena he" (remove previous data)
    // We overwrite the state for this table with the latest ready items from the notification.
    readyTables[tableId] = {
      'items': items,
      'time': time,
      'tableLabel': tableLabel,
    };
    
    readyTables.refresh();
  }

  void clearTableReadyState(int tableId) {
    log('[MainController] clearTableReadyState for table $tableId');
    readyTables.remove(tableId);
  }

  bool isTableReady(int tableId) {
    return readyTables.containsKey(tableId);
  }

  bool isAreaReady(List<dynamic>? tables) {
    if (tables == null || tables.isEmpty) return false;
    return tables.any((table) => readyTables.containsKey(table.id));
  }

  bool hasAnyReadyTable() {
    return readyTables.isNotEmpty;
  }

  void clearNewKotPulse() {
    hasNewKotPulse.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    _fetchRestaurantDetails();
    _subscribeToPusher();
    _fetchMobileAppModules();

    // Ensure printer auto-connection is triggered
    Future.delayed(const Duration(seconds: 3), () {
      try {
        if (Get.isRegistered<PrinterService>()) {
          Get.find<PrinterService>().checkConnection();
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
          final pusherService = PusherService();
          await pusherService.subscribeToOrders(branchId);
        }
      }
    } catch (_) {
      // Pusher subscribe failed
    }
  }

  void changeTab(int index) {
    if (index == 3) {
      clearNewKotPulse();
    }
    if (selectedIndex.value == 2 && index != 2 && _hasCartItems()) {
      _showNavigationConfirmationDialog(index);
      return;
    }

    _performTabChange(index);
  }

  bool _hasCartItems() {
    try {
      return Get.isRegistered<CartScreenController>() &&
          Get.find<CartScreenController>().cartItems.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void _showNavigationConfirmationDialog(int targetIndex) {
    Get.dialog(
      Dialog(
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
                TranslationKeys.warning.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                TranslationKeys.areYouSureExit.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: MySize.getHeight(12)),
              ),
              SizedBox(height: MySize.getHeight(20)),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        TranslationKeys.cancel.tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MySize.getHeight(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        _clearCartIfExists();
                        _performTabChange(targetIndex);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: ColorConstants.primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: MySize.getHeight(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        TranslationKeys.confirm.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MySize.getHeight(14),
                          fontWeight: FontWeight.w600,
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
      barrierDismissible: false,
    );
  }

  void _performTabChange(int index) {
    if (index == 2 && selectedIndex.value != 2) {
      _clearCartIfExists();
      _resetTakeOrderForNewOrder();
    }

    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );

    _previousIndex = index;

    // Refresh data when switching to All Orders or Dine In (e.g. when returning from cart/order update)
    if (index == 0) {
      try {
        if (Get.isRegistered<OrderScreenController>()) {
          Get.find<OrderScreenController>().fetchAllOrders();
        }
      } catch (_) {
        // OrderScreenController not registered
      }
    } else if (index == 1) {
      try {
        if (Get.isRegistered<TableScreenController>()) {
          Get.find<TableScreenController>().fetchTablesAreas();
        }
      } catch (_) {
        // TableScreenController not registered
      }
    }
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  void onPageChanged(int index) {
    if (index == 2 && _previousIndex != 2) {
      _clearCartIfExists();
      _resetTakeOrderForNewOrder();
    }

    selectedIndex.value = index;

    if (index == 0) {
      try {
        if (Get.isRegistered<OrderScreenController>()) {
          final orderController = Get.find<OrderScreenController>();
          orderController.fetchAllOrders();
        }
      } catch (_) {
        // OrderScreenController not registered
      }
    } else if (index == 1) {
      try {
        final tableController = Get.find<TableScreenController>();
        tableController.fetchTablesAreas();
      } catch (_) {
        // TableScreenController not registered
      }
    }

    _previousIndex = index;
  }

  void _clearCartIfExists() {
    try {
      if (Get.isRegistered<CartScreenController>()) {
        final cartController = Get.find<CartScreenController>();
        cartController.clearCart();
      }
    } catch (_) {
      // Controller not registered or already disposed
    }
  }

  void _resetTakeOrderForNewOrder() {
    try {
      if (Get.isRegistered<TakeOrderController>()) {
        Get.find<TakeOrderController>().resetForNewOrder();
      }
    } catch (_) {
      // Controller not registered or already disposed
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
