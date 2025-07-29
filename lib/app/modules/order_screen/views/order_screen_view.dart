import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/modules/order_screen/controllers/order_screen_controller.dart';

import '../../../constants/image_constants.dart';

class OrderScreenView extends GetView<OrderScreenController> {
  const OrderScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderScreenController>(
      init: OrderScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Order'),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          backgroundColor: ColorConstants.bgColor,
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MenuAnchor(
                              style: MenuStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                              ),
                              builder: (context, controllerMenu, child) {
                                return GestureDetector(
                                  onTap: () => controllerMenu.open(),
                                  child: Obx(() {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              controller
                                                  .getDropdownDisplayText(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                    );
                                  }),
                                );
                              },
                              menuChildren:
                                  controller.dateOptions.map((option) {
                                    return MenuItemButton(
                                      onPressed: () {
                                        controller.updateDateOption(option);
                                        if (option == 'Custom Date') {
                                          Future.delayed(
                                            const Duration(milliseconds: 10),
                                            () {
                                              controller
                                                  .showCustomDateRangePickerPop(
                                                    context,
                                                  );
                                            },
                                          );
                                        }
                                      },
                                      child: Text(option),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MenuAnchor(
                              style: MenuStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                              ),
                              builder: (context, controllerMenu, child) {
                                return GestureDetector(
                                  onTap: () => controllerMenu.open(),
                                  child: Obx(() {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            controller
                                                .selectedOrderFilter
                                                .value,
                                          ),
                                          const Icon(Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                    );
                                  }),
                                );
                              },
                              menuChildren:
                                  controller.orderFilterOptions.map((option) {
                                    return MenuItemButton(
                                      onPressed:
                                          () => controller.updateOrderFilter(
                                            option,
                                          ),
                                      child: Text(option),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        final selectedType = controller.selectedOrderType.value;
                        return Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildOrderTypeButton(
                                    icon: ImageConstant.dinein,
                                    label: 'Dine In',
                                    isSelected: selectedType == 'Dine In',
                                    onTap:
                                        () =>
                                            controller.selectedOrderType.value =
                                                'Dine In',
                                  ),
                                  _buildOrderTypeButton(
                                    icon: ImageConstant.Pickup,
                                    label: 'Pickup',
                                    isSelected: selectedType == 'Pickup',
                                    onTap:
                                        () =>
                                            controller.selectedOrderType.value =
                                                'Pickup',
                                  ),
                                  _buildOrderTypeButton(
                                    icon: ImageConstant.delivery,
                                    label: 'Delivery',
                                    isSelected: selectedType == 'Delivery',
                                    onTap:
                                        () =>
                                            controller.selectedOrderType.value =
                                                'Delivery',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = controller.orders[index];
                      return InkWell(
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          _showOrderBottomSheet(context, controller);
                        },
                        child: OrderCard(order: order),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderBottomSheet(
    BuildContext context,
    OrderScreenController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            builder:
                (_, scrollController) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorConstants.bgColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  child: SingleChildScrollView(child: Column(children: [])),
                ),
          ),
    );
  }

  Widget _buildOrderTypeButton({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorConstants.red.withOpacity(0.05)
                  : Colors.transparent,
          border: Border.all(
            color: isSelected ? ColorConstants.red : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Image.asset(icon, height: 20, width: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? ColorConstants.red : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Orders : ${order.id}",
                  style: const TextStyle(
                    color: ColorConstants.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _statusBadge(order.tag, order.tagColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${order.name} - ${order.type}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(radius: 5, backgroundColor: order.statusColor),
                    const SizedBox(width: 5),
                    Text(
                      order.statusText,
                      style: TextStyle(color: ColorConstants.grey800),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.datetime,
              style: TextStyle(color: ColorConstants.grey600, fontSize: 13),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Note : ${order.note}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "KOT # ${order.kot}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 20),
            Text(
              "Total : € ${order.total}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
