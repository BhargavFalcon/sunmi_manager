import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';

import '../controllers/inventory_purchase_order_controller.dart';

class InventoryPurchaseOrderView
    extends GetView<InventoryPurchaseOrderController> {
  const InventoryPurchaseOrderView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.bgColor,
      body: Column(children: []),
    );
  }
}
