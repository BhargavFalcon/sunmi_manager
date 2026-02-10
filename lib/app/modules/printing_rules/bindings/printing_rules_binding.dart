import 'package:get/get.dart';
import '../controllers/printing_rules_controller.dart';

class PrintingRulesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrintingRulesController>(() => PrintingRulesController());
  }
}
