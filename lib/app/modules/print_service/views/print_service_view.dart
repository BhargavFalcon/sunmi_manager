import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import '../controllers/print_service_controller.dart';

class PrintServiceView extends GetWidget<PrintServiceController> {
  const PrintServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return Scaffold(
      backgroundColor: ColorConstants.bgColor,
      body: Column(
        children: [
          // ── App Bar ──
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
                    TranslationKeys.printService.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: MediaQuery.of(context).padding.top + 8,
                child: InkWell(
                  onTap: () => Get.back(),
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

          // ── Main Content ──
          Expanded(
            child: GetBuilder<PrintServiceController>(
              builder: (controller) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Internal Sunmi Printer Info Banner ──
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: ColorConstants.getShadow2,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ColorConstants.successGreen
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.print,
                                  color: ColorConstants.successGreen,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      TranslationKeys.internalSunmiPrinter.tr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      TranslationKeys.connectedAndReady.tr,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: ColorConstants.successGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ══════════════════════════════════════════════
                        // 1) Customer Receipt Print Settings (Order - Top)
                        // ══════════════════════════════════════════════
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: ColorConstants.getShadow2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorConstants.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_outlined,
                                      color: ColorConstants.primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    TranslationKeys.autoPrintReceiptWhenPaid.tr,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Auto Print Receipt Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      TranslationKeys
                                          .autoPrintReceiptWhenPaid
                                          .tr,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    return Switch(
                                      value: controller
                                          .autoPrintReceiptWhenPaid.value,
                                      onChanged: (_) => controller
                                          .toggleAutoPrintReceiptWhenPaid(),
                                      activeThumbColor:
                                          ColorConstants.primaryColor,
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                TranslationKeys.autoPrintReceiptWhenPaidDesc.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Number of Copies
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TranslationKeys.numberOfCopies.tr,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Obx(() {
                                        final copies = controller
                                            .receiptNumberOfCopies.value;
                                        return IconButton(
                                          onPressed: copies > 1
                                              ? () => controller
                                                  .decrementReceiptCopies()
                                              : null,
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          color: copies > 1
                                              ? ColorConstants.primaryColor
                                              : Colors.grey,
                                        );
                                      }),
                                      Obx(() {
                                        return Container(
                                          width: 36,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${controller.receiptNumberOfCopies.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }),
                                      Obx(() {
                                        final copies = controller
                                            .receiptNumberOfCopies.value;
                                        return IconButton(
                                          onPressed: copies < 5
                                              ? () => controller
                                                  .incrementReceiptCopies()
                                              : null,
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                          color: copies < 5
                                              ? ColorConstants.primaryColor
                                              : Colors.grey,
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Paper Width (Receipt)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TranslationKeys.printerWidth.tr,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Obx(() {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: controller
                                              .receiverPaperWidth.value,
                                          items: ['58mm', '80mm']
                                              .map(
                                                (w) => DropdownMenuItem(
                                                  value: w,
                                                  child: Text(
                                                    w,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) {
                                            if (v != null) {
                                              controller
                                                  .receiverPaperWidth
                                                  .value = v;
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ══════════════════════════════════════════════
                        // 2) Kitchen Ticket (KOT) Print Settings (Bottom)
                        // ══════════════════════════════════════════════
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: ColorConstants.getShadow2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorConstants.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.kitchen_outlined,
                                      color: ColorConstants.primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    TranslationKeys.kitchenTickets.tr,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Auto Print KOT Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      TranslationKeys.autoPrintKitchenTicket.tr,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    return Switch(
                                      value: controller.autoPrintKitchen.value,
                                      onChanged: (_) => controller
                                          .toggleAutoPrintKitchen(),
                                      activeThumbColor:
                                          ColorConstants.primaryColor,
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                TranslationKeys.autoPrintKitchenTicketDesc.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Number of Copies
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TranslationKeys.numberOfCopies.tr,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Obx(() {
                                        final copies = controller
                                            .kitchenNumberOfCopies.value;
                                        return IconButton(
                                          onPressed: copies > 1
                                              ? () => controller
                                                  .decrementKitchenCopies()
                                              : null,
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          color: copies > 1
                                              ? ColorConstants.primaryColor
                                              : Colors.grey,
                                        );
                                      }),
                                      Obx(() {
                                        return Container(
                                          width: 36,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${controller.kitchenNumberOfCopies.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }),
                                      Obx(() {
                                        final copies = controller
                                            .kitchenNumberOfCopies.value;
                                        return IconButton(
                                          onPressed: copies < 5
                                              ? () => controller
                                                  .incrementKitchenCopies()
                                              : null,
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                          color: copies < 5
                                              ? ColorConstants.primaryColor
                                              : Colors.grey,
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Paper Width (KOT)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TranslationKeys.printerWidth.tr,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Obx(() {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: controller
                                              .kitchenPaperWidth.value,
                                          items: ['58mm', '80mm']
                                              .map(
                                                (w) => DropdownMenuItem(
                                                  value: w,
                                                  child: Text(
                                                    w,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) {
                                            if (v != null) {
                                              controller
                                                  .kitchenPaperWidth
                                                  .value = v;
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }),
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

          // ── Bottom Save Button ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 8
                  : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.saveSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  TranslationKeys.save.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
