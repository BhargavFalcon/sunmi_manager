import 'package:get/get.dart';

import '../controllers/table_screen_controller.dart';

class TableScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TableScreenController>(
      () => TableScreenController(),
    );
  }
}
