import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../model/login_models.dart';

class ManageNotificationController extends GetxController {
  final kitchenTicketGenerationEnabled = true.obs;
  final kotStatusChangeEnabled = true.obs;
  final newTableReservationsEnabled = true.obs;
  final newShopOrderNotificationsEnabled = true.obs;
  final waiterRequestEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final isChef = _isChef();

    newShopOrderNotificationsEnabled.value =
        box.read(ArgumentConstant.newShopOrderNotificationsKey) ?? !isChef;
    kitchenTicketGenerationEnabled.value =
        box.read(ArgumentConstant.kitchenTicketGenerationKey) ?? isChef;
    kotStatusChangeEnabled.value =
        box.read(ArgumentConstant.kotStatusChangeKey) ?? !isChef;
    newTableReservationsEnabled.value =
        box.read(ArgumentConstant.newTableReservationsKey) ?? !isChef;
    waiterRequestEnabled.value =
        box.read(ArgumentConstant.waiterRequestKey) ?? !isChef;
  }

  bool _isChef() {
    try {
      final loginModelData = box.read(ArgumentConstant.loginModelKey);
      if (loginModelData != null && loginModelData is Map<String, dynamic>) {
        final loginModel = LoginModel.fromJson(loginModelData);
        return loginModel.data?.user?.role?.name?.toLowerCase() == 'chef';
      }
    } catch (_) {}
    return false;
  }

  void toggleNewShopOrderNotifications() {
    newShopOrderNotificationsEnabled.value =
        !newShopOrderNotificationsEnabled.value;
    box.write(
      ArgumentConstant.newShopOrderNotificationsKey,
      newShopOrderNotificationsEnabled.value,
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

  void toggleWaiterRequest() {
    waiterRequestEnabled.value = !waiterRequestEnabled.value;
    box.write(
      ArgumentConstant.waiterRequestKey,
      waiterRequestEnabled.value,
    );
  }
}
