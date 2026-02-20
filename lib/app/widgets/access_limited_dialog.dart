import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import '../constants/translation_keys.dart';

class AccessLimitedDialog extends StatelessWidget {
  const AccessLimitedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MySize.getHeight(400)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    ImageConstant.access,
                    height: MySize.getHeight(70),
                  ),
                  SizedBox(height: MySize.getHeight(20)),
                  Text(
                    TranslationKeys.accessLimited.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(20),
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MySize.getHeight(12)),
                  Text(
                    TranslationKeys.featureNotEnabled.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(14),
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
