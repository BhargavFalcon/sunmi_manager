import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/modules/order_screen/controllers/order_screen_controller.dart';
import 'package:managerapp/app/routes/app_pages.dart';

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
          backgroundColor: ColorConstants.bgColor,
          body: Column(
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
                    "Order",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
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
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    controller
                                                        .getDropdownDisplayText(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.keyboard_arrow_down,
                                                ),
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
                                              controller.updateDateOption(
                                                option,
                                              );
                                              if (option == 'Custom Date') {
                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 10,
                                                  ),
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
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  controller
                                                      .selectedOrderFilter
                                                      .value,
                                                ),
                                                const Icon(
                                                  Icons.keyboard_arrow_down,
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                    menuChildren:
                                        controller.orderFilterOptions.map((
                                          option,
                                        ) {
                                          return MenuItemButton(
                                            onPressed:
                                                () => controller
                                                    .updateOrderFilter(option),
                                            child: Text(option),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Obx(() {
                              final selectedType =
                                  controller.selectedOrderType.value;
                              return Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: _buildOrderTypeButton(
                                            icon: ImageConstant.dinein,
                                            label: 'Dine In',
                                            isSelected:
                                                selectedType == 'Dine In',
                                            onTap:
                                                () =>
                                                    controller
                                                        .selectedOrderType
                                                        .value = 'Dine In',
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildOrderTypeButton(
                                            icon: ImageConstant.Pickup,
                                            label: 'Pickup',
                                            isSelected:
                                                selectedType == 'Pickup',
                                            onTap:
                                                () =>
                                                    controller
                                                        .selectedOrderType
                                                        .value = 'Pickup',
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildOrderTypeButton(
                                            icon: ImageConstant.delivery,
                                            label: 'Delivery',
                                            isSelected:
                                                selectedType == 'Delivery',
                                            onTap:
                                                () =>
                                                    controller
                                                        .selectedOrderType
                                                        .value = 'Delivery',
                                          ),
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
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: controller.orders.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
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
              ),
            ],
          ),
          floatingActionButton: InkWell(
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () => Get.toNamed(Routes.TAKE_ORDER_SCREEN),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: ColorConstants.getShadow2,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        ImageConstant.order,
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Order #386 (Dine In)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildOrderItemsTable(),
                              const SizedBox(height: 8),
                              _buildPriceSummary(),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: ColorConstants.grey600,
                                    ),
                                    boxShadow: ColorConstants.getShadow2,
                                  ),
                                  child: const Text(
                                    'Cancle',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
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
              Text(
                itemName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item(s) header only
          const Text(
            'Item(s)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Price details
          _buildPriceRow('Sub Total:', '\$179.80'),
          _buildPriceRow(
            'Food and Drinks Tax:',
            'Consumption & Excise Tax (11.5%)',
            isSecondary: true,
          ),
          _buildPriceRow('Packaging Tax (0%):', '€19.90'),
          _buildPriceRow(
            'Beverage Sales Tax:',
            'Consumption Tax (19%): €12.9',
            isSecondary: true,
          ),
          _buildPriceRow('Excise Tax (12%):', '€0.80'),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),

          // Total row
          _buildPriceRow(
            'Total:',
            '€201.81',
            isBold: true,
            valueColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    bool isSecondary = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSecondary ? 12 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSecondary ? 12 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorConstants.primaryColor.withValues(alpha: 0.05)
                  : Colors.transparent,
          border: Border.all(
            color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon, height: 20, width: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? ColorConstants.primaryColor : Colors.grey.shade700,
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
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: ColorConstants.primaryColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "T1",
                    style: TextStyle(
                      color: ColorConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID: ${order.id}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        color: ColorConstants.grey600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _statusBadge(order.tag, order.tagColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.datetime,
              style: TextStyle(color: ColorConstants.grey600, fontSize: 13),
            ),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "€ ${order.total}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageConstant.order, width: 18, height: 18),
                    const SizedBox(width: 6),
                    Text(
                      order.customerName,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
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
        color: color.withValues(alpha: 0.15),
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
