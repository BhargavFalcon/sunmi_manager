import 'package:get/get.dart';

import '../controllers/order_screen_controller.dart';

class OrderScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderScreenController>(
      () => OrderScreenController(),
    );
  }
}
