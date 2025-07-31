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
          body: Padding(
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
                        color: Colors.green,
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
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(
                                    () => Text(
                                      controller.selectedSuppliers.value,
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
                            controller.selectedSupplierList.map((time) {
                              return MenuItemButton(
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                    const Size(double.infinity, 48),
                                  ),
                                ),
                                onPressed: () {
                                  controller.selectedSuppliers.value = time;
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
                _buildOrderItemsTable(),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildOrderItemsTable() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: ColorConstants.getShadow2,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Table(
      columnWidths: const {
        0: FlexColumnWidth(0.6),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(0.8),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'NO.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'ITEM NAMES',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'QTY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'PRICE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'AMOUNT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        _buildTableRow(
          itemName: 'Turkey steak',
          details: [
            'M1   Food Type : Regular',
            'Spice level : Medium',
            'Test : Test 1',
          ],
          qty: '2',
          price: '€18.90',
          amount: '€37.80',
        ),
        _buildTableRow(
          itemName: 'Chili con carne (spice)',
          details: [],
          qty: '1',
          price: '€9.90',
          amount: '€9.90',
        ),
        _buildTableRow(
          itemName: 'Ramazzotti Rosato Tonic',
          details: [],
          qty: '1',
          price: '€6.80',
          amount: '€6.80',
        ),
        _buildTableRow(
          itemName: 'Vegan vegetable curry / tofu / basmati rice',
          details: [],
          qty: '2',
          price: '€12.90',
          amount: '€25.80',
        ),
        _buildTableRow(
          itemName: 'Vegan curricid sausage / french fries',
          details: [],
          qty: '2',
          price: '€10.90',
          amount: '€21.80',
        ),
        _buildTableRow(
          itemName: 'Tenderloin steak (ca. 200g)',
          details: [],
          qty: '3',
          price: '€25.90',
          amount: '€77.70',
        ),
      ],
    ),
  );
}

TableRow _buildTableRow({
  required String itemName,
  required List<String> details,
  required String qty,
  required String price,
  required String amount,
}) {
  return TableRow(
    decoration: const BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(color: Colors.grey, width: 0.5),
      ),
    ),
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'M1', // This can be dynamic based on the item index
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (details.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    details
                        .map(
                          (detail) => Text(
                            detail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
      Padding(padding: const EdgeInsets.all(8), child: Text(qty)),
      Padding(padding: const EdgeInsets.all(8), child: Text(price)),
      Padding(padding: const EdgeInsets.all(8), child: Text(amount)),
    ],
  );
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
