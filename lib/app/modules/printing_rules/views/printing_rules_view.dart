import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import '../controllers/printing_rules_controller.dart';

class PrintingRulesView extends GetWidget<PrintingRulesController> {
  const PrintingRulesView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
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
                    TranslationKeys.printingRules.tr,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: MediaQuery.of(context).padding.top + 8,
                child: InkWell(
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
          Expanded(
            child: GetBuilder<PrintingRulesController>(
              builder: (controller) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: ColorConstants.getShadow2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      TranslationKeys.autoPrintKitchenTicket.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    return Switch(
                                      value: controller.autoPrintKitchen.value,
                                      onChanged:
                                          (value) =>
                                              controller
                                                  .toggleAutoPrintKitchen(),
                                      activeColor: ColorConstants.primaryColor,
                                    );
                                  }),
                                ],
                              ),
                              SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  TranslationKeys.autoPrintKitchenTicketDesc.tr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TranslationKeys.numberOfCopies.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Obx(() {
                                        return IconButton(
                                          onPressed:
                                              controller
                                                          .kitchenNumberOfCopies
                                                          .value >
                                                      1
                                                  ? () =>
                                                      controller
                                                          .decrementKitchenCopies()
                                                  : null,
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          color:
                                              controller
                                                          .kitchenNumberOfCopies
                                                          .value >
                                                      1
                                                  ? ColorConstants.primaryColor
                                                  : Colors.grey,
                                        );
                                      }),
                                      Obx(() {
                                        return Container(
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${controller.kitchenNumberOfCopies.value}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }),
                                      Obx(() {
                                        return IconButton(
                                          onPressed:
                                              controller
                                                          .kitchenNumberOfCopies
                                                          .value <
                                                      5
                                                  ? () =>
                                                      controller
                                                          .incrementKitchenCopies()
                                                  : null,
                                          icon: Icon(Icons.add_circle_outline),
                                          color:
                                              controller
                                                          .kitchenNumberOfCopies
                                                          .value <
                                                      5
                                                  ? ColorConstants.primaryColor
                                                  : Colors.grey,
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // --- Receipt: Auto print when order is paid ---
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      TranslationKeys
                                          .autoPrintReceiptWhenPaid
                                          .tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    return Switch(
                                      value:
                                          controller
                                              .autoPrintReceiptWhenPaid
                                              .value,
                                      onChanged:
                                          (value) =>
                                              controller
                                                  .toggleAutoPrintReceiptWhenPaid(),
                                      activeColor: ColorConstants.primaryColor,
                                    );
                                  }),
                                ],
                              ),
                              SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  TranslationKeys
                                      .autoPrintReceiptWhenPaidDesc
                                      .tr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TranslationKeys.numberOfCopies.tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Obx(() {
                                        return IconButton(
                                          onPressed:
                                              controller
                                                          .receiptNumberOfCopies
                                                          .value >
                                                      1
                                                  ? () =>
                                                      controller
                                                          .decrementReceiptCopies()
                                                  : null,
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          color:
                                              controller
                                                          .receiptNumberOfCopies
                                                          .value >
                                                      1
                                                  ? ColorConstants.primaryColor
                                                  : Colors.grey,
                                        );
                                      }),
                                      Obx(() {
                                        return Container(
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${controller.receiptNumberOfCopies.value}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }),
                                      Obx(() {
                                        return IconButton(
                                          onPressed:
                                              controller
                                                          .receiptNumberOfCopies
                                                          .value <
                                                      5
                                                  ? () =>
                                                      controller
                                                          .incrementReceiptCopies()
                                                  : null,
                                          icon: Icon(Icons.add_circle_outline),
                                          color:
                                              controller
                                                          .receiptNumberOfCopies
                                                          .value <
                                                      5
                                                  ? ColorConstants.primaryColor
                                                  : Colors.grey,
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
