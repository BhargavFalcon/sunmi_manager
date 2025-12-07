import 'package:get/get.dart';

import '../controllers/printer_screen_controller.dart';

class PrinterScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrinterScreenController>(() => PrinterScreenController());
  }
}
