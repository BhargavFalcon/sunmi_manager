import 'package:get/get.dart';

import '../controllers/cart_screen_controller.dart';

class CartScreenBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put with permanent: true to avoid SmartManagement warnings
    // This ensures the controller persists across routes
    if (!Get.isRegistered<CartScreenController>()) {
      Get.put<CartScreenController>(CartScreenController(), permanent: true);
    }
  }
}
