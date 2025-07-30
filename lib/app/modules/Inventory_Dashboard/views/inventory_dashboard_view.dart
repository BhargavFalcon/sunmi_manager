import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';

import '../controllers/inventory_dashboard_controller.dart';

class InventoryDashboardView extends GetView<InventoryDashboardController> {
  const InventoryDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryDashboardController>(
      init: InventoryDashboardController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: ColorConstants.getShadow2,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Category Filter
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Category Filter',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              MenuAnchor(
                                style: MenuStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.white,
                                  ),
                                  elevation: WidgetStateProperty.all(4),
                                  shadowColor: WidgetStateProperty.all(
                                    Colors.grey.shade300,
                                  ),
                                  maximumSize: WidgetStateProperty.all(
                                    const Size(double.infinity, 300),
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
                                              controller.selectedCategory.value,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                menuChildren:
                                    controller.categoryList.map((category) {
                                      return MenuItemButton(
                                        style: ButtonStyle(
                                          minimumSize: WidgetStateProperty.all(
                                            const Size(double.infinity, 48),
                                          ),
                                        ),
                                        onPressed: () {
                                          controller.selectedCategory.value =
                                              category;
                                        },
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(category),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Time Filter
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time Period',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              MenuAnchor(
                                style: MenuStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.white,
                                  ),
                                  elevation: WidgetStateProperty.all(4),
                                  shadowColor: WidgetStateProperty.all(
                                    Colors.grey.shade300,
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
                                              controller.selectedTime.value,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                menuChildren:
                                    controller.timeList.map((time) {
                                      return MenuItemButton(
                                        style: ButtonStyle(
                                          minimumSize: WidgetStateProperty.all(
                                            const Size(double.infinity, 48),
                                          ),
                                        ),
                                        onPressed: () {
                                          controller.selectedTime.value = time;
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: ColorConstants.getShadow2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Top Moving Inventory Items",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.inventoryItems.length,
                          itemBuilder: (context, index) {
                            final item = controller.inventoryItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorConstants.bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['category'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item['stock'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item['usage'] ?? '',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: ColorConstants.getShadow2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Low Stock Alerts",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ColorConstants.primaryColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '2 alerts',
                                style: TextStyle(
                                  color: ColorConstants.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.inventoryItems.length,
                          itemBuilder: (context, index) {
                            final item = controller.inventoryItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorConstants.primaryColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['category'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item['stock'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item['usage'] ?? '',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
