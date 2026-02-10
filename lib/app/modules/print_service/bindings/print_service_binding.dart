import 'package:get/get.dart';
import '../controllers/print_service_controller.dart';

class PrintServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrintServiceController>(() => PrintServiceController());
  }
}
