import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

import '../controllers/login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenController> {
  const LoginScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.bgColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(top: 200),
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
                      const SizedBox(width: 3),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 25, color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Dine',
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
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
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
                        "Welcome back! Please enter your details.",
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorConstants.grey600,
                        ),
                      ),
                      SizedBox(height: MySize.getHeight(10)),
                      Text(
                        "Enter your email or username",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: MySize.getHeight(5)),
                      CupertinoTextField(
                        controller: controller.emailController,
                        padding: const EdgeInsets.all(12),
                        placeholder: "Email or Username",
                        placeholderStyle: TextStyle(
                          color: ColorConstants.grey600,
                          fontSize: 14,
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        decoration: BoxDecoration(
                          color: ColorConstants.bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ColorConstants.grey600,
                            width: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: MySize.getHeight(15)),
                      Text(
                        "Enter your password",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: MySize.getHeight(5)),
                      CupertinoTextField(
                        controller: controller.passwordController,
                        padding: const EdgeInsets.all(12),
                        placeholder: "Password",
                        placeholderStyle: TextStyle(
                          color: ColorConstants.grey600,
                          fontSize: 14,
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        obscureText: true,
                        decoration: BoxDecoration(
                          color: ColorConstants.bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ColorConstants.grey600,
                            width: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: MySize.getHeight(20)),
                      Obx(
                        () => InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: controller.isLoading.value
                              ? null
                              : () {
                                  controller.login();
                                },
                          child: Container(
                            width: MySize.screenWidth,
                            height: MySize.getHeight(35),
                            decoration: BoxDecoration(
                              color: controller.isLoading.value
                                  ? ColorConstants.grey600
                                  : ColorConstants.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 16,
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
    );
  }
}
