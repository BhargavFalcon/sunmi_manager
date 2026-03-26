import 'package:get/get.dart';

import '../../main.dart';
import '../constants/api_constants.dart';
import '../middleware/auth_middleware.dart';
import '../modules/Inventory_Dashboard/bindings/inventory_dashboard_binding.dart';
import '../modules/Inventory_Dashboard/views/inventory_dashboard_view.dart';
import '../modules/Inventory_PurchaseOrder/bindings/inventory_purchase_order_binding.dart';
import '../modules/Inventory_PurchaseOrder/views/inventory_purchase_order_view.dart';
import '../modules/cart_screen/bindings/cart_screen_binding.dart';
import '../modules/cart_screen/views/cart_screen_view.dart';
import '../modules/dashboard_screen/bindings/dashboard_screen_binding.dart';
import '../modules/dashboard_screen/views/dashboard_screen_view.dart';
import '../modules/inventory_screen/bindings/inventory_screen_binding.dart';
import '../modules/inventory_screen/views/inventory_screen_view.dart';
import '../modules/login_screen/bindings/login_screen_binding.dart';
import '../modules/login_screen/views/login_screen_view.dart';
import '../modules/kitchen_tickets_screen/bindings/kitchen_tickets_screen_binding.dart';
import '../modules/kitchen_tickets_screen/views/kitchen_tickets_screen_view.dart';
import '../modules/mainHome_screen/bindings/main_home_screen_binding.dart';
import '../modules/mainHome_screen/views/main_home_screen_view.dart';
import '../modules/order_screen/bindings/order_screen_binding.dart';
import '../modules/order_screen/views/order_screen_view.dart';
import '../modules/reservation_screen/bindings/reservation_screen_binding.dart';
import '../modules/reservation_screen/views/reservation_screen_view.dart';
import '../modules/setting_screen/bindings/setting_screen_binding.dart';
import '../modules/setting_screen/views/setting_screen_view.dart';
import '../modules/manage_printer_screen/bindings/manage_printer_screen_binding.dart';
import '../modules/manage_printer_screen/views/manage_printer_screen_view.dart';
import '../modules/print_service/bindings/print_service_binding.dart';
import '../modules/print_service/views/print_service_view.dart';
import '../modules/table_screen/bindings/table_screen_binding.dart';
import '../modules/table_screen/views/table_screen_view.dart';
import '../modules/take_order_screen/bindings/take_order_binding.dart';
import '../modules/take_order_screen/views/take_order_view.dart';
import '../modules/shop_controls_screen/bindings/shop_controls_binding.dart';
import '../modules/shop_controls_screen/views/shop_controls_view.dart';
import '../modules/manage_notification_screen/bindings/manage_notification_binding.dart';
import '../modules/manage_notification_screen/views/manage_notification_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Check if user is already logged in and return appropriate initial route
  // ignore: non_constant_identifier_names
  static String get INITIAL {
    try {
      final token = box.read<String>(ArgumentConstant.tokenKey);
      if (token != null && token.isNotEmpty) {
        return Routes.MAIN_HOME_SCREEN;
      }
    } catch (e) {
      // Handle error silently
    }
    return Routes.LOGIN_SCREEN;
  }

  static final routes = [
    GetPage(
      name: _Paths.MAIN_HOME_SCREEN,
      page: () => const MainHomeScreenView(),
      binding: MainHomeScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.KITCHEN_TICKETS_SCREEN,
      page: () => const KitchenTicketsScreenView(),
      binding: KitchenTicketsScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.DASHBOARD_SCREEN,
      page: () => const DashboardScreenView(),
      binding: DashboardScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ORDER_SCREEN,
      page: () => const OrderScreenView(),
      binding: OrderScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.INVENTORY_SCREEN,
      page: () => const InventoryScreenView(),
      binding: InventoryScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.RESERVATION_SCREEN,
      page: () => const ReservationScreenView(),
      binding: ReservationScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.INVENTORY_DASHBOARD,
      page: () => const InventoryDashboardView(),
      binding: InventoryDashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.INVENTORY_PURCHASE_ORDER,
      page: () => const InventoryPurchaseOrderView(),
      binding: InventoryPurchaseOrderBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.TAKE_ORDER_SCREEN,
      page: () => const TakeOrderView(),
      binding: TakeOrderBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.LOGIN_SCREEN,
      page: () => const LoginScreenView(),
      binding: LoginScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CART_SCREEN,
      page: () => const CartScreenView(),
      binding: CartScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.TABLE_SCREEN,
      page: () => const TableScreenView(),
      binding: TableScreenBinding(),
    ),
    GetPage(
      name: _Paths.SETTING_SCREEN,
      page: () => const SettingScreenView(),
      binding: SettingScreenBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_PRINTER_SCREEN,
      page: () => const ManagePrinterScreenView(),
      binding: ManagePrinterScreenBinding(),
    ),
    GetPage(
      name: _Paths.PRINT_SERVICE,
      page: () => const PrintServiceView(),
      binding: PrintServiceBinding(),
    ),
    GetPage(
      name: _Paths.SHOP_CONTROLS_SCREEN,
      page: () => const ShopControlsView(),
      binding: ShopControlsBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_NOTIFICATION_SCREEN,
      page: () => const ManageNotificationView(),
      binding: ManageNotificationBinding(),
    ),
  ];
}
