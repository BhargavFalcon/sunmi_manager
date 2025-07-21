import 'package:get/get.dart';

import '../controllers/main_home_screen_controller.dart';

class MainHomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeScreenController>(
      () => MainHomeScreenController(),
    );
  }
}
