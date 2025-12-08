import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../data/NetworkClient.dart';
import '../../../routes/app_pages.dart';

class SettingScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      final response = await networkClient.post(
        ArgumentConstant.logoutEndpoint,
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        networkClient.removeAuthToken();
        box.remove(ArgumentConstant.loginModelKey);
        box.remove(ArgumentConstant.menuItemsKey);
        Get.offAllNamed(Routes.LOGIN_SCREEN);
      }
    } on ApiException catch (e) {
      isLoading.value = false;
      safeGetSnackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      isLoading.value = false;
      networkClient.removeAuthToken();
      box.remove(ArgumentConstant.loginModelKey);
      box.remove(ArgumentConstant.menuItemsKey);
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    }
  }
}
