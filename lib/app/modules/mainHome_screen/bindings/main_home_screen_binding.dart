import 'package:get/get.dart';

import '../../kitchen_tickets_screen/bindings/kitchen_tickets_screen_binding.dart';
import '../controllers/main_home_screen_controller.dart';

class MainHomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeScreenController>(
      () => MainHomeScreenController(),
    );
    KitchenTicketsScreenBinding().dependencies();
  }
}
