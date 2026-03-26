import 'package:get/get.dart';
import '../controllers/manage_printer_screen_controller.dart';

class ManagePrinterScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagePrinterScreenController>(
      () => ManagePrinterScreenController(),
    );
  }
}
