import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/modules/order_screen/controllers/order_screen_controller.dart';
import 'package:managerapp/app/routes/app_pages.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';

import '../../../constants/image_constants.dart';
import '../../../model/AllOrdersModel.dart' as orderModel;

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
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildOrderTypeButton(
                                          icon: ImageConstant.allOrders,
                                          label: 'All Orders',
                                          isSelected:
                                              selectedType == 'All Orders',
                                          onTap:
                                              () => controller.updateOrderType(
                                                'All Orders',
                                              ),
                                        ),
                                        _buildOrderTypeButton(
                                          icon: ImageConstant.dinein,
                                          label: 'Dine In',
                                          isSelected: selectedType == 'Dine In',
                                          onTap:
                                              () => controller.updateOrderType(
                                                'Dine In',
                                              ),
                                        ),
                                        _buildOrderTypeButton(
                                          icon: ImageConstant.pickup,
                                          label: 'Pickup',
                                          isSelected: selectedType == 'Pickup',
                                          onTap:
                                              () => controller.updateOrderType(
                                                'Pickup',
                                              ),
                                        ),
                                        _buildOrderTypeButton(
                                          icon: ImageConstant.delivery,
                                          label: 'Delivery',
                                          isSelected:
                                              selectedType == 'Delivery',
                                          onTap:
                                              () => controller.updateOrderType(
                                                'Delivery',
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
                        child: Obx(() {
                          if (controller.isLoading.value &&
                              controller.allOrders.isEmpty) {
                            return const Center(
                              child: CupertinoActivityIndicator(
                                color: ColorConstants.primaryColor,
                              ),
                            );
                          }
                          if (controller.allOrders.isEmpty &&
                              !controller.isLoading.value) {
                            return SmartRefresher(
                              controller: controller.refreshController,
                              enablePullDown: true,
                              enablePullUp: false,
                              onRefresh: controller.onRefresh,
                              header: CustomHeader(
                                height: 60.0,
                                builder: (
                                  BuildContext context,
                                  RefreshStatus? mode,
                                ) {
                                  Widget body;
                                  if (mode == RefreshStatus.idle) {
                                    body = const SizedBox.shrink();
                                  } else if (mode == RefreshStatus.refreshing) {
                                    body = const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: CupertinoActivityIndicator(
                                        color: ColorConstants.primaryColor,
                                      ),
                                    );
                                  } else if (mode == RefreshStatus.completed) {
                                    body = const SizedBox.shrink();
                                  } else if (mode == RefreshStatus.failed) {
                                    body = const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Text("Refresh Failed!"),
                                    );
                                  } else {
                                    body = const SizedBox.shrink();
                                  }
                                  return Container(
                                    alignment: Alignment.center,
                                    child: body,
                                  );
                                },
                              ),
                              child: const Center(
                                child: Text('No orders found'),
                              ),
                            );
                          }
                          return SmartRefresher(
                            controller: controller.refreshController,
                            enablePullDown: true,
                            enablePullUp: true,
                            onRefresh: controller.onRefresh,
                            onLoading: controller.onLoading,
                            header: CustomHeader(
                              height: 60.0,
                              builder: (
                                BuildContext context,
                                RefreshStatus? mode,
                              ) {
                                Widget body;
                                if (mode == RefreshStatus.idle) {
                                  body = const SizedBox.shrink();
                                } else if (mode == RefreshStatus.refreshing) {
                                  body = const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: CupertinoActivityIndicator(
                                      color: ColorConstants.primaryColor,
                                    ),
                                  );
                                } else if (mode == RefreshStatus.completed) {
                                  body = const SizedBox.shrink();
                                } else if (mode == RefreshStatus.failed) {
                                  body = const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: Text("Refresh Failed!"),
                                  );
                                } else {
                                  body = const SizedBox.shrink();
                                }
                                return Container(
                                  alignment: Alignment.center,
                                  child: body,
                                );
                              },
                            ),
                            footer: CustomFooter(
                              builder: (
                                BuildContext context,
                                LoadStatus? mode,
                              ) {
                                Widget body;
                                if (mode == LoadStatus.idle) {
                                  body = const SizedBox.shrink();
                                } else if (mode == LoadStatus.loading) {
                                  body = const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CupertinoActivityIndicator(
                                      color: ColorConstants.primaryColor,
                                    ),
                                  );
                                } else if (mode == LoadStatus.failed) {
                                  body = const Text("Load Failed!Click retry!");
                                } else if (mode == LoadStatus.canLoading) {
                                  body = const SizedBox.shrink();
                                } else {
                                  body = const SizedBox.shrink();
                                }
                                return SizedBox(
                                  height: 55.0,
                                  child: Center(child: body),
                                );
                              },
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: controller.allOrders.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final order = controller.allOrders[index];
                                return InkWell(
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    _showOrderBottomSheet(
                                      context,
                                      controller,
                                      order,
                                    );
                                  },
                                  child: OrderCard(order: order),
                                );
                              },
                            ),
                          );
                        }),
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
    orderModel.Orders order,
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
            'M1',
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

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),

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
    return _OrderTypeButtonItem(
      icon: icon,
      label: label,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class OrderCard extends StatelessWidget {
  final orderModel.Orders order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final tableCode = order.table?.tableCode ?? 'T${order.table?.id ?? ''}';

    final orderNumber =
        order.orderNumber?.toString() ?? order.id?.toString() ?? '';

    final customerName = order.customer?.name ?? 'test name';

    final status = order.status ?? 'PAID';
    final statusColor = _getStatusColor(status);
    final formattedStatus = _formatStatusText(status);

    // Get date time
    final dateTime = order.dateTime ?? order.createdAt ?? '';
    final formattedDateTime = _formatDateTime(dateTime);

    // Get items count
    final itemsCount = order.items?.length ?? 0;

    // Get total price
    final totalPrice = order.totals?.total ?? '0';
    final formattedPrice = CurrencyFormatter.formatPrice(totalPrice);

    // Get waiter name
    final waiterName = order.waiter?.name ?? '';

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
                  child:
                      order.orderType?.toLowerCase() == 'pickup'
                          ? Image.asset(
                            ImageConstant.pickup_all,
                            width: MySize.getHeight(20),
                            height: MySize.getHeight(20),
                          )
                          : order.orderType?.toLowerCase() == 'delivery'
                          ? Image.asset(
                            ImageConstant.delivery_all,
                            color: ColorConstants.primaryColor,
                            width: MySize.getHeight(20),
                            height: MySize.getHeight(20),
                          )
                          : Text(
                            tableCode,
                            style: TextStyle(
                              color: ColorConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: MySize.getHeight(12),
                            ),
                          ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Order #$orderNumber",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (order.customer != null)
                        Text(
                          customerName,
                          style: const TextStyle(
                            color: ColorConstants.grey600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                _statusBadge(formattedStatus, statusColor),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formattedDateTime,
                    style: TextStyle(
                      color: ColorConstants.grey600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  "$itemsCount Item(s)",
                  style: TextStyle(color: ColorConstants.grey600, fontSize: 13),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedPrice,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (waiterName.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(ImageConstant.order, width: 18, height: 18),
                      const SizedBox(width: 6),
                      Text(waiterName, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'PAID';
      case 'billed':
        return 'BILLED';
      case 'canceled':
      case 'cancelled':
        return 'CANCELED';
      case 'payment_due':
        return 'PAYMENT DUE';
      case 'kot':
        return 'KITCHEN';
      case 'pending_verification':
        return 'PENDING VERIFICATION';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return ColorConstants.statusPaid;
      case 'billed':
        return ColorConstants.statusBilled;
      case 'canceled':
      case 'cancelled':
        return ColorConstants.statusCanceled;
      case 'kot':
        return ColorConstants.statusKot;
      case 'payment_due':
        return ColorConstants.statusPaymentDue;
      case 'pending_verification':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '';
    try {
      final date = DateTime.parse(dateTime);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final month = months[date.month - 1];
      final day = date.day;
      final year = date.year;
      final hour = date.hour;
      final minute = date.minute;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return "$month ${day.toString().padLeft(2, '0')}, $year ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm";
    } catch (e) {
      return dateTime;
    }
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.0),
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

class _OrderTypeButtonItem extends StatefulWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeButtonItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OrderTypeButtonItem> createState() => _OrderTypeButtonItemState();
}

class _OrderTypeButtonItemState extends State<_OrderTypeButtonItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.3, 1.0)));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _OrderTypeButtonItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withValues(
                alpha: 0.1 * _backgroundAnimation.value,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorConstants.primaryColor.withValues(
                  alpha: _backgroundAnimation.value,
                ),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(widget.icon, height: MySize.getHeight(20)),
                ),
                SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
