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
                padding: EdgeInsets.all(MySize.getHeight(12)).copyWith(
                  top:
                      MediaQuery.of(context).padding.top + MySize.getHeight(12),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: Center(
                  child: Text(
                    TranslationKeys.printService.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(20),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: MySize.getWidth(12),
                top: MediaQuery.of(context).padding.top + MySize.getHeight(8),
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
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
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
              padding: EdgeInsets.all(MySize.getHeight(4)),
              child: Obx(() {
                if (controller.isConnected.value &&
                    !controller.isConfiguring.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildConnectedStatus(),
                      SizedBox(height: MySize.getHeight(8)),
                      _buildPrinterSetupSection(),
                    ],
                  );
                } else {
                  return _buildConnectionSetup();
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionSetup() {
    return Container(
      padding: EdgeInsets.all(MySize.getHeight(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi,
                size: MySize.getHeight(18),
                color: Colors.blueGrey,
              ),
              SizedBox(width: MySize.getWidth(8)),
              Text(
                TranslationKeys.connection.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.domainUrl.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(4)),
                    TextField(
                      controller: controller.domainController,
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(10),
                          vertical: MySize.getHeight(12),
                        ),
                        hintText: TranslationKeys.domainHint.tr,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: MySize.getHeight(13),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: MySize.getWidth(12)),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.apiKey.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(4)),
                    TextField(
                      controller: controller.apiKeyController,
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(10),
                          vertical: MySize.getHeight(12),
                        ),
                        hintText: TranslationKeys.apiKeyHint.tr,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: MySize.getHeight(13),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(8)),
          if (controller.errorMessage.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: MySize.getHeight(8)),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: MySize.getHeight(12),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : () => controller.testConnection(),
                  icon:
                      controller.isLoading.value
                          ? SizedBox(
                            width: MySize.getHeight(16),
                            height: MySize.getHeight(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(Icons.link, size: MySize.getHeight(18)),
                  label: Text(
                    TranslationKeys.testConnection.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.successGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: MySize.getHeight(14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              if (controller.isConnected.value) ...[
                SizedBox(width: MySize.getWidth(12)),
                SizedBox(
                  width: MySize.getWidth(100),
                  child: ElevatedButton.icon(
                    onPressed: () => controller.done(),
                    icon: Icon(Icons.check, size: MySize.getHeight(18)),
                    label: Text(
                      TranslationKeys.done.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: MySize.getHeight(14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(8),
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
            '${TranslationKeys.url.tr}: ${controller.domainController.text}',
            style: TextStyle(
              fontSize: MySize.getHeight(13),
              color: Colors.black87,
            ),
          ),
          SizedBox(height: MySize.getHeight(2)),
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

  Widget _buildPrinterSetupSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MySize.getHeight(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
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
                  Icon(
                    Icons.print,
                    size: MySize.getHeight(20),
                    color: Colors.black87,
                  ),
                  SizedBox(width: MySize.getWidth(8)),
                  Text(
                    TranslationKeys.printerSetup.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      controller.isFetchingPrinters.value
                          ? null
                          : () => controller.fetchPrinters(),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(14),
                      vertical: MySize.getHeight(8),
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor,
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                      boxShadow: ColorConstants.getShadow2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.isFetchingPrinters.value)
                          SizedBox(
                            width: MySize.getHeight(18),
                            height: MySize.getHeight(18),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          Icon(
                            Icons.refresh,
                            size: MySize.getHeight(16),
                            color: Colors.white,
                          ),
                        SizedBox(width: MySize.getWidth(6)),
                        Text(
                          TranslationKeys.refreshPrinters.tr,
                          style: TextStyle(
                            fontSize: MySize.getHeight(14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(14)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(12),
              vertical: MySize.getHeight(12),
            ),
            decoration: BoxDecoration(
              color: ColorConstants.tableBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(MySize.getHeight(8)),
              border: Border(
                left: BorderSide(color: ColorConstants.tableBlue, width: 4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: MySize.getHeight(20),
                  color: ColorConstants.tableBlue,
                ),
                SizedBox(width: MySize.getWidth(8)),
                Expanded(
                  child: Text(
                    TranslationKeys.mapEachKitchenToPrinter.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(12),
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (controller.printersFetchError.value.isNotEmpty) ...[
            SizedBox(height: MySize.getHeight(12)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(12),
                vertical: MySize.getHeight(12),
              ),
              decoration: BoxDecoration(
                color: ColorConstants.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                border: Border(
                  left: BorderSide(color: ColorConstants.red, width: 4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: MySize.getHeight(22),
                    color: ColorConstants.red,
                  ),
                  SizedBox(width: MySize.getWidth(8)),
                  Expanded(
                    child: Text(
                      '${TranslationKeys.failedToFetchPrinters.tr} ${controller.printersFetchError.value}',
                      style: TextStyle(
                        fontSize: MySize.getHeight(14),
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (controller.printersFetchError.value.isEmpty &&
              controller.printerMappings.isNotEmpty) ...[
            SizedBox(height: MySize.getHeight(16)),
            _buildPrinterMappingsTable(),
            SizedBox(height: MySize.getHeight(16)),
            _buildCashDrawerSettings(),
          ],
        ],
      ),
    );
  }

  Widget _buildPrinterMappingsTable() {
    final count = controller.printerMappings.length;
    final headerText = TranslationKeys.printerMappingsFound.tr.replaceFirst(
      '%s',
      count.toString(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: MySize.getHeight(12)),
          child: Text(
            headerText,
            style: TextStyle(
              fontSize: MySize.getHeight(15),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Obx(() {
          return Column(
            children: controller.printerMappings
                .asMap()
                .entries
                .map((e) => Padding(
                      padding: EdgeInsets.only(
                        bottom: e.key < controller.printerMappings.length - 1
                            ? MySize.getHeight(12)
                            : 0,
                      ),
                      child: _buildMappingCard(e.value),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildMappingCard(PrinterMappingModel mapping) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              MySize.getWidth(12),
              MySize.getHeight(10),
              MySize.getWidth(12),
              MySize.getHeight(8),
            ),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withValues(alpha: 0.06),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mapping.kitchenName,
                  style: TextStyle(
                    fontSize: MySize.getHeight(17),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                if (mapping.printerAlias != mapping.kitchenName) ...[
                  SizedBox(height: MySize.getHeight(2)),
                  Text(
                    mapping.printerAlias,
                    style: TextStyle(
                      fontSize: MySize.getHeight(13),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(12),
              vertical: MySize.getHeight(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationKeys.assignedLocalPrinter.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(12),
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: MySize.getHeight(6)),
                controller.localPrinterNames.isEmpty
                    ? Text(
                        '—',
                        style: TextStyle(
                          fontSize: MySize.getHeight(14),
                          color: Colors.grey,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(10),
                          vertical: MySize.getHeight(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius:
                              BorderRadius.circular(MySize.getHeight(8)),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: mapping.assignedLocalPrinter ??
                                controller.localPrinterNames.firstOrNull,
                            isExpanded: true,
                            selectedItemBuilder: (BuildContext context) {
                              return controller.localPrinterNames
                                  .map(
                                    (name) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(14),
                                        ),
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  )
                                  .toList();
                            },
                            items: controller.localPrinterNames
                                .map(
                                  (name) => DropdownMenuItem<String>(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(14),
                                      ),
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => controller
                                .setMappingAssignedPrinter(mapping.id, v),
                          ),
                        ),
                      ),
                SizedBox(height: MySize.getHeight(10)),
                Divider(height: 1, color: Colors.grey.shade200),
                SizedBox(height: MySize.getHeight(8)),
                Row(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: MySize.getHeight(22),
                          height: MySize.getHeight(22),
                          child: Checkbox(
                            value: mapping.isThermal,
                            onChanged: (v) => controller.setMappingThermal(
                                mapping.id, v ?? true),
                            activeColor: ColorConstants.tableBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(6)),
                        Text(
                          TranslationKeys.thermal.tr,
                          style: TextStyle(
                            fontSize: MySize.getHeight(14),
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.testPrint(mapping.id),
                        borderRadius: BorderRadius.circular(
                            MySize.getHeight(8)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: MySize.getWidth(12),
                            vertical: MySize.getHeight(8),
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.successGreen,
                            borderRadius: BorderRadius.circular(
                                MySize.getHeight(8)),
                            boxShadow: [
                              BoxShadow(
                                color: ColorConstants.successGreen
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.print_rounded,
                                size: MySize.getHeight(16),
                                color: Colors.white,
                              ),
                              SizedBox(width: MySize.getWidth(6)),
                              Text(
                                TranslationKeys.testPrint.tr,
                                style: TextStyle(
                                  fontSize: MySize.getHeight(14),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashDrawerSettings() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MySize.getHeight(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(12)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.cashDrawerSettings.tr,
            style: TextStyle(
              fontSize: MySize.getHeight(15),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: MySize.getHeight(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(8),
              vertical: MySize.getHeight(6),
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(MySize.getHeight(8)),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    TranslationKeys.openDrawerAfterPrint.tr,
                    style: TextStyle(
                      fontSize: MySize.getHeight(13),
                      color: Colors.black87,
                    ),
                  ),
                ),
                Obx(
                  () => Switch(
                    value: controller.openDrawerAfterPrint.value,
                    onChanged: controller.setOpenDrawerAfterPrint,
                    activeColor: ColorConstants.primaryColor,
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
