import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/model/restaurant_users_model.dart';
import 'package:managerapp/app/widgets/shared/common_text_field.dart';

import '../controllers/login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenController> {
  const LoginScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    const double fontScale = 1.0;
    final double cardMaxWidth = double.infinity;
    final double hPad = MySize.getWidth(8);
    final double topPad = MySize.getHeight(60);

    return Scaffold(
      backgroundColor: ColorConstants.bgColor,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom +
                MySize.getHeight(20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: topPad),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          ImageConstant.bottomLogo,
                          height: MySize.getHeight(30),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: MySize.getWidth(3)),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: MySize.getHeight(25 * fontScale),
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: TranslationKeys.dine.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: 'metrics'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MySize.getHeight(28)),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
                        boxShadow: ColorConstants.getShadow2,
                      ),
                      padding: EdgeInsets.all(MySize.getWidth(12)),
                      child: Obx(() {
                        switch (controller.loginMode.value) {
                          case LoginMode.appLock:
                            return _AppLockBody(
                              controller: controller,
                              fontScale: fontScale,
                            );
                          case LoginMode.pin:
                            return _PinFlowBody(
                              controller: controller,
                              fontScale: fontScale,
                            );
                          case LoginMode.emailPassword:
                            return _EmailPasswordBody(
                              controller: controller,
                              fontScale: fontScale,
                            );
                        }
                      }),
                    ),
                    SizedBox(height: MySize.getHeight(16)),
                    Obx(() {
                      if (controller.loginMode.value == LoginMode.appLock) {
                        return const SizedBox.shrink();
                      }
                      final isPinMode =
                          controller.loginMode.value == LoginMode.pin;
                      return GestureDetector(
                        onTap:
                            () => controller.switchMode(
                              isPinMode
                                  ? LoginMode.emailPassword
                                  : LoginMode.pin,
                            ),
                        child: Text(
                          isPinMode
                              ? 'Login as Admin'
                              : 'Login with Restaurant ID & PIN',
                          style: TextStyle(
                            fontSize: MySize.getHeight(13 * fontScale),
                            color: ColorConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: ColorConstants.primaryColor,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLockBody extends StatelessWidget {
  const _AppLockBody({
    required this.controller,
    required this.fontScale,
  });

  final LoginScreenController controller;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final user = controller.selectedUser.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user != null) ...[
          Row(
            children: [
              CircleAvatar(
                radius: MySize.getHeight(16),
                backgroundColor:
                    ColorConstants.primaryColor.withValues(alpha: 0.15),
                child: Text(
                  (user.name ?? 'U').substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: ColorConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(14 * fontScale),
                  ),
                ),
              ),
              SizedBox(width: MySize.getWidth(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? '',
                      style: TextStyle(
                        fontSize: MySize.getHeight(13 * fontScale),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((user.email ?? '').isNotEmpty)
                      Text(
                        user.email!,
                        style: TextStyle(
                          fontSize: MySize.getHeight(11 * fontScale),
                          color: ColorConstants.grey600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(16)),
        ],
        Text(
          'Enter 4-Digit PIN',
          style: TextStyle(
            fontSize: MySize.getHeight(13 * fontScale),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: MySize.getHeight(5)),
        SizedBox(
          height: MySize.getHeight(36 * fontScale),
          child: CommonTextField(
            controller: controller.pinController,
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(12),
              vertical: 0,
            ),
            placeholder: '• • • •',
            obscureText: true,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            style: TextStyle(
              fontSize: MySize.getHeight(16 * fontScale),
              color: Colors.black,
              letterSpacing: MySize.getWidth(8),
            ),
            placeholderStyle: TextStyle(
              color: ColorConstants.grey600,
              fontSize: MySize.getHeight(12 * fontScale),
            ),
            onSubmitted: (_) => controller.loginWithPin(),
          ),
        ),
        SizedBox(height: MySize.getHeight(16)),
        Obx(
          () => _PrimaryButton(
            label: TranslationKeys.login.tr,
            isLoading: controller.isLoading.value,
            fontScale: fontScale,
            onTap: () {
              FocusScope.of(context).unfocus();
              controller.loginWithPin();
            },
          ),
        ),
      ],
    );
  }
}

class _PinFlowBody extends StatelessWidget {
  const _PinFlowBody({
    required this.controller,
    required this.fontScale,
  });

  final LoginScreenController controller;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.login.tr,
          style: TextStyle(
            fontSize: MySize.getHeight(16 * fontScale),
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          height: MySize.getHeight(1),
          width: MySize.getWidth(40),
          color: ColorConstants.primaryColor,
        ),
        SizedBox(height: MySize.getHeight(2)),
        Text(
          TranslationKeys.welcomeBack.tr,
          style: TextStyle(
            fontSize: MySize.getHeight(13 * fontScale),
            color: ColorConstants.grey600,
          ),
        ),
        SizedBox(height: MySize.getHeight(14)),
        Text(
          'Restaurant ID',
          style: TextStyle(
            fontSize: MySize.getHeight(13 * fontScale),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: MySize.getHeight(5)),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: MySize.getHeight(36 * fontScale),
                  child: CommonTextField(
                    controller: controller.restaurantIdController,
                    focusNode: controller.restaurantIdFocusNode,
                    keyboardType: controller.keyboardTypeForRestaurantId.value,
                    inputFormatters: [RestaurantIdFormatter()],
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(12),
                      vertical: 0,
                    ),
                    placeholder: 'Enter restaurant ID (e.g. DE-0001)',
                    style: TextStyle(
                      fontSize: MySize.getHeight(12 * fontScale),
                      color: Colors.black,
                    ),
                    placeholderStyle: TextStyle(
                      color: ColorConstants.grey600,
                      fontSize: MySize.getHeight(12 * fontScale),
                    ),
                    onSubmitted: (_) => controller.fetchRestaurantUsers(),
                  ),
                ),
              ),
              SizedBox(width: MySize.getWidth(6)),
              GestureDetector(
                onTap:
                    controller.isLoadingUsers.value
                        ? null
                        : controller.fetchRestaurantUsers,
                child: Container(
                  height: MySize.getHeight(36 * fontScale),
                  width: MySize.getHeight(36 * fontScale),
                  decoration: BoxDecoration(
                    color:
                        controller.isLoadingUsers.value
                            ? ColorConstants.grey600
                            : ColorConstants.primaryColor,
                    borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                  ),
                  child: Center(
                    child:
                        controller.isLoadingUsers.value
                            ? CupertinoActivityIndicator(
                              radius: MySize.getHeight(9),
                              color: Colors.white,
                            )
                            : Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: MySize.getHeight(20),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          if (!controller.usersLoaded.value) return const SizedBox.shrink();
          if (controller.restaurantUsers.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: MySize.getHeight(10)),
              child: Text(
                'No users found',
                style: TextStyle(
                  fontSize: MySize.getHeight(12 * fontScale),
                  color: ColorConstants.grey600,
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MySize.getHeight(12)),
              Text(
                'Select Staff',
                style: TextStyle(
                  fontSize: MySize.getHeight(13 * fontScale),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MySize.getHeight(8)),
              Wrap(
                spacing: MySize.getWidth(8),
                runSpacing: MySize.getHeight(8),
                children:
                    controller.restaurantUsers
                        .map(
                          (user) => _UserChip(
                            user: user,
                            isSelected:
                                controller.selectedUser.value?.id == user.id,
                            fontScale: fontScale,
                            onTap: () => controller.selectUser(user),
                          ),
                        )
                        .toList(),
              ),
            ],
          );
        }),
        Obx(() {
          if (controller.selectedUser.value == null) {
            return const SizedBox.shrink();
          }
          final user = controller.selectedUser.value!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MySize.getHeight(16)),
              Row(
                children: [
                  CircleAvatar(
                    radius: MySize.getHeight(16),
                    backgroundColor:
                        ColorConstants.primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      (user.name ?? 'U').substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: MySize.getHeight(14 * fontScale),
                      ),
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? '',
                          style: TextStyle(
                            fontSize: MySize.getHeight(13 * fontScale),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if ((user.email ?? '').isNotEmpty)
                          Text(
                            user.email!,
                            style: TextStyle(
                              fontSize: MySize.getHeight(11 * fontScale),
                              color: ColorConstants.grey600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.clearSelectedUser,
                    child: Icon(
                      Icons.close_rounded,
                      size: MySize.getHeight(18),
                      color: ColorConstants.grey600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MySize.getHeight(12)),
              Text(
                'Enter 4-Digit PIN',
                style: TextStyle(
                  fontSize: MySize.getHeight(13 * fontScale),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MySize.getHeight(5)),
              SizedBox(
                height: MySize.getHeight(36 * fontScale),
                child: CommonTextField(
                  controller: controller.pinController,
                  padding: EdgeInsets.symmetric(
                    horizontal: MySize.getWidth(12),
                    vertical: 0,
                  ),
                  placeholder: '• • • •',
                  obscureText: true,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: TextStyle(
                    fontSize: MySize.getHeight(16 * fontScale),
                    color: Colors.black,
                    letterSpacing: MySize.getWidth(8),
                  ),
                  placeholderStyle: TextStyle(
                    color: ColorConstants.grey600,
                    fontSize: MySize.getHeight(12 * fontScale),
                  ),
                  onSubmitted: (_) => controller.loginWithPin(),
                ),
              ),
              SizedBox(height: MySize.getHeight(16)),
              Obx(
                () => _PrimaryButton(
                  label: TranslationKeys.login.tr,
                  isLoading: controller.isLoading.value,
                  fontScale: fontScale,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    controller.loginWithPin();
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _EmailPasswordBody extends StatelessWidget {
  const _EmailPasswordBody({
    required this.controller,
    required this.fontScale,
  });

  final LoginScreenController controller;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.login.tr,
          style: TextStyle(
            fontSize: MySize.getHeight(16 * fontScale),
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          height: MySize.getHeight(1),
          width: MySize.getWidth(40),
          color: ColorConstants.primaryColor,
        ),
        SizedBox(height: MySize.getHeight(2)),
        Text(
          TranslationKeys.welcomeBack.tr,
          style: TextStyle(
            fontSize: MySize.getHeight(13 * fontScale),
            color: ColorConstants.grey600,
          ),
        ),
        SizedBox(height: MySize.getHeight(14)),
        Text(
          TranslationKeys.enterEmailOrUsername.tr,
          style: TextStyle(
            fontSize: MySize.getHeight(13 * fontScale),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: MySize.getHeight(5)),
        SizedBox(
          height: MySize.getHeight(36 * fontScale),
          child: CommonTextField(
            controller: controller.emailController,
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(12),
              vertical: 0,
            ),
            placeholder: TranslationKeys.emailOrUsername.tr,
            style: TextStyle(
              fontSize: MySize.getHeight(12 * fontScale),
              color: Colors.black,
            ),
            placeholderStyle: TextStyle(
              color: ColorConstants.grey600,
              fontSize: MySize.getHeight(12 * fontScale),
            ),
          ),
        ),
        SizedBox(height: MySize.getHeight(14)),
        Text(
          TranslationKeys.enterPassword.tr,
          style: TextStyle(
            fontSize: MySize.getHeight(13 * fontScale),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: MySize.getHeight(5)),
        Obx(
          () => Stack(
            alignment: Alignment.centerRight,
            children: [
              SizedBox(
                height: MySize.getHeight(36 * fontScale),
                child: CommonTextField(
                  controller: controller.passwordController,
                  padding: EdgeInsets.only(
                    left: MySize.getWidth(12),
                    top: 0,
                    bottom: 0,
                    right: MySize.getWidth(45),
                  ),
                  placeholder: TranslationKeys.password.tr,
                  obscureText: !controller.isPasswordVisible.value,
                  style: TextStyle(
                    fontSize: MySize.getHeight(12 * fontScale),
                    color: Colors.black,
                  ),
                  placeholderStyle: TextStyle(
                    color: ColorConstants.grey600,
                    fontSize: MySize.getHeight(12 * fontScale),
                  ),
                ),
              ),
              Positioned(
                right: MySize.getWidth(12),
                child: GestureDetector(
                  onTap: controller.togglePasswordVisibility,
                  child: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: ColorConstants.grey600,
                    size: MySize.getHeight(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MySize.getHeight(20)),
        Obx(
          () => _PrimaryButton(
            label: TranslationKeys.login.tr,
            isLoading: controller.isLoading.value,
            fontScale: fontScale,
            onTap: () {
              FocusScope.of(context).unfocus();
              controller.login();
            },
          ),
        ),
      ],
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({
    required this.user,
    required this.isSelected,
    required this.fontScale,
    required this.onTap,
  });

  final RestaurantUser user;
  final bool isSelected;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(12),
          vertical: MySize.getHeight(7),
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorConstants.primaryColor
                  : ColorConstants.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(MySize.getHeight(20)),
          border: Border.all(
            color:
                isSelected
                    ? ColorConstants.primaryColor
                    : ColorConstants.primaryColor.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: MySize.getHeight(10),
              backgroundColor:
                  isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : ColorConstants.primaryColor.withValues(alpha: 0.2),
              child: Text(
                (user.name ?? 'U').substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: MySize.getHeight(9 * fontScale),
                  color:
                      isSelected ? Colors.white : ColorConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: MySize.getWidth(5)),
            Text(
              user.name ?? 'Unknown',
              style: TextStyle(
                fontSize: MySize.getHeight(12 * fontScale),
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.fontScale,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final double fontScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: MySize.getHeight(38 * fontScale),
        decoration: BoxDecoration(
          color:
              isLoading ? ColorConstants.grey600 : ColorConstants.primaryColor,
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        ),
        child: Center(
          child:
              isLoading
                  ? CupertinoActivityIndicator(
                    radius: MySize.getHeight(10),
                    color: Colors.white,
                  )
                  : Text(
                    label,
                    style: TextStyle(
                      fontSize: MySize.getHeight(16 * fontScale),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}

class RestaurantIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toUpperCase();
    text = text.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    String newString = '';
    for (int i = 0; i < text.length; i++) {
      if (i < 2) {
        if (RegExp(r'[A-Z]').hasMatch(text[i])) {
          newString += text[i];
        }
      } else {
        if (RegExp(r'[0-9]').hasMatch(text[i])) {
          newString += text[i];
        }
      }
    }

    if (newString.length > 2) {
      newString = '${newString.substring(0, 2)}-${newString.substring(2)}';
    } else if (newString.length == 2 &&
        oldValue.text.length <= newValue.text.length) {
      newString += '-';
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
