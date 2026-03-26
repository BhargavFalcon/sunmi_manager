import 'package:get/get.dart';
import 'package:managerapp/app/modules/take_order_screen/controllers/take_order_controller.dart';

class TakeOrderBinding extends Bindings {
  @override
  void dependencies() {
    // Use put so one instance is created when entering Take Order; GetBuilder will use this same instance.
    if (!Get.isRegistered<TakeOrderController>()) {
      Get.put<TakeOrderController>(TakeOrderController(), permanent: false);
    }
  }
}
