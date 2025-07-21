import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/mainHome_screen/bindings/main_home_screen_binding.dart';
import '../modules/mainHome_screen/views/main_home_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN_HOME_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_HOME_SCREEN,
      page: () => const MainHomeScreenView(),
      binding: MainHomeScreenBinding(),
    ),
  ];
}
