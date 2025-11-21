import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/app/data/NetworkClient.dart';
import 'package:managerapp/app/model/LoginModels.dart';
import 'package:managerapp/app/model/RestaurantDetailsModel.dart';
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
                // Fetch restaurant details after successful login
                final restaurantId = loginModel.data?.user?.restaurantId;
                if (restaurantId != null) {
                  await fetchRestaurantDetails(restaurantId);
                }
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

  // Fetch restaurant details
  Future<void> fetchRestaurantDetails(int restaurantId) async {
    try {
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

            // Save restaurant details to box
            box.write(
              ArgumentConstant.restaurantDetailsKey,
              restaurantModel.toJson(),
            );
          } catch (e) {
            print('Error parsing restaurant details: ${e.toString()}');
          }
        }
      }
    } catch (e) {
      print('Error fetching restaurant details: ${e.toString()}');
      // Don't show error to user, just log it
    }
  }
}
