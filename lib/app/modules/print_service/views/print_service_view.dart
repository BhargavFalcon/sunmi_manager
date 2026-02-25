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
            child: GetBuilder<PrintServiceController>(
              builder: (controller) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Connection Section ──────────────────────────────
                        Obx(() {
                          if (controller.isConnected.value &&
                              !controller.isConfiguring.value) {
                            if (controller.isSunmi.value) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                _buildConnectedStatus(),
                                SizedBox(height: MySize.getHeight(12)),
                              ],
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildConnectionSetup(),
                            );
                          }
                        }),

                        // ── Printing Rules Section ───────────────────────────
                        Container(
                          padding: EdgeInsets.all(12),
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
                                      activeThumbColor:
                                          ColorConstants.primaryColor,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    final isWifi =
                                        controller.isKitchenPrinterWifi;
                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: isWifi ? 1 : 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                TranslationKeys.printer.tr,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    hint: Text(
                                                      'Select Printer',
                                                    ),
                                                    value:
                                                        controller
                                                                .selectedKitchenPrinter
                                                                .value
                                                                .isEmpty
                                                            ? null
                                                            : controller
                                                                .selectedKitchenPrinter
                                                                .value,
                                                    items:
                                                        controller
                                                            .connectedPrinters
                                                            .map(
                                                              (
                                                                p,
                                                              ) => DropdownMenuItem(
                                                                value:
                                                                    p['name'],
                                                                child: Text(
                                                                  '${p['name']} (${p['type']})',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                    onChanged:
                                                        (v) => controller
                                                            .onPrinterSelected(
                                                              'kitchen',
                                                              v,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isWifi) ...[
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  TranslationKeys
                                                      .printerWidth
                                                      .tr,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton<
                                                      String
                                                    >(
                                                      isExpanded: true,
                                                      value:
                                                          controller
                                                              .kitchenPaperWidth
                                                              .value,
                                                      items:
                                                          ['58mm', '80mm']
                                                              .map(
                                                                (
                                                                  w,
                                                                ) => DropdownMenuItem(
                                                                  value: w,
                                                                  child: Text(
                                                                    w,
                                                                    softWrap:
                                                                        false,
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  }),
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
                                      activeThumbColor:
                                          ColorConstants.primaryColor,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    final isWifi =
                                        controller.isReceiptPrinterWifi;
                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: isWifi ? 1 : 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                TranslationKeys.printer.tr,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    hint: Text(
                                                      'Select Printer',
                                                    ),
                                                    value:
                                                        controller
                                                                .selectedReceiptPrinter
                                                                .value
                                                                .isEmpty
                                                            ? null
                                                            : controller
                                                                .selectedReceiptPrinter
                                                                .value,
                                                    items:
                                                        controller
                                                            .connectedPrinters
                                                            .map(
                                                              (
                                                                p,
                                                              ) => DropdownMenuItem(
                                                                value:
                                                                    p['name'],
                                                                child: Text(
                                                                  '${p['name']} (${p['type']})',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                    onChanged:
                                                        (v) => controller
                                                            .onPrinterSelected(
                                                              'receipt',
                                                              v,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isWifi) ...[
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  TranslationKeys
                                                      .printerWidth
                                                      .tr,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton<
                                                      String
                                                    >(
                                                      isExpanded: true,
                                                      value:
                                                          controller
                                                              .receiverPaperWidth
                                                              .value,
                                                      items:
                                                          ['58mm', '80mm']
                                                              .map(
                                                                (
                                                                  w,
                                                                ) => DropdownMenuItem(
                                                                  value: w,
                                                                  child: Text(
                                                                    w,
                                                                    softWrap:
                                                                        false,
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
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
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
        child: ElevatedButton(
          onPressed: () => controller.saveSettings(),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Widget _buildConnectionSetup() {
    return Container(
      padding: EdgeInsets.all(MySize.getHeight(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(MySize.getHeight(8)),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
                child: Icon(
                  Icons.wifi,
                  size: MySize.getHeight(20),
                  color: ColorConstants.primaryColor,
                ),
              ),
              SizedBox(width: MySize.getWidth(10)),
              Text(
                TranslationKeys.connection.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(16)),
          // API Key label
          Text(
            TranslationKeys.apiKey.tr,
            style: TextStyle(
              fontSize: MySize.getHeight(13),
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: MySize.getHeight(6)),
          // API Key TextField (full width)
          TextField(
            controller: controller.apiKeyController,
            style: TextStyle(
              fontSize: MySize.getHeight(14),
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(12),
                vertical: MySize.getHeight(14),
              ),
              hintText: TranslationKeys.apiKeyHint.tr,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: MySize.getHeight(13),
              ),
              prefixIcon: Icon(
                Icons.key_outlined,
                color: Colors.grey.shade400,
                size: MySize.getHeight(18),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MySize.getHeight(10)),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MySize.getHeight(10)),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MySize.getHeight(10)),
                borderSide: BorderSide(
                  color: ColorConstants.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: MySize.getHeight(14)),
          // Error message
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(bottom: MySize.getHeight(10)),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: MySize.getHeight(14),
                    ),
                    SizedBox(width: MySize.getWidth(4)),
                    Expanded(
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: MySize.getHeight(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // Connect button (full width)
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: MySize.getHeight(48),
              child: ElevatedButton.icon(
                onPressed:
                    controller.connectionLoading.value
                        ? null
                        : () => controller.testConnection(),
                icon:
                    controller.connectionLoading.value
                        ? SizedBox(
                          width: MySize.getHeight(18),
                          height: MySize.getHeight(18),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Icon(Icons.link, size: MySize.getHeight(20)),
                label: Text(
                  TranslationKeys.connection.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MySize.getHeight(10)),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          // Done button (shown after successful connection)
          Obx(() {
            if (controller.isConnected.value) {
              return Padding(
                padding: EdgeInsets.only(top: MySize.getHeight(10)),
                child: SizedBox(
                  width: double.infinity,
                  height: MySize.getHeight(48),
                  child: OutlinedButton.icon(
                    onPressed: () => controller.done(),
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: MySize.getHeight(20),
                    ),
                    label: Text(
                      TranslationKeys.done.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorConstants.successGreen,
                      side: BorderSide(color: ColorConstants.successGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(10),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildConnectedStatus() {
    return Container(
      padding: EdgeInsets.all(MySize.getHeight(8)),
      decoration: BoxDecoration(
        color: ColorConstants.successGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        border: Border.all(
          color: ColorConstants.successGreen.withValues(alpha: 0.35),
        ),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: MySize.getHeight(8),
                    height: MySize.getHeight(8),
                    decoration: const BoxDecoration(
                      color: ColorConstants.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(8)),
                  Icon(
                    Icons.wifi,
                    size: MySize.getHeight(20),
                    color: ColorConstants.successGreen,
                  ),
                  SizedBox(width: MySize.getWidth(8)),
                  Text(
                    TranslationKeys.connectedAndPolling.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => controller.toggleConfigure(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings,
                      size: MySize.getHeight(18),
                      color: ColorConstants.successGreen,
                    ),
                    SizedBox(width: MySize.getWidth(4)),
                    Text(
                      TranslationKeys.configure.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(10)),
          Text(
            '${TranslationKeys.key.tr}: ${controller.maskedApiKey}',
            style: TextStyle(
              fontSize: MySize.getHeight(13),
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
