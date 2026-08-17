part of 'app_pages.dart';
// ignore_for_file: constant_identifier_names

abstract class Routes {
  Routes._();
  static const MAIN_HOME_SCREEN = _Paths.MAIN_HOME_SCREEN;
  static const ORDER_SCREEN = _Paths.ORDER_SCREEN;
  static const LOGIN_SCREEN = _Paths.LOGIN_SCREEN;
  static const SETTING_SCREEN = _Paths.SETTING_SCREEN;
  static const PRINT_SERVICE = _Paths.PRINT_SERVICE;
}

abstract class _Paths {
  _Paths._();
  static const MAIN_HOME_SCREEN = '/main-home-screen';
  static const ORDER_SCREEN = '/order-screen';
  static const LOGIN_SCREEN = '/login-screen';
  static const SETTING_SCREEN = '/setting-screen';
  static const PRINT_SERVICE = '/print-service';
}
