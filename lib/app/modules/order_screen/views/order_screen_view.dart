import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/widgets/app_toast.dart';
import 'package:managerapp/app/modules/order_screen/controllers/order_screen_controller.dart';

import 'package:managerapp/app/widgets/access_limited_dialog.dart';
import 'package:managerapp/app/widgets/payment_receipt_dialog.dart';

import 'package:managerapp/app/services/printer_service.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/image_constants.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/all_orders_model.dart' as order_model;
import '../../../model/get_order_model.dart' as order_details_model;
import '../../../model/receipt_order_response_model.dart';
import '../../../model/kitchen_ticket_model.dart';
import '../../../services/sunmi_invoice_printer_service.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/date_time_formatter.dart';
import '../../../utils/order_helpers.dart' as helpers;
import '../../../widgets/shared/order_detail_widgets.dart';

Widget _buildPlacedViaBadge({
  required String placedVia,
  String? providerName,
}) {
  final key = placedVia.toLowerCase().trim();

  // Text badge
  final color = switch (key) {
    'ios' => const Color(0xFF4A4A4A),
    'android' => ColorConstants.statusPaid,
    'shop' => ColorConstants.statusBilled,
    _ => ColorConstants.statusBilled,
  };
  final label = key == 'ios'
      ? 'iOS'
      : key == 'android'
          ? 'Android'
          : 'Shop';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(MySize.getHeight(6)),
      border: Border.all(color: color, width: 1.5),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: MySize.getHeight(10),
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );
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
                                                label:
                                                    TranslationKeys
                                                        .newStatus
                                                        .tr,
                                                isSelected:
                                                    selectedStatus == 'New',
                                                onTap:
                                                    () =>
                                                        controller
                                                            .selectedLocalStatus
                                                            .value = 'New',
                                              ),

                                              _buildStatusTab(
                                                label: 'OK',
                                                isSelected:
                                                    selectedStatus == 'Ready',
                                                onTap:
                                                    () =>
                                                        controller
                                                            .selectedLocalStatus
                                                            .value = 'Ready',
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
              filteredList.length + (controller.isLoadingMore.value ? 1 : 0),
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
                showOrderBottomSheet(context, controller, order);
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
    await showOrderBottomSheetByUuid(context, controller, orderUuid);
  }

  /// Shows the order details bottom sheet by UUID only — used by pusher_service
  /// where we only have the UUID but no [order_model.Orders] object.
  static Future<void> showOrderBottomSheetByUuid(
    BuildContext context,
    OrderScreenController controller,
    String orderUuid,
  ) async {
    if (!context.mounted) return;

    final screenHeight = MediaQuery.of(context).size.height;

    // Always refresh order details when opening the sheet
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
        return OrderScreenView()._buildBottomSheetContentByUuid(
          builderContext,
          controller,
          screenHeight,
        );
      },
    );
  }


  Widget _buildBottomSheetContentByUuid(
    BuildContext context,
    OrderScreenController controller,
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
                child: _buildOrderDetailsOrErrorFromController(
                    context, controller),
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
    return Container(
      padding: EdgeInsets.fromLTRB(
        MySize.getWidth(12),
        MySize.getHeight(8),
        MySize.getWidth(12),
        MySize.getHeight(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button
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
                    fontSize: MySize.getHeight(14),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // KOT Print button (Kitchen Tickets)
          Expanded(
            child: Obx(() {
              final printing = controller.isPrinting.value;
              return InkWell(
                onTap: printing
                    ? null
                    : () => _printKitchenTicket(context, controller, orderData),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MySize.getWidth(16),
                    vertical: MySize.getHeight(10),
                  ),
                  decoration: BoxDecoration(
                    color: printing
                        ? ColorConstants.primaryColor.withValues(alpha: 0.7)
                        : ColorConstants.primaryColor,
                    borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  child: Center(
                    child: printing
                        ? CupertinoActivityIndicator(
                            radius: MySize.getHeight(8),
                            color: Colors.white,
                          )
                        : Text(
                            TranslationKeys.kitchenTickets.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: MySize.getHeight(14),
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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


  Widget _buildOrderDetailsOrErrorFromController(
    BuildContext context,
    OrderScreenController controller,
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
                  '${orderDetails?.formattedOrderNumber ?? orderDetails?.id?.toString() ?? ''} (${helpers.formatOrderType(orderDetails?.orderType)})',
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
                _buildPlacedViaBadge(
                  placedVia: placedVia,
                  providerName: orderDetails?.providerName,
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
              final amountVal = payment.amountTotal ?? payment.amount;
              final amountStr =
                  amountVal != null
                      ? CurrencyFormatter.formatPrice(
                        amountVal.toString(),
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
            })
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

    final orderStatus = orderData.order?.status?.toLowerCase();
    final orderUuid = orderData.order?.uuid ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MySize.getWidth(8),
              vertical: MySize.getHeight(10),
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(MySize.getHeight(8)),
              ),
            ),
            child: Row(
              children: [
                _tableHeaderCell(TranslationKeys.amount.tr, flex: 4),
                _tableHeaderCell(TranslationKeys.paymentMethod.tr, flex: 7),
                _tableHeaderCell(TranslationKeys.dateAndTime.tr, flex: 9),
              ],
            ),
          ),
          ...payments.asMap().entries.map((entry) {
            final payment = entry.value;
            final isLast = entry.key == payments.length - 1;
            final method = payment.paymentMethod?.toLowerCase() ?? '';
            final isDue = method == 'due';
            final amountVal = payment.amountTotal ?? payment.amount;
            final amountStr = amountVal != null
                ? CurrencyFormatter.formatPrice(amountVal.toString())
                : '—';
            final methodLabel = _paymentMethodLabel(payment);
            final dateTimeStr = payment.createdAt != null &&
                    payment.createdAt!.isNotEmpty
                ? DateTimeFormatter.formatDateTime(payment.createdAt)
                : '—';

            final refunds = _refundsForPayment(orderData, payment);
            final alreadyRefundedAmount = _refundedAmountForPayment(refunds);
            final refundableAmount =
                _remainingRefundableAmount(payment, refunds);

            final actions = <Widget>[];

            if (!isDue) {
              actions.add(
                _outlinedButton(
                  label: TranslationKeys.view.tr,
                  icon: Icons.visibility_outlined,
                  textColor: ColorConstants.successGreen,
                  borderColor:
                      ColorConstants.successGreen.withValues(alpha: 0.5),
                  backgroundColor:
                      ColorConstants.successGreen.withValues(alpha: 0.08),
                  onTap: () {
                    final id = payment.id;
                    if (id != null) {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => PaymentReceiptDialog(paymentId: id),
                      );
                    }
                  },
                ),
              );

              actions.add(
                _outlinedButton(
                  label: TranslationKeys.print.tr,
                  icon: Icons.print_outlined,
                  textColor: ColorConstants.tableBlue,
                  borderColor:
                      ColorConstants.tableBlue.withValues(alpha: 0.5),
                  backgroundColor:
                      ColorConstants.tableBlue.withValues(alpha: 0.08),
                  onTap: () {
                    final id = payment.id;
                    if (id != null) {
                      _printPaymentReceipt(context, controller, id);
                    } else {
                      _printInvoice(context, controller, orderData);
                    }
                  },
                ),
              );

              if (orderStatus == 'paid' &&
                  payment.id != null &&
                  orderUuid.isNotEmpty &&
                  refundableAmount > 0.009) {
                actions.add(
                  _outlinedButton(
                    label: TranslationKeys.refund.tr,
                    icon: Icons.undo_rounded,
                    borderColor: ColorConstants.red.withValues(alpha: 0.5),
                    textColor: ColorConstants.red,
                    backgroundColor: ColorConstants.red.withValues(alpha: 0.08),
                    onTap: () => _showRefundDialog(
                      context,
                      controller: controller,
                      orderUuid: orderUuid,
                      paymentId: payment.id!,
                      paymentAmount:
                          (payment.amountTotal ?? payment.amount) ?? 0.0,
                      alreadyRefundedAmount: alreadyRefundedAmount,
                      refundableAmount: refundableAmount,
                    ),
                  ),
                );
              }
            }

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(8),
                vertical: MySize.getHeight(10),
              ),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.8,
                        ),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          amountStr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(12),
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Text(
                          methodLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(12),
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Text(
                          dateTimeStr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(12),
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: MySize.getHeight(8)),
                    Row(
                      children: [
                        for (int i = 0; i < actions.length; i++) ...[
                          if (i > 0) SizedBox(width: MySize.getWidth(6)),
                          Expanded(child: actions[i]),
                        ],
                      ],
                    ),
                  ],
                  if (refunds.isNotEmpty) ...[
                    SizedBox(height: MySize.getHeight(8)),
                    ...refunds.map(
                      (refund) => Padding(
                        padding: EdgeInsets.only(top: MySize.getHeight(4)),
                        child: _buildRefundHistoryLine(refund),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: MySize.getHeight(11),
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  List<order_details_model.Refunds> _refundsForPayment(
    order_details_model.Data orderData,
    order_details_model.Payments payment,
  ) {
    final paymentId = payment.id;
    if (paymentId == null) return const [];
    return (orderData.order?.refundSummary?.refunds ?? [])
        .where((refund) => refund.paymentId == paymentId)
        .toList();
  }

  double _refundedAmountForPayment(List<order_details_model.Refunds> refunds) {
    return refunds.fold<double>(
      0.0,
      (sum, refund) => sum + (refund.amount ?? 0.0),
    );
  }

  double _remainingRefundableAmount(
    order_details_model.Payments payment,
    List<order_details_model.Refunds> refunds,
  ) {
    final paidAmount = (payment.amountTotal ?? payment.amount) ?? 0.0;
    final refundedAmount = _refundedAmountForPayment(refunds);
    final remainingAmount = paidAmount - refundedAmount;
    return remainingAmount > 0 ? remainingAmount : 0.0;
  }

  String _paymentMethodLabel(order_details_model.Payments payment) {
    final method = payment.paymentMethod?.toLowerCase() ?? '';
    switch (method) {
      case 'cash':
        return TranslationKeys.cash.tr;
      case 'due':
        return TranslationKeys.due.tr;
      case 'card':
        return TranslationKeys.card.tr;
      case 'upi':
        return TranslationKeys.upi.tr;
      case 'bank transfer':
        return TranslationKeys.bankTransfer.tr;
      default:
        return payment.paymentMethod ?? '—';
    }
  }

  Future<void> _showRefundDialog(
    BuildContext context, {
    required OrderScreenController controller,
    required String orderUuid,
    required int paymentId,
    required double paymentAmount,
    required double alreadyRefundedAmount,
    required double refundableAmount,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _RefundDialog(
          controller: controller,
          orderUuid: orderUuid,
          paymentId: paymentId,
          paymentAmount: paymentAmount,
          alreadyRefundedAmount: alreadyRefundedAmount,
          refundableAmount: refundableAmount,
        );
      },
    );
  }

  Widget _buildRefundHistoryLine(
    order_details_model.Refunds refund,
  ) {
    final amountText =
        refund.amount != null
            ? CurrencyFormatter.formatPrice(refund.amount!.toString())
            : '—';
    final dateText =
        refund.createdAt != null && refund.createdAt!.isNotEmpty
            ? DateTimeFormatter.formatDateTime(refund.createdAt)
            : '—';
    final refundedBy = refund.refundedBy?.trim();
    final refundReason = refund.reason?.trim();
    final hasMetaLine =
        (refundedBy != null && refundedBy.isNotEmpty) ||
        (refundReason != null && refundReason.isNotEmpty);

    final metaTextStyle = TextStyle(
      fontSize: MySize.getHeight(11),
      color: Colors.grey.shade700,
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: MySize.getHeight(4)),
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(8),
        vertical: MySize.getHeight(6),
      ),
      decoration: BoxDecoration(
        color: ColorConstants.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(MySize.getHeight(6)),
        border: Border.all(
          color: ColorConstants.primaryColor.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.reply_outlined,
            size: MySize.getHeight(14),
            color: ColorConstants.primaryColor,
          ),
          SizedBox(width: MySize.getWidth(6)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: MySize.getWidth(8),
                  runSpacing: MySize.getHeight(2),
                  children: [
                    Text(
                      '${TranslationKeys.refund.tr}: $amountText',
                      style: TextStyle(
                        fontSize: MySize.getHeight(11.5),
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                    Text(dateText, style: metaTextStyle),
                  ],
                ),
                if (hasMetaLine) ...[
                  SizedBox(height: MySize.getHeight(2)),
                  Text.rich(
                    TextSpan(
                      children: [
                        if (refundedBy != null && refundedBy.isNotEmpty)
                          TextSpan(
                            text: '${TranslationKeys.by.tr} $refundedBy',
                            style: metaTextStyle,
                          ),
                        if (refundedBy != null &&
                            refundedBy.isNotEmpty &&
                            refundReason != null &&
                            refundReason.isNotEmpty)
                          TextSpan(text: '  ', style: metaTextStyle),
                        if (refundReason != null && refundReason.isNotEmpty)
                          TextSpan(
                            text: '"$refundReason"',
                            style: metaTextStyle.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    softWrap: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
        (icon == Icons.print || icon == Icons.print_outlined
            ? ColorConstants.tableBlue
            : (icon == Icons.visibility_outlined
                ? ColorConstants.successGreen
                : (icon == Icons.undo_rounded
                    ? ColorConstants.red
                    : Colors.grey.shade400)));
    final effectiveTextColor =
        textColor ??
        (isFilled
            ? Colors.white
            : (icon == Icons.print || icon == Icons.print_outlined
                ? ColorConstants.tableBlue
                : (icon == Icons.visibility_outlined
                    ? ColorConstants.successGreen
                    : (icon == Icons.undo_rounded
                        ? ColorConstants.red
                        : Colors.grey.shade700))));
    final iconOnlyPadding =
        showLabel
            ? null
            : EdgeInsets.symmetric(
              horizontal: MySize.getWidth(4),
              vertical: MySize.getHeight(4),
            );
    final iconSize = MySize.getHeight(16);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MySize.getHeight(6)),
      child: Container(
        padding:
            iconOnlyPadding ??
            EdgeInsets.symmetric(
              horizontal: MySize.getWidth(6),
              vertical: MySize.getHeight(8),
            ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: isFilled && borderColor == null
              ? null
              : Border.all(color: effectiveBorderColor, width: 1.2),
          borderRadius: BorderRadius.circular(MySize.getHeight(6)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: effectiveTextColor),
                if (showLabel) SizedBox(width: MySize.getWidth(5)),
              ],
              if (showLabel)
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: MySize.getHeight(13),
                      fontWeight: FontWeight.bold,
                      color: effectiveTextColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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

      final isConnected = await Get.find<PrinterService>()
          .checkPrinterConnectivity();

      if (!isConnected) {
        AppToast.showError(
          TranslationKeys.printerNotConnected.tr,
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

      final isConnected = await Get.find<PrinterService>()
          .checkPrinterConnectivity();

      if (!isConnected) {
        AppToast.showError(
          TranslationKeys.printerNotConnected.tr,
          title: TranslationKeys.error.tr,
        );
        return;
      }

      // Since we are Sunmi-exclusive now, we always use SunmiInvoicePrinterService
      await SunmiInvoicePrinterService().printInvoice(
        orderData,
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

  Future<void> _printKitchenTicket(
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

      final isConnected = await Get.find<PrinterService>()
          .checkPrinterConnectivity();

      if (!isConnected) {
        AppToast.showError(
          TranslationKeys.printerNotConnected.tr,
          title: TranslationKeys.error.tr,
        );
        return;
      }

      final ord = orderData.order!;
      final tableMap = <String, dynamic>{
        'table_code': ord.table?.tableCode ?? '',
        'name': ord.table?.tableCode ?? '',
      };

      final kot = KitchenTicket(
        id: ord.id,
        kotNumber: ord.formattedOrderNumber ??
            (ord.orderNumber != null ? '${ord.orderNumber}' : null),
        createdAt: ord.createdAt ?? DateTime.now().toIso8601String(),
        note: ord.note,
        order: KitchenTicketOrder(
          id: ord.id,
          orderNumber: ord.formattedOrderNumber ?? ord.orderNumber,
          formattedOrderNumber: ord.formattedOrderNumber,
          orderType: ord.orderType,
          table: tableMap,
          note: ord.note,
        ),
        items: ord.items?.map((it) {
          return KitchenTicketItem(
            id: it.id,
            itemName: it.itemName,
            quantity: it.quantity,
            variationName: it.variationName,
            note: it.note,
            modifiers: it.modifiers?.map((m) => KitchenTicketModifier(
                  id: m.id,
                  name: m.name,
                )).toList(),
          );
        }).toList(),
      );

      final printerService = Get.find<PrinterService>();
      final copies = printerService.kitchenCopies.value > 0
          ? printerService.kitchenCopies.value
          : 1;

      await SunmiInvoicePrinterService().printKOT(
        kot,
        copies: copies,
      );

      AppToast.showSuccess(TranslationKeys.printSuccessful.tr);
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
    final itemsCount = order.itemsCount ?? 0;
    final formattedPrice =
        order.formattedEffectiveTotal ??
        CurrencyFormatter.formatPrice(
          (order.effectiveTotal ?? order.total) != null
              ? (order.effectiveTotal?.toString() ?? order.total ?? '0')
              : '0',
        );
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
          mainAxisSize: MainAxisSize.min,
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
                      if (customerName.isNotEmpty)
                        Text(
                          customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
            SizedBox(height: MySize.getHeight(4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formattedDateTime,
                    style: TextStyle(
                      color: ColorConstants.grey600,
                      fontSize: MySize.getHeight(12),
                    ),
                  ),
                ),
                if (itemsCount > 0)
                  Text(
                    "$itemsCount ${TranslationKeys.itemsPlural.tr}",
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
                if (order.coupon != null && order.coupon!.code != null) ...[
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
                      '${TranslationKeys.coupon.tr.toUpperCase()}: ${order.coupon!.code!.toUpperCase()}',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: MySize.getHeight(11),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: MySize.getWidth(6)),
                ],
                if (order.placedVia != null && order.placedVia!.isNotEmpty)
                  _buildPlacedViaBadge(
                    placedVia: order.placedVia!,
                    providerName: order.providerName,
                  ),
                SizedBox(width: MySize.getWidth(6)),
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
        label: "OK",
        icon: Icons.check,
        color: ColorConstants.primaryColor,
        onTap:
            () =>
                controller.updateLocalStatus(order.id.toString(), 'Ready'),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(12),
          vertical: MySize.getHeight(6),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(MySize.getHeight(6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: MySize.getHeight(16)),
              SizedBox(width: MySize.getWidth(4)),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: MySize.getHeight(13),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
      case 'out_for_delivery':
        return 'OUT FOR DELIVERY';
      case 'delivered':
        return TranslationKeys.orderDelivered.tr.toUpperCase();
      default:
        return status.replaceAll('_', ' ').toUpperCase();
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
      case 'out_for_delivery':
        return ColorConstants.tableBlue;
      case 'delivered':
        return ColorConstants.successGreen;
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

class _RefundDialog extends StatefulWidget {
  final OrderScreenController controller;
  final String orderUuid;
  final int paymentId;
  final double paymentAmount;
  final double alreadyRefundedAmount;
  final double refundableAmount;

  const _RefundDialog({
    required this.controller,
    required this.orderUuid,
    required this.paymentId,
    required this.paymentAmount,
    required this.alreadyRefundedAmount,
    required this.refundableAmount,
  });

  @override
  State<_RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends State<_RefundDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _reasonController;
  String? _amountErrorText;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: CurrencyFormatter.formatOnlyNumber(widget.refundableAmount),
    );
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  double? _parseRefundAmount(String rawValue) {
    var normalized = rawValue.trim();
    final decimalSeparator = CurrencyFormatter.getDecimalSeparator();
    if (decimalSeparator != '.') {
      normalized = normalized.replaceAll(decimalSeparator, '.');
    }
    normalized = normalized.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDotIndex = normalized.indexOf('.');
    if (firstDotIndex != -1) {
      normalized =
          normalized.substring(0, firstDotIndex + 1) +
          normalized.substring(firstDotIndex + 1).replaceAll('.', '');
    }
    return double.tryParse(normalized);
  }

  void _clearAmountError() {
    if (_amountErrorText == null || _isSubmitting) return;
    setState(() {
      _amountErrorText = null;
    });
  }

  InputDecoration _buildTextFieldDecoration({
    String? hintText,
    String? errorText,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      errorText: errorText,
      hintStyle: TextStyle(
        fontSize: MySize.getHeight(12),
        color: Colors.grey.shade500,
      ),
      errorStyle: TextStyle(
        fontSize: MySize.getHeight(11),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(12),
        vertical: MySize.getHeight(12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        borderSide: const BorderSide(color: ColorConstants.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        borderSide: const BorderSide(color: ColorConstants.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        borderSide: const BorderSide(color: ColorConstants.red),
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    final amount = _parseRefundAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountErrorText = TranslationKeys.enterValidRefundAmount.tr;
      });
      return;
    }

    if (amount - widget.refundableAmount > 0.009) {
      setState(() {
        _amountErrorText = TranslationKeys.refundAmountExceedsAvailable.tr;
      });
      return;
    }

    final trimmedReason = _reasonController.text.trim();
    setState(() {
      _amountErrorText = null;
      _isSubmitting = true;
    });

    final errorMessage = await widget.controller.createRefund(
      orderUuid: widget.orderUuid,
      paymentId: widget.paymentId,
      amount: amount,
      reason: trimmedReason.isEmpty ? null : trimmedReason,
    );

    if (!mounted) return;

    if (errorMessage == null) {
      Navigator.of(context).pop();
      AppToast.showSuccess(
        TranslationKeys.createRefund.tr,
        title: TranslationKeys.success.tr,
      );
      return;
    }

    setState(() {
      _isSubmitting = false;
    });
    AppToast.showError(errorMessage, title: TranslationKeys.error.tr);
  }

  Widget _buildRefundSummaryRow(
    String label,
    double amount, {
    Color? valueColor,
    FontWeight valueWeight = FontWeight.w500,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: MySize.getHeight(12),
              color: Colors.grey.shade700,
            ),
          ),
        ),
        SizedBox(width: MySize.getWidth(8)),
        Text(
          CurrencyFormatter.formatPrice(amount.toString()),
          maxLines: 1,
          style: TextStyle(
            fontSize: MySize.getHeight(12.5),
            fontWeight: valueWeight,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;
    final keyboardOpen = keyboardInset > 0;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(
            MySize.getWidth(20),
            keyboardOpen ? MySize.getHeight(12) : MySize.getHeight(24),
            MySize.getWidth(20),
            keyboardOpen ? MySize.getHeight(12) : MySize.getHeight(24),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: keyboardOpen ? Alignment.topCenter : Alignment.center,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MySize.getWidth(340),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(MySize.getHeight(10)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(MySize.getHeight(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MySize.getWidth(3),
                          height: MySize.getHeight(22),
                          decoration: BoxDecoration(
                            color: ColorConstants.primaryColor,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(10)),
                        Expanded(
                          child: Text(
                            TranslationKeys.createRefund.tr,
                            style: TextStyle(
                              fontSize: MySize.getHeight(16),
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MySize.getHeight(14)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.getWidth(12),
                        vertical: MySize.getHeight(10),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius:
                            BorderRadius.circular(MySize.getHeight(8)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildRefundSummaryRow(
                            TranslationKeys.amount.tr,
                            widget.paymentAmount,
                          ),
                          SizedBox(height: MySize.getHeight(8)),
                          _buildRefundSummaryRow(
                            TranslationKeys.alreadyRefunded.tr,
                            widget.alreadyRefundedAmount,
                          ),
                          SizedBox(height: MySize.getHeight(8)),
                          _buildRefundSummaryRow(
                            TranslationKeys.availableToRefund.tr,
                            widget.refundableAmount,
                            valueColor: ColorConstants.primaryColor,
                            valueWeight: FontWeight.w800,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(14)),
                    Text(
                      TranslationKeys.amount.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(6)),
                    TextField(
                      controller: _amountController,
                      style: TextStyle(fontSize: MySize.getHeight(13)),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _clearAmountError(),
                      decoration: _buildTextFieldDecoration(
                        errorText: _amountErrorText,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(12)),
                    Text(
                      TranslationKeys.reasonOptional.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(6)),
                    TextField(
                      controller: _reasonController,
                      style: TextStyle(fontSize: MySize.getHeight(13)),
                      minLines: 3,
                      maxLines: 3,
                      decoration: _buildTextFieldDecoration(
                        hintText: TranslationKeys.enterReason.tr,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize:
                                  Size.fromHeight(MySize.getHeight(40)),
                              padding: EdgeInsets.symmetric(
                                vertical: MySize.getHeight(10),
                              ),
                              textStyle: TextStyle(
                                fontSize: MySize.getHeight(13),
                                fontWeight: FontWeight.w700,
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  MySize.getHeight(8),
                                ),
                              ),
                            ),
                            child: Text(
                              TranslationKeys.cancel.tr,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(10)),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed:
                                _isSubmitting ? null : _validateAndSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize:
                                  Size.fromHeight(MySize.getHeight(40)),
                              padding: EdgeInsets.symmetric(
                                vertical: MySize.getHeight(10),
                              ),
                              textStyle: TextStyle(
                                fontSize: MySize.getHeight(13),
                                fontWeight: FontWeight.w800,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  MySize.getHeight(8),
                                ),
                              ),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    width: MySize.getWidth(18),
                                    height: MySize.getHeight(18),
                                    child: const CupertinoActivityIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    TranslationKeys.createRefund.tr,
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

