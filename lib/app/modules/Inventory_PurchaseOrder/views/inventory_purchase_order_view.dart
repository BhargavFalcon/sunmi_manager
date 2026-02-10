import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

import '../controllers/inventory_purchase_order_controller.dart';

class InventoryPurchaseOrderView
    extends GetView<InventoryPurchaseOrderController> {
  const InventoryPurchaseOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryPurchaseOrderController>(
      init: InventoryPurchaseOrderController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: itemCount(
                          controller: controller,
                          icon: Icons.inventory_sharp,
                          title: "Total",
                          count: 3,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                      SizedBox(width: MySize.getWidth(8)),
                      Expanded(
                        child: itemCount(
                          controller: controller,
                          icon: Icons.pending_actions,
                          title: "Created",
                          count: 3,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: MySize.getWidth(8)),
                      Expanded(
                        child: itemCount(
                          controller: controller,
                          icon: Icons.check_circle_outline,
                          title: "Received",
                          count: 3,
                          color: ColorConstants.successGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MySize.getHeight(10)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: ColorConstants.getShadow2,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        CupertinoTextField(
                          placeholder: "Search Purchase Order",
                          placeholderStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: MySize.getHeight(12),
                          ),
                          cursorColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: ColorConstants.getShadow2,
                          ),
                          prefix: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.search, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(10)),
                        MenuAnchor(
                          style: MenuStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            maximumSize: WidgetStateProperty.all(
                              const Size(double.infinity, 200),
                            ),
                          ),
                          builder: (context, controllerAnchor, _) {
                            return GestureDetector(
                              onTap: controllerAnchor.open,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(
                                      () => Text(
                                        controller.selectedStatus.value,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                            );
                          },
                          menuChildren:
                              controller.selectedStatusList.map((time) {
                                return MenuItemButton(
                                  style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                      const Size(double.infinity, 48),
                                    ),
                                  ),
                                  onPressed: () {
                                    controller.selectedStatus.value = time;
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(time),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(10)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.supplierItem.length,
                    itemBuilder: (context, index) {
                      final item = controller.supplierItem[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: ColorConstants.getShadow2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['poNo'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['supplierName'] ?? '',
                                  style: const TextStyle(
                                    color: ColorConstants.grey600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item['date'] ?? '',
                                  style: const TextStyle(
                                    color: ColorConstants.grey600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        item['status'] == 'Created'
                                            ? Colors.blue.withValues(alpha: 0.1)
                                            : ColorConstants.successGreen
                                                .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['status'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          item['status'] == 'Created'
                                              ? Colors.blue
                                              : ColorConstants.successGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget itemCount({
  required InventoryPurchaseOrderController controller,
  required IconData? icon,
  required String? title,
  required int? count,
  required Color? color,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: ColorConstants.getShadow2,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color!.withValues(alpha: 0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: color, size: MySize.getHeight(16)),
          ),
        ),
        SizedBox(width: MySize.getWidth(10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title!, style: TextStyle(fontSize: MySize.getHeight(13))),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: MySize.getHeight(13),
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
