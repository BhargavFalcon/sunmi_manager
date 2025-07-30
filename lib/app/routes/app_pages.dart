import 'package:get/get.dart';

import '../modules/Inventory_Dashboard/bindings/inventory_dashboard_binding.dart';
import '../modules/Inventory_Dashboard/views/inventory_dashboard_view.dart';
import '../modules/Inventory_PurchaseOrder/bindings/inventory_purchase_order_binding.dart';
import '../modules/Inventory_PurchaseOrder/views/inventory_purchase_order_view.dart';
import '../modules/dashboard_screen/bindings/dashboard_screen_binding.dart';
import '../modules/dashboard_screen/views/dashboard_screen_view.dart';
import '../modules/inventory_screen/bindings/inventory_screen_binding.dart';
import '../modules/inventory_screen/views/inventory_screen_view.dart';
import '../modules/mainHome_screen/bindings/main_home_screen_binding.dart';
import '../modules/mainHome_screen/views/main_home_screen_view.dart';
import '../modules/order_screen/bindings/order_screen_binding.dart';
import '../modules/order_screen/views/order_screen_view.dart';
import '../modules/reservation_screen/bindings/reservation_screen_binding.dart';
import '../modules/reservation_screen/views/reservation_screen_view.dart';
import '../modules/setting_screen/bindings/setting_screen_binding.dart';
import '../modules/setting_screen/views/setting_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN_HOME_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.MAIN_HOME_SCREEN,
      page: () => const MainHomeScreenView(),
      binding: MainHomeScreenBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD_SCREEN,
      page: () => const DashboardScreenView(),
      binding: DashboardScreenBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_SCREEN,
      page: () => const OrderScreenView(),
      binding: OrderScreenBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY_SCREEN,
      page: () => const InventoryScreenView(),
      binding: InventoryScreenBinding(),
    ),
    GetPage(
      name: _Paths.SETTING_SCREEN,
      page: () => const SettingScreenView(),
      binding: SettingScreenBinding(),
    ),
    GetPage(
      name: _Paths.RESERVATION_SCREEN,
      page: () => const ReservationScreenView(),
      binding: ReservationScreenBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY_DASHBOARD,
      page: () => const InventoryDashboardView(),
      binding: InventoryDashboardBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY_PURCHASE_ORDER,
      page: () => const InventoryPurchaseOrderView(),
      binding: InventoryPurchaseOrderBinding(),
    ),
  ];
}
