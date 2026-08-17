import 'package:get/get.dart';
import '../../main.dart';
import '../constants/api_constants.dart';
import '../middleware/auth_middleware.dart';
import '../modules/login_screen/bindings/login_screen_binding.dart';
import '../modules/login_screen/views/login_screen_view.dart';
import '../modules/mainHome_screen/bindings/main_home_screen_binding.dart';
import '../modules/mainHome_screen/views/main_home_screen_view.dart';
import '../modules/order_screen/bindings/order_screen_binding.dart';
import '../modules/order_screen/views/order_screen_view.dart';
import '../modules/setting_screen/bindings/setting_screen_binding.dart';
import '../modules/setting_screen/views/setting_screen_view.dart';
import '../modules/print_service/bindings/print_service_binding.dart';
import '../modules/print_service/views/print_service_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: non_constant_identifier_names
  static String get INITIAL {
    final token = box.read<String>(ArgumentConstant.tokenKey);
    final savedPin = box.read<String>(ArgumentConstant.savedPinKey);
    if (token != null &&
        token.isNotEmpty &&
        savedPin != null &&
        savedPin.isNotEmpty) {
      return Routes.LOGIN_SCREEN;
    } else if (token != null && token.isNotEmpty) {
      return Routes.MAIN_HOME_SCREEN;
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
      name: _Paths.ORDER_SCREEN,
      page: () => const OrderScreenView(),
      binding: OrderScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.LOGIN_SCREEN,
      page: () => const LoginScreenView(),
      binding: LoginScreenBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SETTING_SCREEN,
      page: () => const SettingScreenView(),
      binding: SettingScreenBinding(),
    ),
    GetPage(
      name: _Paths.PRINT_SERVICE,
      page: () => const PrintServiceView(),
      binding: PrintServiceBinding(),
    ),
  ];
}
