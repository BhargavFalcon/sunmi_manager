import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import '../model/getorderModel.dart' as orderModel;
import '../services/sunmi_invoice_printer_service.dart';
import '../constants/translation_keys.dart';
import '../constants/sizeConstant.dart';
import '../utils/order_helpers.dart' as helpers;
import '../widgets/shared/order_detail_widgets.dart';

class NewOrderDetailsBottomSheet {
  static final RxBool isPrinting = false.obs;

  static void show(orderModel.Data orderData) {
    final context = Get.context;
    if (context == null) return;

    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MySize.getHeight(16)),
        ),
      ),
      builder: (builderContext) {
        return _buildBottomSheetContent(
          builderContext,
          orderData,
          screenHeight,
        );
      },
    );
  }

  static Widget _buildBottomSheetContent(
    BuildContext context,
    orderModel.Data orderData,
    double screenHeight,
  ) {
    final orderDetails = orderData.order;
    if (orderDetails == null) {
      return Container(
        height: screenHeight * 0.8,
        decoration: BoxDecoration(
          color: ColorConstants.bgColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MySize.getHeight(16)),
          ),
          boxShadow: ColorConstants.getShadow2,
        ),
        child: Center(
          child: Text(
            TranslationKeys.noItemsFound.tr,
            style: TextStyle(
              fontSize: MySize.getHeight(14),
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      height: screenHeight * 0.8,
      decoration: BoxDecoration(
        color: ColorConstants.bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MySize.getHeight(16)),
        ),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: _buildOrderDetailsContent(
                context,
                orderData,
                orderDetails,
              ),
            ),
          ),
          _buildStickyButtons(context, orderData),
        ],
      ),
    );
  }

  static Widget _buildOrderDetailsContent(
    BuildContext context,
    orderModel.Data orderData,
    orderModel.Order orderDetails,
  ) {
    return Padding(
      padding: EdgeInsets.all(MySize.getHeight(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${orderDetails.formattedOrderNumber ?? orderDetails.id?.toString() ?? ''} (${helpers.formatOrderType(orderDetails.orderType)})',
                  style: TextStyle(
                    fontSize: MySize.getHeight(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(8)),
          OrderDetailWidgets.buildOrderTimeInfo(orderDetails, fontSize: 12),
          SizedBox(height: MySize.getHeight(8)),
          if (orderDetails.customer != null &&
              helpers.hasCustomerInfo(orderDetails.customer!))
            OrderDetailWidgets.buildCustomerDetails(
              orderDetails.customer!,
              fontSize: 12,
              titleFontSize: 14,
            ),
          if (orderDetails.customer != null &&
              helpers.hasCustomerInfo(orderDetails.customer!))
            SizedBox(height: MySize.getHeight(8)),
          Builder(
            builder: (context) {
              final shouldShowWaiter =
                  (orderDetails.customer == null ||
                      !helpers.hasCustomerInfo(orderDetails.customer)) &&
                  helpers.isDineInOrder(orderDetails.orderType) &&
                  helpers.hasWaiterInfo(orderDetails.waiter);

              if (!shouldShowWaiter) return const SizedBox.shrink();

              return Column(
                children: [
                  OrderDetailWidgets.buildWaiterDetails(
                    orderDetails.waiter!,
                    fontSize: 12,
                    titleFontSize: 14,
                  ),
                  SizedBox(height: MySize.getHeight(8)),
                ],
              );
            },
          ),
          OrderDetailWidgets.buildOrderItemsTable(
            orderData,
            fontSize: 12,
            headerFontSize: 10,
          ),
          SizedBox(height: MySize.getHeight(8)),
          OrderDetailWidgets.buildPriceSummary(
            orderData,
            fontSize: 12,
            titleFontSize: 14,
          ),
          SizedBox(height: MySize.getHeight(16)),
        ],
      ),
    );
  }

  static Widget _buildStickyButtons(
    BuildContext context,
    orderModel.Data orderData,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MySize.getHeight(8),
        left: MySize.getWidth(16),
        right: MySize.getWidth(16),
        bottom: MySize.getHeight(10),
      ),
      decoration: BoxDecoration(
        color: ColorConstants.bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: MySize.getHeight(4),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(MySize.getHeight(12)),
                decoration: BoxDecoration(
                  color: const Color(0xFF60616E),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: Text(
                  TranslationKeys.close.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MySize.getHeight(14),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              final printing = isPrinting.value;
              return InkWell(
                onTap: printing ? null : () => _printInvoice(orderData),
                child: Container(
                  padding: EdgeInsets.all(MySize.getHeight(12)),
                  decoration: BoxDecoration(
                    color:
                        printing
                            ? const Color(0xFF0E9F6E).withOpacity(0.7)
                            : const Color(0xFF0E9F6E),
                    borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (printing)
                        CupertinoActivityIndicator(
                          radius: MySize.getHeight(8),
                          color: Colors.white,
                        )
                      else
                        Icon(
                          Icons.print,
                          color: Colors.white,
                          size: MySize.getHeight(18),
                        ),
                      if (!printing) SizedBox(width: MySize.getWidth(6)),
                      if (!printing)
                        Text(
                          TranslationKeys.print.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(14),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  static Future<void> _printInvoice(orderModel.Data orderData) async {
    if (Platform.isIOS) {
      safeGetSnackbar(
        TranslationKeys.warning.tr,
        TranslationKeys.printOnlyAvailableOnAndroid.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade700,
      );
      return;
    }

    if (orderData.order == null) {
      return;
    }

    try {
      isPrinting.value = true;
      final printerService = SunmiInvoicePrinterService();
      await printerService.printInvoice(orderData);
    } catch (e) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.somethingWentWrong.tr,
      );
    } finally {
      isPrinting.value = false;
    }
  }
}
