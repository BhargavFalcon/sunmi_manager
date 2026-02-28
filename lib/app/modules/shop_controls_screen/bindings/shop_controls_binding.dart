import 'package:get/get.dart';
import '../controllers/shop_controls_controller.dart';

class ShopControlsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopControlsController>(() => ShopControlsController());
  }
}
