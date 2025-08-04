import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/modules/Inventory_Dashboard/views/inventory_dashboard_view.dart';
import 'package:managerapp/app/modules/Inventory_PurchaseOrder/views/inventory_purchase_order_view.dart';

import '../controllers/inventory_screen_controller.dart';

class InventoryScreenView extends GetView<InventoryScreenController> {
  const InventoryScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryScreenController>(
      assignId: true,
      init: InventoryScreenController(),
      builder: (controller) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: ColorConstants.bgColor,
            appBar: AppBar(
              title: const Text(
                'Inventory',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              bottom: TabBar(
                splashFactory: NoSplash.splashFactory,
                controller: controller.tabController,
                indicatorColor: ColorConstants.primaryColor,
                labelColor: ColorConstants.primaryColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Purchase Order'),
                ],
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller.tabController,
              children: const [
                InventoryDashboardView(),
                InventoryPurchaseOrderView(),
              ],
            ),
          ),
        );
      },
    );
  }
}
