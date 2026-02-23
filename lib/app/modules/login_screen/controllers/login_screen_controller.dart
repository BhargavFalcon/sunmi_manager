import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/app/widgets/app_toast.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/data/NetworkClient.dart';
import 'package:managerapp/app/model/login_models.dart';
import 'package:managerapp/app/model/restaurant_details_model.dart';
import 'package:managerapp/app/routes/app_pages.dart';
import '../../../../main.dart';

class LoginScreenController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final networkClient = NetworkClient();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }



  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty) {
      AppToast.showError(
        TranslationKeys.pleaseEnterEmail.tr,
        title: TranslationKeys.error.tr,
      );
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      AppToast.showError(
        TranslationKeys.pleaseEnterPassword.tr,
        title: TranslationKeys.error.tr,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await networkClient.post(
        ArgumentConstant.loginEndpoint,
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          try {
            final loginModel = LoginModel.fromJson(
              response.data as Map<String, dynamic>,
            );

            box.write(ArgumentConstant.loginModelKey, loginModel.toJson());

            String? token;
            if (loginModel.data?.token != null &&
                loginModel.data!.token!.isNotEmpty) {
              token = loginModel.data!.token;
            }

            if (token != null && token.isNotEmpty) {
              networkClient.setAuthToken(token);
              final savedToken = networkClient.getSavedToken();
              if (savedToken != null && savedToken.isNotEmpty) {
                await _fetchRestaurantDetails(loginModel);
                Get.offAllNamed(Routes.MAIN_HOME_SCREEN);
              } else {
                AppToast.showError(
                  TranslationKeys.failedToSaveAuthToken.tr,
                  title: TranslationKeys.error.tr,
                );
              }
            } else {
              AppToast.showError(
                TranslationKeys.tokenNotFound.tr,
                title: TranslationKeys.error.tr,
              );
            }
          } catch (e) {
            AppToast.showError(
              TranslationKeys.failedToParseLoginResponse.tr,
              title: TranslationKeys.error.tr,
            );
          }
        } else {
          AppToast.showError(
            TranslationKeys.invalidResponseFormat.tr,
            title: TranslationKeys.error.tr,
          );
        }
      }
    } on ApiException catch (e) {
      isLoading.value = false;
      AppToast.showError(e.message, title: TranslationKeys.error.tr);
    } catch (e) {
      isLoading.value = false;
      AppToast.showError(
        TranslationKeys.somethingWentWrong.tr,
        title: TranslationKeys.error.tr,
      );
    }
  }

  Future<void> _fetchRestaurantDetails(LoginModel loginModel) async {
    try {
      final restaurantId = loginModel.data?.user?.restaurantId;
      if (restaurantId != null) {
        final endpoint = ArgumentConstant.restaurantDetailsEndpoint.replaceAll(
          ':restaurant_id',
          restaurantId.toString(),
        );

        final response = await networkClient.get(endpoint);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data != null && response.data is Map<String, dynamic>) {
            try {
              final restaurantModel = RestaurantModel.fromJson(
                response.data as Map<String, dynamic>,
              );
              box.write(
                ArgumentConstant.restaurantDetailsKey,
                restaurantModel.toJson(),
              );
            } catch (e) {
              // Handle parsing error silently
            }
          }
        }
      }
    } catch (e) {
      // Handle error silently - don't block login flow
    }
  }
}
