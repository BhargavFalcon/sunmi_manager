import 'package:get/get.dart';

import '../controllers/inventory_purchase_order_controller.dart';

class InventoryPurchaseOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryPurchaseOrderController>(
      () => InventoryPurchaseOrderController(),
    );
  }
}
