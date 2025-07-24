import 'package:get/get.dart';

import '../controllers/reservation_screen_controller.dart';

class ReservationScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReservationScreenController>(
      () => ReservationScreenController(),
    );
  }
}
