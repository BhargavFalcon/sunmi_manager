import 'package:get/get.dart';

import '../controllers/inventory_dashboard_controller.dart';

class InventoryDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryDashboardController>(
      () => InventoryDashboardController(),
    );
  }
}
