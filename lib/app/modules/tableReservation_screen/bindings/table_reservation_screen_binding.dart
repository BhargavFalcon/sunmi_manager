import 'package:get/get.dart';

import '../controllers/table_reservation_screen_controller.dart';

class TableReservationScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TableReservationScreenController>(
      () => TableReservationScreenController(),
    );
  }
}
