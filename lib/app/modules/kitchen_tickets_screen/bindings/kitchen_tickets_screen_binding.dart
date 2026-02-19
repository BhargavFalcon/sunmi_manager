import 'package:get/get.dart';

import '../controllers/kitchen_tickets_screen_controller.dart';

class KitchenTicketsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KitchenTicketsScreenController>(
      () => KitchenTicketsScreenController(),
    );
  }
}
