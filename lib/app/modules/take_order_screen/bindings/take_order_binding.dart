import 'package:get/get.dart';
import 'package:managerapp/app/modules/take_order_screen/controllers/take_order_controller.dart';

class TakeOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TakeOrderController>(
      () => TakeOrderController(),
    );
  }
}
