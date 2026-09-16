import '../../../utils/branch_utils.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/app/widgets/app_toast.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/data/NetworkClient.dart';
import 'package:managerapp/app/data/pusher_service.dart';
import 'package:managerapp/app/model/login_models.dart';
import 'package:managerapp/app/model/restaurant_details_model.dart';
import 'package:managerapp/app/model/restaurant_users_model.dart';
import 'package:managerapp/app/routes/app_pages.dart';
import '../../../../main.dart';

enum LoginMode { pin, emailPassword, appLock }

class LoginScreenController extends GetxController {
  final restaurantIdController = TextEditingController();
  final restaurantIdFocusNode = FocusNode();
  final keyboardTypeForRestaurantId = TextInputType.text.obs;
  final pinController = TextEditingController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isLoadingUsers = false.obs;
  final isPasswordVisible = false.obs;

  final loginMode = LoginMode.pin.obs;

  final restaurantUsers = <RestaurantUser>[].obs;

  final selectedUser = Rxn<RestaurantUser>();

  final usersLoaded = false.obs;

  final networkClient = NetworkClient();

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();

    restaurantIdController.addListener(() {
      final text = restaurantIdController.text;
      if (text.length >= 3) {
        if (keyboardTypeForRestaurantId.value != TextInputType.number) {
          keyboardTypeForRestaurantId.value = TextInputType.number;
          _reloadKeyboard();
        }
      } else {
        if (keyboardTypeForRestaurantId.value != TextInputType.text) {
          keyboardTypeForRestaurantId.value = TextInputType.text;
          _reloadKeyboard();
        }
      }
    });
  }

  void _reloadKeyboard() {
    if (!isClosed && restaurantIdFocusNode.hasFocus) {
      restaurantIdFocusNode.unfocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!isClosed && restaurantIdFocusNode.canRequestFocus) {
          restaurantIdFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    _checkExistingSession();
  }

  void _checkExistingSession() {
    try {
      final token = box.read<String>(ArgumentConstant.tokenKey);
      final savedPin = box.read<String>(ArgumentConstant.savedPinKey);
      final loginData = box.read(ArgumentConstant.loginModelKey);

      if (token != null &&
          token.isNotEmpty &&
          savedPin != null &&
          savedPin.isNotEmpty &&
          loginData != null) {
        Map<String, dynamic>? data;
        if (loginData is String) {
          try {
            data = json.decode(loginData) as Map<String, dynamic>;
          } catch (_) {}
        } else if (loginData is Map) {
          data = Map<String, dynamic>.from(loginData);
        }

        if (data != null) {
          final loginModel = LoginModel.fromJson(data);
          final user = loginModel.data?.user;
          if (user != null) {
            loginMode.value = LoginMode.appLock;
            selectedUser.value = RestaurantUser(
              id: user.id,
              name: user.name,
              email: user.email,
            );
          }
        }
      }
    } catch (_) {}
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void switchMode(LoginMode mode) {
    loginMode.value = mode;
    _clearFields();
  }

  void _clearFields() {
    restaurantIdController.clear();
    pinController.clear();
    emailController.clear();
    passwordController.clear();
    restaurantUsers.clear();
    selectedUser.value = null;
    usersLoaded.value = false;
  }

  void selectUser(RestaurantUser user) {
    selectedUser.value = user;
    pinController.clear();
  }

  void clearSelectedUser() {
    selectedUser.value = null;
    pinController.clear();
  }

  Future<void> fetchRestaurantUsers() async {
    final restaurantId = restaurantIdController.text.trim();
    if (restaurantId.isEmpty) {
      AppToast.showError(
        'Please enter Restaurant ID',
        title: TranslationKeys.error.tr,
      );
      return;
    }

    try {
      isLoadingUsers.value = true;
      selectedUser.value = null;
      restaurantUsers.clear();

      final endpoint = ArgumentConstant.restaurantUsersEndpoint.replaceAll(
        ':restaurant_id',
        restaurantId,
      );

      final response = await networkClient.get(endpoint);
      isLoadingUsers.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          final model = RestaurantUsersModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          if (model.data != null && model.data!.isNotEmpty) {
            final filteredUsers = model.data!.where((user) {
              final roleName = user.role?.name?.toLowerCase() ?? '';
              final displayName = user.role?.displayName?.toLowerCase() ?? '';
              final isNotAdmin =
                  !roleName.contains('admin') && !displayName.contains('admin');
              final isNotChef =
                  !roleName.contains('chef') && !displayName.contains('chef');
              return isNotAdmin && isNotChef;
            }).toList();

            if (filteredUsers.isNotEmpty) {
              restaurantUsers.assignAll(filteredUsers);
              usersLoaded.value = true;
            } else {
              usersLoaded.value = true;
              AppToast.showError(
                'No non-admin staff found for this Restaurant ID',
                title: TranslationKeys.error.tr,
              );
            }
          } else {
            usersLoaded.value = true;
            AppToast.showError(
              'No users found for this Restaurant ID',
              title: TranslationKeys.error.tr,
            );
          }
        }
      }
    } on ApiException catch (e) {
      isLoadingUsers.value = false;
      AppToast.showError(e.message, title: TranslationKeys.error.tr);
    } catch (_) {
      isLoadingUsers.value = false;
      AppToast.showError(
        TranslationKeys.somethingWentWrong.tr,
        title: TranslationKeys.error.tr,
      );
    }
  }

  Future<void> loginWithPin() async {
    final user = selectedUser.value;
    if (user == null) {
      AppToast.showError(
        'Please select a user first',
        title: TranslationKeys.error.tr,
      );
      return;
    }

    final pin = pinController.text.trim();
    if (pin.isEmpty || pin.length != 4) {
      AppToast.showError(
        'Please enter a valid 4-digit PIN',
        title: TranslationKeys.error.tr,
      );
      return;
    }

    if (loginMode.value == LoginMode.appLock) {
      final savedPin = box.read<String>(ArgumentConstant.savedPinKey);
      if (savedPin == pin) {
        Get.offAllNamed(Routes.MAIN_HOME_SCREEN);
      } else {
        AppToast.showError(
          'Incorrect PIN',
          title: TranslationKeys.error.tr,
        );
      }
      return;
    }

    String email = user.email ?? '';
    if (email.isEmpty) {
      email = user.username ?? '';
    }
    if (email.isEmpty) {
      AppToast.showError(
        'User email/login not available',
        title: TranslationKeys.error.tr,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await networkClient.post(
        ArgumentConstant.loginEndpoint,
        data: {
          'email': email,
          'login': email,
          'authenticate_by': 'pin',
          'pin': pin,
        },
      );

      isLoading.value = false;
      box.write(ArgumentConstant.savedPinKey, pin);
      await _handleLoginResponse(response);
    } on ApiException catch (e) {
      isLoading.value = false;
      AppToast.showError(e.message, title: TranslationKeys.error.tr);
    } catch (_) {
      isLoading.value = false;
      AppToast.showError(
        TranslationKeys.somethingWentWrong.tr,
        title: TranslationKeys.error.tr,
      );
    }
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
          'login': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'authenticate_by': 'password',
        },
      );

      isLoading.value = false;
      await _handleLoginResponse(response);
    } on ApiException catch (e) {
      isLoading.value = false;
      AppToast.showError(e.message, title: TranslationKeys.error.tr);
    } catch (_) {
      isLoading.value = false;
      AppToast.showError(
        TranslationKeys.somethingWentWrong.tr,
        title: TranslationKeys.error.tr,
      );
    }
  }

  Future<void> _handleLoginResponse(dynamic response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data != null && response.data is Map<String, dynamic>) {
        try {
          if (Get.isRegistered<PusherService>()) {
            await Get.find<PusherService>().disconnect();
          }

          box.remove(ArgumentConstant.mobileAppModulesKey);
          box.remove(ArgumentConstant.restaurantDetailsKey);

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
        } catch (_) {
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
              BranchUtils.saveBranchTimezone(restaurantModel);
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    restaurantIdController.dispose();
    restaurantIdFocusNode.dispose();
    pinController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
