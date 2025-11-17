import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/app/data/NetworkClient.dart';
import 'package:managerapp/app/model/LoginModels.dart';
import 'package:managerapp/app/routes/app_pages.dart';
import '../../../../main.dart';

class LoginScreenController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final networkClient = NetworkClient();

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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    // Validate email and password
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
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

      // Handle successful login
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          try {
            // Parse response to LoginModel
            final loginModel = LoginModel.fromJson(
              response.data as Map<String, dynamic>,
            );

            // Save LoginModel to GetStorage
            box.write(ArgumentConstant.loginModelKey, loginModel.toJson());

            // Extract and save token
            String? token;
            if (loginModel.data?.token != null &&
                loginModel.data!.token!.isNotEmpty) {
              token = loginModel.data!.token;
            }

            // Save token if found
            if (token != null && token.isNotEmpty) {
              networkClient.setAuthToken(token);
              // Verify token was saved before navigation
              final savedToken = networkClient.getSavedToken();
              if (savedToken != null && savedToken.isNotEmpty) {
                // Navigate to main home screen - use offAllNamed to clear stack
                Get.offAllNamed(Routes.MAIN_HOME_SCREEN);
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to save authentication token',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            } else {
              Get.snackbar(
                'Error',
                'Token not found in response',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to parse login response: ${e.toString()}',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'Invalid response format',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } on ApiException catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
