import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/routes/app_pages.dart';

import '../controllers/setting_screen_controller.dart';

class SettingScreenView extends GetWidget<SettingScreenController> {
  const SettingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingScreenController>(
      init: SettingScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  12,
                ).copyWith(top: MediaQuery.of(context).padding.top + 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: Center(
                  child: Text(
                    "Setting",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.toNamed(Routes.PRINTER_SCREEN);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ColorConstants.primaryColor.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ColorConstants.primaryColor,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.print,
                                color: ColorConstants.primaryColor,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Printer",
                                style: TextStyle(
                                  color: ColorConstants.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: ColorConstants.primaryColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
