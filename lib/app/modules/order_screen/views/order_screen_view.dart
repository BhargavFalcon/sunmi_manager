import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/modules/order_screen/controllers/order_screen_controller.dart';
import 'package:managerapp/app/widgets/running_table_dialog.dart';
import 'package:managerapp/app/routes/app_pages.dart';

import '../../../constants/image_constants.dart';
import '../../../model/AllOrdersModel.dart' as orderModel;
import '../../../model/getorderModel.dart' as orderDetailsModel;

class OrderScreenView extends GetView<OrderScreenController> {
  const OrderScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OrderScreenController>()) {
      Get.put(OrderScreenController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<OrderScreenController>();
      controller.fetchAllOrders();
    });
    return GetBuilder<OrderScreenController>(
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Obx(() {
            return Stack(
              children: [
                Column(
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
                          "All Orders",
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
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                  Colors.white,
                                                ),
                                          ),
                                          builder: (
                                            context,
                                            controllerMenu,
                                            child,
                                          ) {
                                            return GestureDetector(
                                              onTap: () {
                                                if (controllerMenu.isOpen) {
                                                  controllerMenu.close();
                                                } else {
                                                  controllerMenu.open();
                                                }
                                              },
                                              child: Obx(() {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
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
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            );
                                          },
                                          menuChildren:
                                              controller.dateOptions.map((
                                                option,
                                              ) {
                                                return MenuItemButton(
                                                  onPressed: () {
                                                    controller.updateDateOption(
                                                      option,
                                                    );
                                                    if (option ==
                                                        'Custom Date') {
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
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                  Colors.white,
                                                ),
                                          ),
                                          builder: (
                                            context,
                                            controllerMenu,
                                            child,
                                          ) {
                                            return GestureDetector(
                                              onTap: () {
                                                if (controllerMenu.isOpen) {
                                                  controllerMenu.close();
                                                } else {
                                                  controllerMenu.open();
                                                }
                                              },
                                              child: Obx(() {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
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
                                                        Icons
                                                            .keyboard_arrow_down,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            );
                                          },
                                          menuChildren:
                                              controller.orderFilterOptions.map(
                                                (option) {
                                                  return MenuItemButton(
                                                    onPressed:
                                                        () => controller
                                                            .updateOrderFilter(
                                                              option,
                                                            ),
                                                    child: Text(option),
                                                  );
                                                },
                                              ).toList(),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                                    selectedType ==
                                                    'All Orders',
                                                onTap:
                                                    () => controller
                                                        .updateOrderType(
                                                          'All Orders',
                                                        ),
                                              ),
                                              _buildOrderTypeButton(
                                                icon: ImageConstant.dinein,
                                                label: 'Dine In',
                                                isSelected:
                                                    selectedType == 'Dine In',
                                                onTap:
                                                    () => controller
                                                        .updateOrderType(
                                                          'Dine In',
                                                        ),
                                              ),
                                              _buildOrderTypeButton(
                                                icon: ImageConstant.pickup,
                                                label: 'Pickup',
                                                isSelected:
                                                    selectedType == 'Pickup',
                                                onTap:
                                                    () => controller
                                                        .updateOrderType(
                                                          'Pickup',
                                                        ),
                                              ),
                                              _buildOrderTypeButton(
                                                icon: ImageConstant.delivery,
                                                label: 'Delivery',
                                                isSelected:
                                                    selectedType == 'Delivery',
                                                onTap:
                                                    () => controller
                                                        .updateOrderType(
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
                                return _buildOrderList(controller, context);
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (controller.isNavigatingToOrder.value)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CupertinoActivityIndicator(
                          radius: 12,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildOrderList(
    OrderScreenController controller,
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      color: ColorConstants.primaryColor,
      child: Obx(() {
        if (controller.allOrders.isEmpty && !controller.isLoading.value) {
          return const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: 400,
              child: Center(child: Text('No orders found')),
            ),
          );
        }
        return ListView.separated(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount:
              controller.allOrders.length +
              (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == controller.allOrders.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CupertinoActivityIndicator(
                    color: ColorConstants.primaryColor,
                  ),
                ),
              );
            }
            final order = controller.allOrders[index];
            return InkWell(
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                final isKotStatus = order.status?.toLowerCase() == 'kot';
                final hasTable = order.table != null && order.table!.id != null;
                if (isKotStatus && hasTable) {
                  RunningTableDialog.showRunningTablePopup(
                    context: context,
                    tableId: order.table!.id!,
                    onRefreshTables: () => controller.fetchAllOrders(),
                    onSetLoader:
                        (bool show) =>
                            controller.isNavigatingToOrder.value = show,
                    sourceScreen: Routes.ORDER_SCREEN,
                  );
                } else {
                  _showOrderBottomSheet(context, controller, order);
                }
              },
              child: OrderCard(order: order),
            );
          },
        );
      }),
    );
  }

  Future<void> _showOrderBottomSheet(
    BuildContext context,
    OrderScreenController controller,
    orderModel.Orders order,
  ) async {
    final orderUuid = order.uuid;
    if (orderUuid == null || orderUuid.isEmpty) {
      safeGetSnackbar('Error', 'Order UUID not found');
      return;
    }

    try {
      // Show loader first (like kot flow)
      controller.isNavigatingToOrder.value = true;

      // Fetch order details
      await controller.fetchOrderDetails(orderUuid);
    } finally {
      // Always hide loader even if error occurs
      controller.isNavigatingToOrder.value = false;
    }

    // Show bottom sheet after loader completes
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _buildBottomSheetContent(context, controller, order),
    );
  }

  Widget _buildBottomSheetContent(
    BuildContext context,
    OrderScreenController controller,
    orderModel.Orders order,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: ColorConstants.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Obx(() {
        final orderDetails = controller.orderDetails.value;
        final orderData = orderDetails?.data;

        if (orderData == null) {
          return _buildErrorView(context);
        }

        return _buildOrderDetailsContent(context, orderData, order);
      }),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Failed to load order details',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsContent(
    BuildContext context,
    orderDetailsModel.Data orderData,
    orderModel.Orders order,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(ImageConstant.order, height: 24, width: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #${orderData.orderNumber ?? order.id ?? ''} (${_formatOrderType(orderData.orderType)})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildOrderItemsTable(orderData),
            const SizedBox(height: 8),
            _buildPriceSummary(orderData),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorConstants.grey600),
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: const Text(
                  'Close',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatOrderType(String? orderType) {
    if (orderType == null || orderType.isEmpty) {
      return 'N/A';
    }
    switch (orderType.toLowerCase()) {
      case 'dine_in':
        return 'Dine In';
      case 'pickup':
        return 'Pickup';
      case 'delivery':
        return 'Delivery';
      default:
        return 'N/A';
    }
  }

  Widget _buildOrderItemsTable(orderDetailsModel.Data orderData) {
    final items = orderData.items ?? [];
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: ColorConstants.getShadow2,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No items found',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      );
    }
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
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemNumber = item.itemNumber ?? 'M${index + 1}';
            final modifiers = item.modifiers ?? [];
            final details =
                modifiers
                    .map(
                      (m) =>
                          '${m.name ?? ''}${m.price != null && m.price!.isNotEmpty ? ' : ${m.price}' : ''}',
                    )
                    .toList();
            if (item.variationName != null && item.variationName!.isNotEmpty) {
              details.insert(0, 'Variation: ${item.variationName}');
            }
            return _buildTableRow(
              itemName: item.itemName ?? 'N/A',
              details: details,
              qty: item.quantity?.toString() ?? '0',
              price: item.price ?? '0',
              amount: item.formattedAmount ?? item.amount ?? '0',
              itemNumber: itemNumber,
            );
          }).toList(),
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
    String itemNumber = 'M1',
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
            itemNumber,
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

  Widget _buildPriceSummary(orderDetailsModel.Data orderData) {
    final totals = orderData.totals;
    final itemsCount = orderData.items?.length ?? 0;

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
          Text(
            'Item(s)${itemsCount > 0 ? ' ($itemsCount)' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          if (totals?.subTotal != null)
            _buildPriceRow('Sub Total:', totals!.subTotal!),

          if (totals?.totalTaxAmount != null &&
              totals!.totalTaxAmount!.isNotEmpty)
            _buildPriceRow('Tax:', totals.totalTaxAmount!),

          if (totals?.discountAmount != null &&
              totals!.discountAmount!.isNotEmpty &&
              totals.discountAmount != 'null' &&
              totals.discountAmount != '0' &&
              totals.discountAmount != '0.0' &&
              totals.discountAmount != '0.00' &&
              double.tryParse(totals.discountAmount!) != null &&
              double.tryParse(totals.discountAmount!)! > 0)
            _buildPriceRow('Discount:', totals.discountAmount!),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),

          if (totals?.total != null)
            _buildPriceRow(
              'Total:',
              totals!.total!,
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

    final formattedDateTime = order.formattedDateTime;

    // Get items count
    final itemsCount = order.itemsCount ?? 0;

    final formattedPrice = order.formattedTotal;

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
                    formattedDateTime ?? '',
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
                  formattedPrice ?? '',
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
