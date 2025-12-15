import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import '../controllers/printer_screen_controller.dart';

class PrinterScreenView extends GetWidget<PrinterScreenController> {
  const PrinterScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrinterScreenController>(
      init: PrinterScreenController(),
      assignId: true,
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
                        "Printer",
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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    controller.isLoading.value
                                        ? null
                                        : () => controller.printTestReceipt(),
                                icon: Icon(Icons.print),
                                label: Text('Test Print'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorConstants.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                        Obx(() {
                          if (controller.isConnected.value &&
                              controller.connectedDevice.value != null) {
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: ColorConstants.getShadow2,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Connected Printer',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  controller
                                                      .connectedDevice
                                                      .value!
                                                      .name,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  controller
                                                      .connectedDevice
                                                      .value!
                                                      .macAdress,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              Get.dialog(
                                                AlertDialog(
                                                  title: Text(
                                                    'Disconnect Printer',
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to disconnect?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Get.back(),
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Get.back();
                                                        controller
                                                            .disconnectDevice();
                                                      },
                                                      child: Text(
                                                        'Disconnect',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],
                            );
                          }
                          return SizedBox.shrink();
                        }),

                        // Printer Settings Section
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
                              Text(
                                'Printer Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 16),

                              // Auto-print Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Auto-print',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Obx(() {
                                    return Switch(
                                      value: controller.autoPrint.value,
                                      onChanged:
                                          (value) =>
                                              controller.toggleAutoPrint(),
                                      activeColor: ColorConstants.primaryColor,
                                    );
                                  }),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Number of Copies
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Number of copies',
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
                                              controller.numberOfCopies.value >
                                                      1
                                                  ? () =>
                                                      controller
                                                          .decrementCopies()
                                                  : null,
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          color:
                                              controller.numberOfCopies.value >
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
                                            '${controller.numberOfCopies.value}',
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
                                              controller.numberOfCopies.value <
                                                      5
                                                  ? () =>
                                                      controller
                                                          .incrementCopies()
                                                  : null,
                                          icon: Icon(Icons.add_circle_outline),
                                          color:
                                              controller.numberOfCopies.value <
                                                      5
                                                  ? ColorConstants.primaryColor
                                                  : Colors.grey,
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Printer Width Dropdown
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Printer width',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Obx(() {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ColorConstants.primaryColor,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButton<String>(
                                        value: controller.printerWidth.value,
                                        underline: SizedBox(),
                                        items:
                                            controller.printerWidthOptions.map((
                                              String width,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: width,
                                                child: Text(width),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            controller.setPrinterWidth(
                                              newValue,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Bluetooth Devices Section
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
                                  Text(
                                    'Bluetooth Printers',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Obx(() {
                                    return ElevatedButton.icon(
                                      onPressed:
                                          controller.isScanning.value
                                              ? null
                                              : () =>
                                                  controller.scanForDevices(),
                                      icon:
                                          controller.isScanning.value
                                              ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                              : Icon(Icons.bluetooth_searching),
                                      label: Text(
                                        controller.isScanning.value
                                            ? 'Scanning...'
                                            : 'Scan',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorConstants.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              SizedBox(height: 16),
                              Obx(() {
                                if (controller.isScanning.value &&
                                    controller.availableDevices.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        color: ColorConstants.primaryColor,
                                      ),
                                    ),
                                  );
                                }

                                if (controller.availableDevices.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.print_disabled,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'No printers found',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Tap Scan to search for Bluetooth printers',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: controller.availableDevices.length,
                                  itemBuilder: (context, index) {
                                    final device =
                                        controller.availableDevices[index];
                                    final isConnectedDevice =
                                        controller
                                            .connectedDevice
                                            .value
                                            ?.macAdress ==
                                        device.macAdress;

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color:
                                            isConnectedDevice
                                                ? ColorConstants.primaryColor
                                                    .withValues(alpha: 0.1)
                                                : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              isConnectedDevice
                                                  ? ColorConstants.primaryColor
                                                  : Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.print,
                                          color:
                                              isConnectedDevice
                                                  ? ColorConstants.primaryColor
                                                  : Colors.grey[700],
                                        ),
                                        title: Text(
                                          device.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isConnectedDevice
                                                    ? ColorConstants
                                                        .primaryColor
                                                    : Colors.black,
                                          ),
                                        ),
                                        subtitle: Text(
                                          device.macAdress,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        trailing:
                                            isConnectedDevice
                                                ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                )
                                                : Obx(() {
                                                  return controller
                                                          .isLoading
                                                          .value
                                                      ? SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color:
                                                              ColorConstants
                                                                  .primaryColor,
                                                        ),
                                                      )
                                                      : IconButton(
                                                        icon: Icon(
                                                          Icons.link,
                                                          color:
                                                              ColorConstants
                                                                  .primaryColor,
                                                        ),
                                                        onPressed:
                                                            () => controller
                                                                .connectToDevice(
                                                                  device,
                                                                ),
                                                      );
                                                }),
                                        onTap:
                                            isConnectedDevice
                                                ? null
                                                : () => controller
                                                    .connectToDevice(device),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
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
