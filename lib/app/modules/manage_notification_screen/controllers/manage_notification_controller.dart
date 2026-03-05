import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';

class ManageNotificationController extends GetxController {
  final orderPlacedFromQrCodeEnabled = true.obs;
  final kitchenTicketGenerationEnabled = true.obs;
  final kotStatusChangeEnabled = true.obs;
  final newTableReservationsEnabled = true.obs;
  final newShopOrderNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    newShopOrderNotificationsEnabled.value =
        box.read(ArgumentConstant.newShopOrderNotificationsKey) ?? true;
    orderPlacedFromQrCodeEnabled.value =
        box.read(ArgumentConstant.orderPlacedFromQrCodeKey) ?? true;
    kitchenTicketGenerationEnabled.value =
        box.read(ArgumentConstant.kitchenTicketGenerationKey) ?? true;
    kotStatusChangeEnabled.value =
        box.read(ArgumentConstant.kotStatusChangeKey) ?? true;
    newTableReservationsEnabled.value =
        box.read(ArgumentConstant.newTableReservationsKey) ?? true;
  }

  void toggleNewShopOrderNotifications() {
    newShopOrderNotificationsEnabled.value =
        !newShopOrderNotificationsEnabled.value;
    box.write(
      ArgumentConstant.newShopOrderNotificationsKey,
      newShopOrderNotificationsEnabled.value,
    );
  }

  void toggleOrderPlacedFromQrCode() {
    orderPlacedFromQrCodeEnabled.value = !orderPlacedFromQrCodeEnabled.value;
    box.write(
      ArgumentConstant.orderPlacedFromQrCodeKey,
      orderPlacedFromQrCodeEnabled.value,
    );
  }

  void toggleKitchenTicketGeneration() {
    kitchenTicketGenerationEnabled.value =
        !kitchenTicketGenerationEnabled.value;
    box.write(
      ArgumentConstant.kitchenTicketGenerationKey,
      kitchenTicketGenerationEnabled.value,
    );
  }

  void toggleKotStatusChange() {
    kotStatusChangeEnabled.value = !kotStatusChangeEnabled.value;
    box.write(
      ArgumentConstant.kotStatusChangeKey,
      kotStatusChangeEnabled.value,
    );
  }

  void toggleNewTableReservations() {
    newTableReservationsEnabled.value = !newTableReservationsEnabled.value;
    box.write(
      ArgumentConstant.newTableReservationsKey,
      newTableReservationsEnabled.value,
    );
  }
}
