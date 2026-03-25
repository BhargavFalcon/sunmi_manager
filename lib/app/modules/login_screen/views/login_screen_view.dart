import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/widgets/shared/common_text_field.dart';

import '../controllers/login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenController> {
  const LoginScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.bgColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom + MySize.getHeight(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(
                MySize.getWidth(8),
              ).copyWith(top: MySize.getHeight(200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Row(
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
                              fontSize: MySize.getHeight(25),
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: TranslationKeys.dine.tr,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'metrics'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(50)),
                  Container(
                    width: MySize.screenWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                      boxShadow: ColorConstants.getShadow2,
                    ),
                    padding: EdgeInsets.all(MySize.getWidth(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.login.tr,
                          style: TextStyle(
                            fontSize: MySize.getHeight(16),
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
                            fontSize: MySize.getHeight(14),
                            color: ColorConstants.grey600,
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(10)),
                        Text(
                          TranslationKeys.enterEmailOrUsername.tr,
                          style: TextStyle(
                            fontSize: MySize.getHeight(14),
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(5)),
                        SizedBox(
                          height: MySize.getHeight(35),
                          child: CommonTextField(
                            controller: controller.emailController,
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(12),
                              vertical: 0,
                            ),
                            placeholder: TranslationKeys.emailOrUsername.tr,
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(15)),
                        Text(
                          TranslationKeys.enterPassword.tr,
                          style: TextStyle(
                            fontSize: MySize.getHeight(14),
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(5)),
                        Obx(
                          () => Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              SizedBox(
                                height: MySize.getHeight(35),
                                child: CommonTextField(
                                  controller: controller.passwordController,
                                  padding: EdgeInsets.only(
                                    left: MySize.getWidth(12),
                                    top: 0,
                                    bottom: 0,
                                    right: MySize.getWidth(45),
                                  ),
                                  placeholder: TranslationKeys.password.tr,
                                  obscureText:
                                      !controller.isPasswordVisible.value,
                                ),
                              ),
                              Positioned(
                                right: MySize.getWidth(12),
                                child: GestureDetector(
                                  onTap: () {
                                    controller.togglePasswordVisibility();
                                  },
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
                          () => InkWell(
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap:
                                controller.isLoading.value
                                    ? null
                                    : () {
                                      FocusScope.of(context).unfocus();
                                      controller.login();
                                    },
                            child: Container(
                              width: double.infinity,
                              height: MySize.getHeight(35),
                              decoration: BoxDecoration(
                                color:
                                    controller.isLoading.value
                                        ? ColorConstants.grey600
                                        : ColorConstants.primaryColor,
                                borderRadius: BorderRadius.circular(
                                  MySize.getHeight(8),
                                ),
                              ),
                              child: Center(
                                child:
                                    controller.isLoading.value
                                        ? CupertinoActivityIndicator(
                                          radius: MySize.getHeight(10),
                                          color: Colors.white,
                                        )
                                        : Text(
                                          TranslationKeys.login.tr,
                                          style: TextStyle(
                                            fontSize: MySize.getHeight(18),
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
