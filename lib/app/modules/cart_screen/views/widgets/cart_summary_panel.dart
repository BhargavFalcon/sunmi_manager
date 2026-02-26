import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';

import '../../controllers/cart_screen_controller.dart';

Widget summaryRow({
  required String label,
  required String value,
  bool bold = false,
  Color? valueColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: MySize.getHeight(15.0),
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: MySize.getHeight(15.0),
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: valueColor ?? Colors.black,
        ),
      ),
    ],
  );
}

class CartSummaryPanel extends StatelessWidget {
  const CartSummaryPanel({
    super.key,
    required this.controller,
    required this.onAddDiscount,
  });

  final CartScreenController controller;
  final VoidCallback onAddDiscount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        MySize.getWidth(16),
        MySize.getHeight(16),
        MySize.getWidth(16),
        MySize.getHeight(8),
      ),
      margin: EdgeInsets.all(MySize.getHeight(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MySize.getHeight(4.0)),
          summaryRow(
            label: TranslationKeys.total.tr,
            value: CurrencyFormatter.formatPriceFromDouble(
              controller.finalTotal,
            ),
            bold: true,
            valueColor: ColorConstants.primaryColor,
          ),
          Obx(() {
            if (controller.isDeliveryFree) {
              return Padding(
                padding: EdgeInsets.only(top: MySize.getHeight(4.0)),
                child: summaryRow(
                  label: TranslationKeys.deliveryCharge.tr,
                  value: 'Free',
                  bold: true,
                  valueColor: Colors.green,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          SizedBox(height: MySize.getHeight(8.0)),
          InkWell(
            onTap: () => controller.submitOrder(status: 'kot'),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: MySize.getHeight(8)),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.circular(MySize.getHeight(6)),
              ),
              child: Text(
                TranslationKeys.sendToKitchen.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(16.5),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
