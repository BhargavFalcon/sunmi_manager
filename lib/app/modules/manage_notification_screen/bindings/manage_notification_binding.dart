import 'package:get/get.dart';
import '../controllers/manage_notification_controller.dart';

class ManageNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageNotificationController>(
      () => ManageNotificationController(),
    );
  }
}
