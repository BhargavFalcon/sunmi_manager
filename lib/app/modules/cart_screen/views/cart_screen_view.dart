import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

import '../controllers/cart_screen_controller.dart';

class CartScreenView extends GetWidget<CartScreenController> {
  const CartScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartScreenController>(
      assignId: true,
      init: CartScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Column(
            children: [
              Stack(
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
                        "Cart",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: MediaQuery.of(context).padding.top + 8,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: MySize.getHeight(30),
                        width: MySize.getHeight(30),
                        decoration: BoxDecoration(
                          color: ColorConstants.primaryColor.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: ColorConstants.primaryColor,
                          size: MySize.getHeight(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.grey.withValues(alpha: 0.2),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                height: MySize.getHeight(28),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MySize.getHeight(80),
                        child: Text(
                          "NUMBER",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(11),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MySize.getHeight(100),
                        child: Text(
                          "ITEM NAME",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(11),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MySize.getHeight(100),
                        child: Text(
                          "QTY",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(11),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MySize.getHeight(100),
                        child: Text(
                          "AMOUNT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(11),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MySize.getHeight(50),
                        child: Text(
                          "ACTION",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(11),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: Row(children: []),
              ),
            ],
          ),
        );
      },
    );
  }
}
