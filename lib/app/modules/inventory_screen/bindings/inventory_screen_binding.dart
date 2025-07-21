import 'package:get/get.dart';

import '../controllers/inventory_screen_controller.dart';

class InventoryScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryScreenController>(
      () => InventoryScreenController(),
    );
  }
}
