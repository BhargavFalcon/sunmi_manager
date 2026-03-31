import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/widgets/app_toast.dart';
import 'package:managerapp/app/modules/order_screen/controllers/order_screen_controller.dart';
import 'package:managerapp/app/widgets/running_table_dialog.dart';
import 'package:managerapp/app/widgets/access_limited_dialog.dart';
import 'package:managerapp/app/widgets/payment_receipt_dialog.dart';
import 'package:managerapp/app/routes/app_pages.dart';

import 'package:managerapp/main.dart';
import 'package:managerapp/app/services/printer_service.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/image_constants.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/all_orders_model.dart' as order_model;
import '../../../model/get_order_model.dart' as order_details_model;
import '../../../model/receipt_order_response_model.dart';
import '../../../services/sunmi_invoice_printer_service.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/date_time_formatter.dart';
import '../../../utils/order_helpers.dart' as helpers;
import '../../../widgets/shared/order_detail_widgets.dart';

// Static helper functions for placed_via badge colors and text
Color _getPlacedViaColorStatic(String placedVia) {
  switch (placedVia.toLowerCase()) {
    case 'ios':
      return const Color(0xFF4A4A4A); // Charcoal/dark grey
    case 'android':
      return ColorConstants.statusPaid; // Green like paid
    case 'pos':
      return ColorConstants.primaryColor; // Dinemetrics pink
    case 'qr':
      return Colors.orange; // Yellow/Orange like kitchen
    case 'shop':
      return ColorConstants.statusBilled; // Blue like billed
    default:
      return Colors.grey;
  }
}

String _formatPlacedViaTextStatic(String placedVia) {
  switch (placedVia.toLowerCase()) {
    case 'ios':
      return 'iOS'; // Proper iOS formatting
    default:
      return placedVia.toUpperCase();
  }
}


class OrderScreenView extends GetView<OrderScreenController> {
  const OrderScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    if (!Get.isRegistered<OrderScreenController>()) {
      Get.put(OrderScreenController());
    }
    return GetBuilder<OrderScreenController>(
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Obx(() {
            return Stack(
              children: [
                IgnorePointer(
                  ignoring: controller.showAccessDialog.value,
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(MySize.getHeight(8)),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(MySize.getHeight(5)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    MySize.getHeight(12),
                                  ),
                                  boxShadow: ColorConstants.getShadow2,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Date Filter
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
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              MySize.getWidth(
                                                                8,
                                                              ),
                                                          vertical:
                                                              MySize.getHeight(
                                                                6,
                                                              ),
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                        width: 1.5,
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
                                                            _translateDateOption(
                                                              controller
                                                                  .getDropdownDisplayText(),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  MySize.getHeight(
                                                                    13,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          size:
                                                              MySize.getHeight(
                                                                20,
                                                              ),
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
                                                      controller
                                                          .updateDateOption(
                                                            option,
                                                          );
                                                      if (option ==
                                                          'Custom Date') {
                                                        Future.delayed(
                                                          const Duration(
                                                            milliseconds: 10,
                                                          ),
                                                          () {
                                                            if (context
                                                                .mounted) {
                                                              controller
                                                                  .showCustomDateRangePickerPop(
                                                                    context,
                                                                  );
                                                            }
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      _translateDateOption(
                                                        option,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize:
                                                            MySize.getHeight(
                                                              13,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                        SizedBox(width: MySize.getWidth(4)),
                                        // Status Filter
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
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              MySize.getWidth(
                                                                8,
                                                              ),
                                                          vertical:
                                                              MySize.getHeight(
                                                                6,
                                                              ),
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                        width: 1.5,
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
                                                            _translateOrderFilter(
                                                              controller
                                                                  .selectedOrderFilter
                                                                  .value,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  MySize.getHeight(
                                                                    13,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          size:
                                                              MySize.getHeight(
                                                                20,
                                                              ),
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
                                                            .updateOrderFilter(
                                                              option,
                                                            ),
                                                    child: Text(
                                                      _translateOrderFilter(
                                                        option,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize:
                                                            MySize.getHeight(
                                                              13,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: MySize.getHeight(8)),
                                    Obx(() {
                                      final selectedStatus =
                                          controller.selectedLocalStatus.value;
                                      return Container(
                                        height: MySize.getHeight(45),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            MySize.getHeight(8),
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            MySize.getHeight(8),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildStatusTab(
                                                label: TranslationKeys.newStatus.tr,
                                                isSelected: selectedStatus == 'New',
                                                onTap: () => controller.selectedLocalStatus.value = 'New',
                                              ),
                                              _buildStatusTab(
                                                label: TranslationKeys.preparingStatus.tr,
                                                isSelected: selectedStatus == 'Preparing',
                                                onTap: () => controller.selectedLocalStatus.value = 'Preparing',
                                              ),
                                              _buildStatusTab(
                                                label: TranslationKeys.readyStatus.tr,
                                                isSelected: selectedStatus == 'Ready',
                                                onTap: () => controller.selectedLocalStatus.value = 'Ready',
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              SizedBox(height: MySize.getHeight(12)),
                              Expanded(
                                child: Obx(() {
                                  if (controller.isLoading.value &&
                                      controller.allOrders.isEmpty) {
                                    return Center(
                                      child: CupertinoActivityIndicator(
                                        radius: MySize.getHeight(8),
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
                ),
                if (controller.isNavigatingToOrder.value)
                  Container(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(MySize.getWidth(12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CupertinoActivityIndicator(
                          radius: MySize.getHeight(8),
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                if (controller.showAccessDialog.value)
                  const AccessLimitedDialog(),
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
        final filteredList = controller.filteredOrdersByLocalStatus;
        if (filteredList.isEmpty && !controller.isLoading.value) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MySize.getHeight(400),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      ImageConstant.emptyBox,
                      color: Colors.grey.shade400,
                      width: MySize.getWidth(120),
                      height: MySize.getHeight(120),
                    ),
                    Text(
                      TranslationKeys.noOrdersFound.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(17),
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount:
              filteredList.length +
              (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: MySize.getHeight(10)),
          itemBuilder: (context, index) {
            if (index == filteredList.length) {
              return Padding(
                padding: EdgeInsets.all(MySize.getWidth(16)),
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: MySize.getHeight(8),
                    color: ColorConstants.primaryColor,
                  ),
                ),
              );
            }
            final order = filteredList[index];
            return InkWell(
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                final status = order.status?.toLowerCase() ?? '';
                final isKotStatus = status == 'kot';
                final isBilledStatus = status == 'billed';
                final hasTable = order.table != null && order.table!.id != null;
                final isDeliveryOrPickup =
                    order.orderType?.toLowerCase() == 'delivery' ||
                    order.orderType?.toLowerCase() == 'pickup';
                final isCounter = order.orderType?.toLowerCase() == 'counter';
                final showRunningDialog =
                    isKotStatus &&
                    (hasTable || isDeliveryOrPickup || isCounter);
                if (isBilledStatus) {
                  _openPaymentForOrderCard(context, controller, order);
                  return;
                }
                if (showRunningDialog) {
                  RunningTableDialog.showRunningTablePopup(
                    context: context,
                    tableId: hasTable ? order.table!.id! : null,
                    orderUuid: !hasTable ? order.uuid : null,
                    onRefreshTables: () => controller.fetchAllOrders(),
                    onSetLoader:
                        (bool show) =>
                            controller.isNavigatingToOrder.value = show,
                    sourceScreen: Routes.ORDER_SCREEN,
                    hideChangeTable: isDeliveryOrPickup || isCounter,
                  );
                } else {
                  showOrderBottomSheet(context, controller, order);
                }
              },
              child: OrderCard(order: order),
            );
          },
        );
      }),
    );
  }

  String _translateDateOption(String option) {
    switch (option) {
      case 'Today':
        return TranslationKeys.today.tr;
      case 'Current Week':
        return TranslationKeys.currentWeek.tr;
      case 'Last Week':
        return TranslationKeys.lastWeek.tr;
      case 'Last 7 Days':
        return TranslationKeys.last7Days.tr;
      case 'Current Month':
        return TranslationKeys.currentMonth.tr;
      case 'Last Month':
        return TranslationKeys.lastMonth.tr;
      case 'Current Year':
        return TranslationKeys.currentYear.tr;
      case 'Last Year':
        return TranslationKeys.lastYear.tr;
      case 'Custom Date':
        return TranslationKeys.customDate.tr;
      default:
        return option;
    }
  }

  String _translateOrderFilter(String option) {
    switch (option) {
      case 'All Orders':
        return TranslationKeys.allOrders.tr;
      case 'Kitchen':
        return TranslationKeys.kitchenStatus.tr;
      case 'Billed':
        return TranslationKeys.billedStatus.tr;
      case 'Paid':
        return TranslationKeys.paidStatus.tr;
      case 'Canceled':
        return TranslationKeys.canceledStatus.tr;
      case 'Payment Due':
        return TranslationKeys.paymentDueStatus.tr;
      default:
        return option;
    }
  }

  static Future<void> showOrderBottomSheet(
    BuildContext context,
    OrderScreenController controller,
    order_model.Orders order,
  ) async {
    final orderUuid = order.uuid;
    if (orderUuid == null || orderUuid.isEmpty) {
      AppToast.showError(
        TranslationKeys.orderUuidNotFound.tr,
        title: TranslationKeys.error.tr,
      );
      return;
    }

    if (!context.mounted) return;

    final screenHeight = MediaQuery.of(context).size.height;

    // Always refresh order details when a card is tapped
    if (!controller.isLoadingOrderDetails.value) {
      controller.fetchOrderDetails(orderUuid);
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MySize.getHeight(16)),
        ),
      ),
      builder: (builderContext) {
        return OrderScreenView()._buildBottomSheetContent(
          builderContext,
          controller,
          order,
          screenHeight,
        );
      },
    );
  }

  Widget _buildBottomSheetContent(
    BuildContext context,
    OrderScreenController controller,
    order_model.Orders order,
    double screenHeight,
  ) {
    return Container(
      height: screenHeight * 0.8,
      decoration: BoxDecoration(
        color: ColorConstants.bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MySize.getHeight(16)),
        ),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Obx(() {
        if (controller.isLoadingOrderDetails.value) {
          return _buildLoadingView();
        }

        final orderDetails = controller.orderDetails.value;
        final orderData = orderDetails?.data;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: _buildOrderDetailsOrError(context, controller, order),
              ),
            ),
            if (orderData != null)
              _buildStickyButtons(context, controller, orderData),
          ],
        );
      }),
    );
  }

  Widget _buildStickyButtons(
    BuildContext context,
    OrderScreenController controller,
    order_details_model.Data orderData,
  ) {
    final showAddPayment = _hasPaymentDue(orderData);
    return Container(
      padding: EdgeInsets.only(
        top: MySize.getHeight(8),
        left: MySize.getWidth(8),
        right: MySize.getWidth(8),
        bottom: MySize.getHeight(20),
      ),
      decoration: BoxDecoration(
        color: ColorConstants.bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: MySize.getWidth(4),
            offset: Offset(0, -MySize.getHeight(2)),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MySize.getWidth(16),
                  vertical: MySize.getHeight(10),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF60616E),
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                  boxShadow: ColorConstants.getShadow2,
                ),
                child: Text(
                  TranslationKeys.close.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MySize.getHeight(15),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: MySize.getWidth(12)),
          Expanded(
            child:
                showAddPayment
                    ? InkWell(
                      onTap:
                          () => _openAddPaymentFromSheet(context, controller),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(16),
                          vertical: MySize.getHeight(10),
                        ),
                        decoration: BoxDecoration(
                          color: ColorConstants.successGreen,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          boxShadow: ColorConstants.getShadow2,
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.payment,
                                  color: Colors.white,
                                  size: MySize.getHeight(18),
                                ),
                                SizedBox(width: MySize.getWidth(6)),
                                Text(
                                  TranslationKeys.pay.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: MySize.getHeight(15),
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    : Obx(() {
                      final isPrinting = controller.isPrinting.value;
                      return InkWell(
                        onTap:
                            isPrinting
                                ? null
                                : () => _printInvoice(
                                  context,
                                  controller,
                                  orderData,
                                ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: MySize.getWidth(16),
                            vertical: MySize.getHeight(10),
                          ),
                          decoration: BoxDecoration(
                            color:
                                isPrinting
                                    ? const Color(
                                      0xFF0E9F6E,
                                    ).withValues(alpha: 0.7)
                                    : const Color(0xFF0E9F6E),
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(8),
                            ),
                            boxShadow: ColorConstants.getShadow2,
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isPrinting)
                                    CupertinoActivityIndicator(
                                      radius: MySize.getHeight(8),
                                      color: Colors.white,
                                    )
                                  else
                                    Icon(
                                      Icons.print,
                                      color: Colors.white,
                                      size: MySize.getHeight(18),
                                    ),
                                  if (!isPrinting)
                                    SizedBox(width: MySize.getWidth(6)),
                                  if (!isPrinting)
                                    Text(
                                      TranslationKeys.print.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(15),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsOrError(
    BuildContext context,
    OrderScreenController controller,
    order_model.Orders order,
  ) {
    final orderDetails = controller.orderDetails.value;
    final orderData = orderDetails?.data?.order;

    if (orderData == null || orderDetails?.data == null) {
      return _buildErrorView(context);
    }

    return _buildOrderDetailsContent(
      context,
      controller,
      orderDetails!.data!,
      order,
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(MySize.getWidth(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: MySize.getWidth(8),
              offset: Offset(0, MySize.getHeight(2)),
            ),
          ],
        ),
        child: CupertinoActivityIndicator(
          radius: MySize.getHeight(8),
          color: ColorConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: MySize.getHeight(48),
            color: Colors.grey,
          ),
          SizedBox(height: MySize.getHeight(16)),
          Text(
            TranslationKeys.failedToLoadOrderDetails.tr,
            style: TextStyle(
              fontSize: MySize.getHeight(17),
              color: Colors.grey,
            ),
          ),
          SizedBox(height: MySize.getHeight(16)),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(24),
                vertical: MySize.getHeight(12),
              ),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.circular(MySize.getHeight(8)),
              ),
              child: Text(
                TranslationKeys.close.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MySize.getHeight(15),
                ),
              ),
            ),
          ),
          SizedBox(height: MySize.getHeight(16)),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsContent(
    BuildContext context,
    OrderScreenController controller,
    order_details_model.Data orderData,
    order_model.Orders order,
  ) {
    final orderDetails = orderData.order;
    final couponCode = orderDetails?.couponCode;
    final placedVia = orderDetails?.placedVia;

    return Padding(
      padding: EdgeInsets.all(MySize.getWidth(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${orderDetails?.formattedOrderNumber ?? order.id ?? ''} (${helpers.formatOrderType(orderDetails?.orderType)})',
                  style: TextStyle(
                    fontSize: MySize.getHeight(17),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (couponCode != null && couponCode.isNotEmpty) ...[
                SizedBox(width: MySize.getWidth(8)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(MySize.getHeight(6)),
                    border: Border.all(
                      color: Colors.purple.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${TranslationKeys.coupon.tr.toUpperCase()}: ${couponCode.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontSize: MySize.getHeight(11),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (placedVia != null && placedVia.isNotEmpty) ...[
                SizedBox(width: MySize.getWidth(8)),
                Builder(
                  builder: (context) {
                    final placedViaColor = _getPlacedViaColorStatic(placedVia);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: placedViaColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(6),
                        ),
                        border: Border.all(color: placedViaColor, width: 1.5),
                      ),
                      child: Text(
                        _formatPlacedViaTextStatic(placedVia),
                        style: TextStyle(
                          color: placedViaColor,
                          fontSize: MySize.getHeight(11),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          SizedBox(height: MySize.getHeight(12)),
          OrderDetailWidgets.buildOrderTimeInfo(
            orderDetails,
            dateFormatter: (s) => DateTimeFormatter.formatDateTime(s),
          ),
          SizedBox(height: MySize.getHeight(8)),
          if (orderDetails?.customer != null &&
              helpers.hasCustomerInfo(orderDetails!.customer!))
            OrderDetailWidgets.buildCustomerDetails(
              orderDetails.customer!,
              orderType: orderDetails.orderType,
              deliveryAddress: orderDetails.deliveryAddress,
            ),
          if (orderDetails?.customer != null &&
              helpers.hasCustomerInfo(orderDetails!.customer!))
            SizedBox(height: MySize.getHeight(8)),
          Builder(
            builder: (context) {
              final shouldShowWaiter =
                  (orderDetails?.customer == null ||
                      !helpers.hasCustomerInfo(orderDetails?.customer)) &&
                  helpers.isDineInOrder(orderDetails?.orderType) &&
                  helpers.hasWaiterInfo(orderDetails?.waiter);

              if (!shouldShowWaiter) return const SizedBox.shrink();

              return Column(
                children: [
                  OrderDetailWidgets.buildWaiterDetails(orderDetails!.waiter!),
                  SizedBox(height: MySize.getHeight(8)),
                ],
              );
            },
          ),
          OrderDetailWidgets.buildOrderItemsTable(orderData),
          SizedBox(height: MySize.getHeight(8)),
          OrderDetailWidgets.buildPriceSummary(orderData),
          if (orderData.order?.payments?.isNotEmpty ?? false) ...[
            SizedBox(height: MySize.getHeight(8)),
            _buildPaymentsTable(context, orderData, controller),
          ],
          if (_isPendingVerification(orderData)) ...[
            SizedBox(height: MySize.getHeight(8)),
            _buildPendingVerificationSection(context, orderData, controller),
          ],
          SizedBox(height: MySize.getHeight(16)),
        ],
      ),
    );
  }

  bool _hasPaymentDue(order_details_model.Data orderData) {
    final statusDue = orderData.order?.status?.toLowerCase() == 'payment_due';
    final paymentDue =
        orderData.order?.payments?.any(
          (p) => p.paymentMethod?.toLowerCase() == 'due',
        ) ??
        false;
    return statusDue || paymentDue;
  }

  bool _isPendingVerification(order_details_model.Data orderData) {
    return orderData.order?.status?.toLowerCase() == 'pending_verification';
  }

  Widget _buildPendingVerificationSection(
    BuildContext context,
    order_details_model.Data orderData,
    OrderScreenController controller,
  ) {
    final orderUuid = orderData.order?.uuid ?? '';
    final payments = orderData.order?.payments ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(12),
              vertical: MySize.getHeight(8),
            ),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(MySize.getHeight(8)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.pending_outlined,
                  size: MySize.getHeight(16),
                  color: Colors.orange.shade800,
                ),
                SizedBox(width: MySize.getWidth(6)),
                Text(
                  TranslationKeys.pendingVerificationStatus.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(13),
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          // Payment rows
          if (payments.isNotEmpty)
            ...payments.map((payment) {
              final methodRaw = payment.paymentMethod?.toLowerCase() ?? '';
              final methodLabel =
                  methodRaw == 'cash'
                      ? TranslationKeys.cash.tr
                      : methodRaw == 'due'
                      ? TranslationKeys.due.tr
                      : methodRaw == 'card'
                      ? TranslationKeys.card.tr
                      : payment.paymentMethod ?? '—';
              final amountStr =
                  payment.amount != null
                      ? CurrencyFormatter.formatPrice(
                        payment.amount!.toString(),
                      )
                      : '—';
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MySize.getWidth(12),
                  vertical: MySize.getHeight(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: amount + method chip
                    Row(
                      children: [
                        Text(
                          amountStr,
                          style: TextStyle(
                            fontSize: MySize.getHeight(13.5),
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(6)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: MySize.getWidth(6),
                            vertical: MySize.getHeight(3),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(4),
                            ),
                          ),
                          child: Text(
                            methodLabel,
                            style: TextStyle(
                              fontSize: MySize.getHeight(11),
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MySize.getHeight(8)),
                    // Row 2: Confirm Payment + Report Unpaid buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (orderUuid.isEmpty) return;
                              final success = await controller
                                  .updateOrderStatus(orderUuid, 'paid');
                              if (success && context.mounted) {
                                Navigator.of(context).pop();
                                controller.fetchAllOrders();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: MySize.getHeight(8),
                              ),
                              decoration: BoxDecoration(
                                color: ColorConstants.successGreen,
                                borderRadius: BorderRadius.circular(
                                  MySize.getHeight(6),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  TranslationKeys.confirmPayment.tr,
                                  style: TextStyle(
                                    fontSize: MySize.getHeight(12),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(8)),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (orderUuid.isEmpty) return;
                              final success = await controller
                                  .updateOrderStatus(orderUuid, 'payment_due');
                              if (success && context.mounted) {
                                Navigator.of(context).pop();
                                controller.fetchAllOrders();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: MySize.getHeight(8),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(
                                  MySize.getHeight(6),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  TranslationKeys.reportUnpaid.tr,
                                  style: TextStyle(
                                    fontSize: MySize.getHeight(12),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList()
          else
            Padding(
              padding: EdgeInsets.all(MySize.getWidth(12)),
              child: Text(
                'No payment details available.',
                style: TextStyle(
                  fontSize: MySize.getHeight(13),
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentsTable(
    BuildContext context,
    order_details_model.Data orderData,
    OrderScreenController controller,
  ) {
    final payments = orderData.order?.payments ?? [];
    if (payments.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.1),
          1: FlexColumnWidth(1.1),
          2: FlexColumnWidth(1.9),
          3: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(MySize.getHeight(8)),
              ),
            ),
            children: [
              _tableHeaderCell(TranslationKeys.amount.tr),
              _tableHeaderCell(TranslationKeys.paymentMethod.tr),
              _tableHeaderCell(TranslationKeys.dateAndTime.tr),
              _tableHeaderCell(TranslationKeys.action.tr),
            ],
          ),
          ...payments.map((payment) {
            final method = payment.paymentMethod?.toLowerCase() ?? '';
            final isDue = method == 'due';
            final amountStr =
                payment.amount != null
                    ? CurrencyFormatter.formatPrice(payment.amount!.toString())
                    : '—';
            final methodLabel =
                isDue
                    ? TranslationKeys.due.tr
                    : (method == 'cash'
                        ? TranslationKeys.cash.tr
                        : (payment.paymentMethod ?? '—'));
            final dateTimeStr =
                payment.createdAt != null && payment.createdAt!.isNotEmpty
                    ? DateTimeFormatter.formatDateTime(payment.createdAt)
                    : '—';
            return TableRow(
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              children: [
                _centeredTableCell(amountStr),
                _centeredTableCell(methodLabel),
                _centeredTableCell(dateTimeStr),
                Padding(
                  padding: EdgeInsets.all(MySize.getHeight(8)),
                  child: Center(
                    child:
                        isDue
                            ? _outlinedButton(
                              label: TranslationKeys.pay.tr,
                              onTap:
                                  () => _openAddPaymentFromSheet(
                                    context,
                                    controller,
                                  ),
                              backgroundColor: ColorConstants.successGreen,
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _outlinedButton(
                                  label: TranslationKeys.view.tr,
                                  icon: Icons.visibility_outlined,
                                  onTap: () {
                                    final id = payment.id;
                                    if (id != null) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder:
                                            (_) => PaymentReceiptDialog(
                                              paymentId: id,
                                            ),
                                      );
                                    }
                                  },
                                  iconOnly: true,
                                ),
                                SizedBox(width: MySize.getWidth(4)),
                                _outlinedButton(
                                  label: TranslationKeys.print.tr,
                                  icon: Icons.print,
                                  iconOnly: true,
                                  onTap: () {
                                    final id = payment.id;
                                    if (id != null) {
                                      _printPaymentReceipt(
                                        context,
                                        controller,
                                        id,
                                      );
                                    } else {
                                      _printInvoice(
                                        context,
                                        controller,
                                        orderData,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Reusable centered table cell for payment table (header and data).
  Widget _centeredTableCell(
    String text, {
    double fontSize = 12,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.all(MySize.getHeight(8)),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: MySize.getHeight(fontSize),
            fontWeight: fontWeight,
            color: color ?? Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return _centeredTableCell(
      text,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade700,
    );
  }

  Widget _outlinedButton({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
    bool? iconOnly,
    Color? borderColor,
    Color? textColor,
    Color? backgroundColor,
  }) {
    final showLabel = iconOnly != true;
    final isFilled = backgroundColor != null;
    final effectiveBorderColor =
        borderColor ??
        (icon == Icons.print
            ? Colors.red.shade300
            : (icon == Icons.visibility_outlined
                ? Colors.blue.shade300
                : Colors.grey.shade400));
    final effectiveTextColor =
        isFilled
            ? Colors.white
            : (textColor ??
                (icon == Icons.print
                    ? Colors.red
                    : (icon == Icons.visibility_outlined
                        ? Colors.blue
                        : Colors.grey)));
    final iconOnlyPadding =
        showLabel
            ? null
            : EdgeInsets.symmetric(
              horizontal: MySize.getWidth(4),
              vertical: MySize.getHeight(4),
            );
    final iconSize = MySize.getHeight(20);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            iconOnlyPadding ??
            EdgeInsets.symmetric(
              horizontal: MySize.getWidth(8),
              vertical: MySize.getHeight(6),
            ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: isFilled ? null : Border.all(color: effectiveBorderColor),
          borderRadius: BorderRadius.circular(MySize.getHeight(6)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: effectiveTextColor),
                if (showLabel) SizedBox(width: MySize.getWidth(4)),
              ],
              if (showLabel)
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MySize.getHeight(11),
                    color: effectiveTextColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _openAddPaymentFromSheet(
    BuildContext context,
    OrderScreenController controller,
  ) async {
    Navigator.pop(context);
    final getOrderModel = controller.orderDetails.value;
    final orderUuid = getOrderModel?.data?.order?.uuid;
    if (orderUuid == null || orderUuid.isEmpty) return;

    final success = await RunningTableService.openPaymentFlow(
      context: context,
      orderUuid: orderUuid,
    );

    if (success == true) {
      controller.fetchAllOrders();
    }
  }

  static Future<void> _openPaymentForOrderCard(
    BuildContext context,
    OrderScreenController controller,
    order_model.Orders order,
  ) async {
    final orderUuid = order.uuid;
    if (orderUuid == null || orderUuid.isEmpty) return;

    final success = await RunningTableService.openPaymentFlow(
      context: context,
      orderUuid: orderUuid,
    );

    if (success == true) {
      controller.fetchAllOrders();
    }
  }

  /// Order card shows API time as-is (format only, no timezone conversion)
  /// so e.g. 03:16 does not become 04:16 when API already sends local/restaurant time.
  static String _formatOrderCardDateTime(
    String? dateTime,
    String? formattedDateTime,
  ) {
    if (dateTime != null && dateTime.isNotEmpty) {
      return DateTimeFormatter.formatDateTime(dateTime);
    }
    if (formattedDateTime != null && formattedDateTime.isNotEmpty) {
      return DateTimeFormatter.formatDateTime(formattedDateTime);
    }
    return '';
  }

  static String formatOrderDateTimeForCard(String? dateTimeString) {
    return DateTimeFormatter.formatDateTimeWithRestaurantTimezone(
      dateTimeString,
    );
  }

  Future<void> _printPaymentReceipt(
    BuildContext context,
    OrderScreenController controller,
    int paymentId,
  ) async {
    try {
      controller.isPrinting.value = true;
      final networkClient = NetworkClient();
      final endpoint = ArgumentConstant.paymentReceiptEndpoint.replaceAll(
        ':id',
        paymentId.toString(),
      );
      final response = await networkClient.get(endpoint);

      if (!helpers.isSuccessStatus(response.statusCode)) {
        AppToast.showError(
          TranslationKeys.somethingWentWrong.tr,
          title: TranslationKeys.error.tr,
        );
        return;
      }

      if (response.data is! Map<String, dynamic>) {
        AppToast.showError(
          TranslationKeys.somethingWentWrong.tr,
          title: TranslationKeys.error.tr,
        );
        return;
      }

      final model = ReceiptOrderResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success != true || model.data == null) {
        AppToast.showError(
          TranslationKeys.somethingWentWrong.tr,
          title: TranslationKeys.error.tr,
        );
        return;
      }

      final printerName = box.read(ArgumentConstant.selectedReceiptPrinterKey);
      final isConnected = await Get.find<PrinterService>()
          .checkPrinterConnectivity(printerName);

      if (!isConnected) {
        AppToast.showError(
          '${TranslationKeys.printerNotConnected.tr}: $printerName',
          title: TranslationKeys.error.tr,
        );
        return;
      }

      // Since we are Sunmi-exclusive now, we always use SunmiInvoicePrinterService
      await SunmiInvoicePrinterService().printReceiptFromApi(
        model.data!,
        copies: 1,
      );
    } catch (e) {
      AppToast.showError(
        TranslationKeys.somethingWentWrong.tr,
        title: TranslationKeys.error.tr,
      );
    } finally {
      controller.isPrinting.value = false;
    }
  }

  Future<void> _printInvoice(
    BuildContext context,
    OrderScreenController controller,
    order_details_model.Data orderData,
  ) async {
    if (orderData.order == null) {
      AppToast.showError(
        TranslationKeys.invoiceDataNotFound.tr,
        title: TranslationKeys.error.tr,
      );
      return;
    }

    try {
      controller.isPrinting.value = true;

      final printerName = box.read(ArgumentConstant.selectedReceiptPrinterKey);
      final isConnected = await Get.find<PrinterService>()
          .checkPrinterConnectivity(printerName);

      if (!isConnected) {
        AppToast.showError(
          '${TranslationKeys.printerNotConnected.tr}: $printerName',
          title: TranslationKeys.error.tr,
        );
        return;
      }

      // Since we are Sunmi-exclusive now, we always use SunmiInvoicePrinterService
      await SunmiInvoicePrinterService().printInvoice(orderData, copies: 1);
    } catch (e) {
      AppToast.showError(
        TranslationKeys.somethingWentWrong.tr,
        title: TranslationKeys.error.tr,
      );
    } finally {
      controller.isPrinting.value = false;
    }
  }
}

Widget _buildStatusTab({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: MySize.getWidth(4)),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.primaryColor : Colors.white,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: MySize.getHeight(14),
            ),
          ),
        ),
      ),
    ),
  );
}


class OrderCard extends StatelessWidget {
  final order_model.Orders order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final tableCode = order.table?.tableCode ?? 'T${order.table?.id ?? ''}';

    final orderNumber =
        order.formattedOrderNumber?.toString() ??
        order.orderNumber?.toString() ??
        '';

    final customerName = order.customer?.name ?? '';

    final status = order.status ?? TranslationKeys.paidStatus.tr;
    final statusColor = _getStatusColor(status);
    final formattedStatus = _formatStatusText(status);

    final formattedDateTime = OrderScreenView._formatOrderCardDateTime(
      order.dateTime,
      order.formattedDateTime,
    );
    final formattedPrice = CurrencyFormatter.formatPrice(order.total ?? '0');
    final waiterName = order.waiter?.name ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(MySize.getHeight(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MySize.getHeight(6),
                    vertical: MySize.getHeight(6),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(MySize.getHeight(6)),
                  ),
                  child:
                      order.orderType?.toLowerCase() == 'pickup'
                          ? Image.asset(
                            ImageConstant.pickup,
                            width: MySize.getHeight(28),
                            height: MySize.getHeight(28),
                          )
                          : order.orderType?.toLowerCase() == 'delivery'
                          ? Image.asset(
                            ImageConstant.delivery,
                            width: MySize.getHeight(28),
                            height: MySize.getHeight(28),
                          )
                          : order.orderType?.toLowerCase() == 'counter'
                          ? Image.asset(
                            ImageConstant.counter,
                            width: MySize.getHeight(28),
                            height: MySize.getHeight(28),
                          )
                          : Text(
                            tableCode,
                            style: TextStyle(
                              color: ColorConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: MySize.getHeight(13),
                            ),
                          ),
                ),
                SizedBox(width: MySize.getWidth(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        orderNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MySize.getHeight(14),
                        ),
                      ),
                      if (order.customer != null && customerName.isNotEmpty)
                        Text(
                          customerName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MySize.getHeight(13),
                          ),
                        ),
                    ],
                  ),
                ),
                _statusBadge(formattedStatus, statusColor),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formattedDateTime,
                  style: TextStyle(
                    color: ColorConstants.grey600,
                    fontSize: MySize.getHeight(12),
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey.shade300,
              thickness: MySize.getHeight(1),
              height: MySize.getHeight(6),
            ),
            Row(
              children: [
                Text(
                  formattedPrice,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(17),
                  ),
                ),
                if (waiterName.isNotEmpty) SizedBox(width: MySize.getWidth(10)),
                if (waiterName.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        ImageConstant.waiter,
                        width: MySize.getHeight(18),
                        height: MySize.getHeight(18),
                      ),
                      SizedBox(width: MySize.getWidth(6)),
                      Text(
                        waiterName,
                        style: TextStyle(fontSize: MySize.getHeight(12)),
                      ),
                    ],
                  ),
                const Spacer(),

                if (order.placedVia != null && order.placedVia!.isNotEmpty)
                  Builder(
                    builder: (context) {
                      final placedViaColor = _getPlacedViaColorStatic(
                        order.placedVia!,
                      );
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: placedViaColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(6),
                          ),
                          border: Border.all(color: placedViaColor, width: 1.5),
                        ),
                        child: Text(
                          _formatPlacedViaTextStatic(order.placedVia!),
                          style: TextStyle(
                            color: placedViaColor,
                            fontSize: MySize.getHeight(13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                const Spacer(),
                _buildActionButtons(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final controller = Get.find<OrderScreenController>();
    final currentLocalStatus = controller.getLocalStatus(order.id.toString());

    if (currentLocalStatus == 'New') {
      return _buildActionButton(
        label: TranslationKeys.start.tr,
        color: ColorConstants.primaryColor,
        onTap: () => controller.updateLocalStatus(order.id.toString(), 'Preparing'),
      );
    } else if (currentLocalStatus == 'Preparing') {
      return _buildActionButton(
        label: TranslationKeys.ready.tr,
        color: ColorConstants.statusPaid,
        onTap: () => controller.updateLocalStatus(order.id.toString(), 'Ready'),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(12),
          vertical: MySize.getHeight(6),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(MySize.getHeight(6)),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: MySize.getHeight(13),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return TranslationKeys.paidStatus.tr;
      case 'billed':
        return TranslationKeys.billedStatus.tr;
      case 'canceled':
      case 'cancelled':
        return TranslationKeys.canceledStatus.tr;
      case 'payment_due':
        return TranslationKeys.paymentDueStatus.tr;
      case 'kot':
        return TranslationKeys.kitchenStatus.tr;
      case 'pending_verification':
        return TranslationKeys.pendingVerificationStatus.tr;
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
        return Colors.orange;
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
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(8),
        vertical: MySize.getHeight(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: MySize.getHeight(10),
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
  final bool isTablet;

  const _OrderTypeButtonItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isTablet,
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
      begin: widget.isTablet ? 1.0 : 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.3, 1.0)));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isSelected || widget.isTablet) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _OrderTypeButtonItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected || widget.isTablet) {
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
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(widget.isTablet ? 6 : 8),
              vertical: MySize.getHeight(6),
            ),
            decoration: BoxDecoration(
              color:
                  widget.isSelected
                      ? ColorConstants.primaryColor.withValues(
                        alpha: 0.1 * _backgroundAnimation.value,
                      )
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(MySize.getHeight(8)),
              border:
                  widget.isSelected
                      ? Border.all(
                        color: ColorConstants.primaryColor.withValues(
                          alpha: _backgroundAnimation.value,
                        ),
                        width: 1.5,
                      )
                      : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 0 : MySize.getWidth(6),
              ),
              child: Row(
                mainAxisSize:
                    widget.isTablet ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      widget.icon,
                      height: MySize.getHeight(20),
                      width: MySize.getHeight(20),
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (widget.isTablet || _fadeAnimation.value > 0)
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: MySize.getWidth(4)),
                        child:
                            widget.isTablet
                                ? Text(
                                  widget.label,
                                  style: TextStyle(
                                    fontSize: MySize.getHeight(13),
                                    color:
                                        widget.isSelected
                                            ? ColorConstants.primaryColor
                                            : Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.center,
                                )
                                : Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: MySize.getWidth(2),
                                  ),
                                  child: SizeTransition(
                                    axis: Axis.horizontal,
                                    sizeFactor: _fadeAnimation,
                                    child: Text(
                                      widget.label,
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(13),
                                        color:
                                            widget.isSelected
                                                ? ColorConstants.primaryColor
                                                : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
