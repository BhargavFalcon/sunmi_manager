import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/modules/order_screen/controllers/order_screen_controller.dart';
import 'package:managerapp/app/widgets/running_table_dialog.dart';
import 'package:managerapp/app/widgets/access_limited_dialog.dart';
import 'package:managerapp/app/routes/app_pages.dart';

import '../../../constants/image_constants.dart';
import '../../../constants/translation_keys.dart';
import '../../../model/AllOrdersModel.dart' as orderModel;
import '../../../model/getorderModel.dart' as orderDetailsModel;
import '../../../model/RestaurantDetailsModel.dart';
import '../../../services/sunmi_invoice_printer_service.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/date_time_formatter.dart';
import '../../../../main.dart';
import '../../../constants/api_constants.dart';

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
                                                                5,
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
                                                                    12,
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
                                                            controller
                                                                .showCustomDateRangePickerPop(
                                                                  context,
                                                                );
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
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                        SizedBox(width: MySize.getWidth(4)),
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
                                                                6,
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
                                                        Text(
                                                          _translateOrderFilter(
                                                            controller
                                                                .selectedOrderFilter
                                                                .value,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize:
                                                                MySize.getHeight(
                                                                  12,
                                                                ),
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                              12,
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
                                      final selectedType =
                                          controller.selectedOrderType.value;
                                      final shortestSide =
                                          MediaQuery.of(
                                            context,
                                          ).size.shortestSide;
                                      final isTablet = shortestSide >= 600;
                                      return Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              MySize.getHeight(8),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              MySize.getHeight(2),
                                            ),
                                            child:
                                                isTablet
                                                    ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          child: _buildOrderTypeButton(
                                                            icon:
                                                                ImageConstant
                                                                    .allOrders,
                                                            label:
                                                                TranslationKeys
                                                                    .allOrders
                                                                    .tr,
                                                            isSelected:
                                                                selectedType ==
                                                                'All Orders',
                                                            onTap:
                                                                () => controller
                                                                    .updateOrderType(
                                                                      'All Orders',
                                                                    ),
                                                            isTablet: isTablet,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: _buildOrderTypeButton(
                                                            icon:
                                                                ImageConstant
                                                                    .dinein,
                                                            label:
                                                                TranslationKeys
                                                                    .dineIn
                                                                    .tr,
                                                            isSelected:
                                                                selectedType ==
                                                                'Dine In',
                                                            onTap:
                                                                () => controller
                                                                    .updateOrderType(
                                                                      'Dine In',
                                                                    ),
                                                            isTablet: isTablet,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: _buildOrderTypeButton(
                                                            icon:
                                                                ImageConstant
                                                                    .pickup,
                                                            label:
                                                                TranslationKeys
                                                                    .pickup
                                                                    .tr,
                                                            isSelected:
                                                                selectedType ==
                                                                'Pickup',
                                                            onTap:
                                                                () => controller
                                                                    .updateOrderType(
                                                                      'Pickup',
                                                                    ),
                                                            isTablet: isTablet,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: _buildOrderTypeButton(
                                                            icon:
                                                                ImageConstant
                                                                    .delivery,
                                                            label:
                                                                TranslationKeys
                                                                    .delivery
                                                                    .tr,
                                                            isSelected:
                                                                selectedType ==
                                                                'Delivery',
                                                            onTap:
                                                                () => controller
                                                                    .updateOrderType(
                                                                      'Delivery',
                                                                    ),
                                                            isTablet: isTablet,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                    : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        _buildOrderTypeButton(
                                                          icon:
                                                              ImageConstant
                                                                  .allOrders,
                                                          label:
                                                              TranslationKeys
                                                                  .allOrders
                                                                  .tr,
                                                          isSelected:
                                                              selectedType ==
                                                              'All Orders',
                                                          onTap:
                                                              () => controller
                                                                  .updateOrderType(
                                                                    'All Orders',
                                                                  ),
                                                          isTablet: isTablet,
                                                        ),
                                                        _buildOrderTypeButton(
                                                          icon:
                                                              ImageConstant
                                                                  .dinein,
                                                          label:
                                                              TranslationKeys
                                                                  .dineIn
                                                                  .tr,
                                                          isSelected:
                                                              selectedType ==
                                                              'Dine In',
                                                          onTap:
                                                              () => controller
                                                                  .updateOrderType(
                                                                    'Dine In',
                                                                  ),
                                                          isTablet: isTablet,
                                                        ),
                                                        _buildOrderTypeButton(
                                                          icon:
                                                              ImageConstant
                                                                  .pickup,
                                                          label:
                                                              TranslationKeys
                                                                  .pickup
                                                                  .tr,
                                                          isSelected:
                                                              selectedType ==
                                                              'Pickup',
                                                          onTap:
                                                              () => controller
                                                                  .updateOrderType(
                                                                    'Pickup',
                                                                  ),
                                                          isTablet: isTablet,
                                                        ),
                                                        _buildOrderTypeButton(
                                                          icon:
                                                              ImageConstant
                                                                  .delivery,
                                                          label:
                                                              TranslationKeys
                                                                  .delivery
                                                                  .tr,
                                                          isSelected:
                                                              selectedType ==
                                                              'Delivery',
                                                          onTap:
                                                              () => controller
                                                                  .updateOrderType(
                                                                    'Delivery',
                                                                  ),
                                                          isTablet: isTablet,
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
                              SizedBox(height: MySize.getHeight(12)),
                              Expanded(
                                child: Obx(() {
                                  if (controller.isLoading.value &&
                                      controller.allOrders.isEmpty) {
                                    return Center(
                                      child: CupertinoActivityIndicator(
                                        radius: MySize.getHeight(12),
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
                    color: Colors.black.withOpacity(0.2),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(MySize.getWidth(20)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CupertinoActivityIndicator(
                          radius: MySize.getHeight(12),
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
        if (controller.allOrders.isEmpty && !controller.isLoading.value) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MySize.getHeight(400),
              child: Center(
                child: Text(
                  TranslationKeys.noOrdersFound.tr,
                  style: TextStyle(
                    fontSize: MySize.getHeight(18),
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
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
              controller.allOrders.length +
              (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: MySize.getHeight(10)),
          itemBuilder: (context, index) {
            if (index == controller.allOrders.length) {
              return Padding(
                padding: EdgeInsets.all(MySize.getWidth(16)),
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: MySize.getHeight(12),
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
    orderModel.Orders order,
  ) async {
    final orderUuid = order.uuid;
    if (orderUuid == null || orderUuid.isEmpty) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.orderUuidNotFound.tr,
      );
      return;
    }

    if (!context.mounted) return;

    final screenHeight = MediaQuery.of(context).size.height;

    // API call only once when bottom sheet opens
    if (!controller.isLoadingOrderDetails.value &&
        controller.orderDetails.value?.data?.order?.uuid != orderUuid) {
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
    orderModel.Orders order,
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
            if (orderData != null) _buildStickyButtons(context, orderData),
          ],
        );
      }),
    );
  }

  Widget _buildStickyButtons(
    BuildContext context,
    orderDetailsModel.Data orderData,
  ) {
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
            color: Colors.black.withOpacity(0.1),
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
                    fontSize: MySize.getHeight(14),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: MySize.getWidth(12)),
          Expanded(
            child: Obx(() {
              final isPrinting = controller.isPrinting.value;
              return InkWell(
                onTap:
                    isPrinting
                        ? null
                        : () => _printInvoice(context, controller, orderData),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MySize.getWidth(16),
                    vertical: MySize.getHeight(10),
                  ),
                  decoration: BoxDecoration(
                    color:
                        isPrinting
                            ? const Color(0xFF0E9F6E).withOpacity(0.7)
                            : const Color(0xFF0E9F6E),
                    borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  child: Row(
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
                      if (!isPrinting) SizedBox(width: MySize.getWidth(6)),
                      if (!isPrinting)
                        Text(
                          TranslationKeys.print.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MySize.getHeight(14),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
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
    orderModel.Orders order,
  ) {
    final orderDetails = controller.orderDetails.value;
    final orderData = orderDetails?.data?.order;

    if (orderData == null || orderDetails?.data == null) {
      return _buildErrorView(context);
    }

    return _buildOrderDetailsContent(context, orderDetails!.data!, order);
  }

  Widget _buildLoadingView() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(MySize.getWidth(24)),
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
              fontSize: MySize.getHeight(16),
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
                  fontSize: MySize.getHeight(14),
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
    orderDetailsModel.Data orderData,
    orderModel.Orders order,
  ) {
    final orderDetails = orderData.order;
    return Padding(
      padding: EdgeInsets.all(MySize.getWidth(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                ImageConstant.order,
                height: MySize.getHeight(24),
                width: MySize.getHeight(24),
              ),
              SizedBox(width: MySize.getWidth(8)),
              Expanded(
                child: Text(
                  '${orderDetails?.formattedOrderNumber ?? order.id ?? ''} (${_formatOrderType(orderDetails?.orderType)})',
                  style: TextStyle(
                    fontSize: MySize.getHeight(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(8)),
          _buildOrderTimeInfo(orderDetails),
          SizedBox(height: MySize.getHeight(8)),
          if (orderDetails?.customer != null &&
              _hasCustomerInfo(orderDetails!.customer!))
            _buildCustomerDetails(orderDetails.customer!),
          if (orderDetails?.customer != null &&
              _hasCustomerInfo(orderDetails!.customer!))
            SizedBox(height: MySize.getHeight(8)),
          Builder(
            builder: (context) {
              final shouldShowWaiter =
                  (orderDetails?.customer == null ||
                      !_hasCustomerInfo(orderDetails?.customer)) &&
                  _isDineInOrder(orderDetails?.orderType) &&
                  _hasWaiterInfo(orderDetails?.waiter);

              if (!shouldShowWaiter) return const SizedBox.shrink();

              return Column(
                children: [
                  _buildWaiterDetails(orderDetails!.waiter!),
                  SizedBox(height: MySize.getHeight(8)),
                ],
              );
            },
          ),
          _buildOrderItemsTable(orderData),
          SizedBox(height: MySize.getHeight(8)),
          _buildPriceSummary(orderData),
          SizedBox(height: MySize.getHeight(16)),
        ],
      ),
    );
  }

  Widget _buildOrderTimeInfo(dynamic orderDetails) {
    if (orderDetails == null) return const SizedBox.shrink();

    final createdAt = orderDetails.createdAt ?? '';
    final orderType = orderDetails.orderType?.toLowerCase() ?? '';
    final dateTimeString = orderDetails.dateTime ?? '';

    final List<String> timeInfoList = [];

    if (createdAt.isNotEmpty) {
      final formattedCreatedAt = formatOrderDateTimeForCard(createdAt);
      timeInfoList.add(
        '${TranslationKeys.orderCreated.tr}: $formattedCreatedAt',
      );
    }

    if (dateTimeString.isNotEmpty) {
      final formattedDateTime = formatOrderDateTimeForCard(dateTimeString);
      final timeLabel = _getTimeLabel(orderType);
      if (timeLabel != null) {
        timeInfoList.add('$timeLabel: $formattedDateTime');
      }
    }

    if (timeInfoList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(MySize.getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            timeInfoList
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          entry.key < timeInfoList.length - 1
                              ? MySize.getHeight(8)
                              : 0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: MySize.getHeight(18),
                          color: ColorConstants.primaryColor,
                        ),
                        SizedBox(width: MySize.getWidth(8)),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: MySize.getHeight(12),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  String? _getTimeLabel(String orderType) {
    if (orderType == 'delivery' || orderType == 'delivery_order') {
      return TranslationKeys.deliveryTime.tr;
    } else if (orderType == 'pickup' || orderType == 'pickup_order') {
      return TranslationKeys.pickupTime.tr;
    }
    return null;
  }

  static String formatOrderDateTimeForCard(String? dateTimeString) {
    return DateTimeFormatter.formatDateTime(dateTimeString);
  }

  String _formatOrderType(String? orderType) {
    if (orderType == null || orderType.isEmpty) {
      return 'N/A';
    }
    switch (orderType.toLowerCase()) {
      case 'dine_in':
        return TranslationKeys.dineIn.tr;
      case 'pickup':
        return TranslationKeys.pickup.tr;
      case 'delivery':
        return TranslationKeys.delivery.tr;
      default:
        return TranslationKeys.na.tr;
    }
  }

  Widget _buildOrderItemsTable(orderDetailsModel.Data orderData) {
    final orderDetails = orderData.order;
    final items = orderDetails?.items ?? [];
    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(MySize.getWidth(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: ColorConstants.getShadow2,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        ),
        child: Center(
          child: Text(
            TranslationKeys.noItemsFound.tr,
            style: TextStyle(
              fontSize: MySize.getHeight(18),
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.7),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(0.8),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
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
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.noHeader.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(10),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.itemNames.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(10),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.qty.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(10),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.priceHeader.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(10),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(MySize.getWidth(6)),
                child: Text(
                  TranslationKeys.amountHeader.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(10),
                  ),
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
                          '${m.name ?? ''}${m.price != null && m.price! > 0 ? ' : ${CurrencyFormatter.formatPrice(m.price!.toString())}' : ''}',
                    )
                    .toList();
            if (item.variationName != null && item.variationName!.isNotEmpty) {
              details.insert(0, 'Variation: ${item.variationName}');
            }
            final priceStr =
                item.price is num
                    ? item.price.toString()
                    : (item.price?.toString() ?? '0');
            final amountStr =
                item.amount is num
                    ? item.amount.toString()
                    : (item.amount?.toString() ?? '0');

            return _buildTableRow(
              itemName: item.itemName ?? 'N/A',
              details: details,
              qty: item.quantity?.toString() ?? '0',
              price: CurrencyFormatter.formatPrice(priceStr),
              amount: CurrencyFormatter.formatPrice(amountStr),
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
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Text(
            itemNumber,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MySize.getHeight(12),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MySize.getHeight(12),
                ),
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
                                fontSize: MySize.getHeight(12),
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                          .toList(),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Text(qty, style: TextStyle(fontSize: MySize.getHeight(12))),
        ),
        Padding(
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Text(price, style: TextStyle(fontSize: MySize.getHeight(12))),
        ),
        Padding(
          padding: EdgeInsets.all(MySize.getWidth(6)),
          child: Text(amount, style: TextStyle(fontSize: MySize.getHeight(12))),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(orderDetailsModel.Data orderData) {
    final orderDetails = orderData.order;
    final totals = orderDetails?.totals;
    final itemsCount = orderDetails?.items?.length ?? 0;
    final taxes = orderData.taxes ?? [];
    final charges = orderDetails?.charges ?? [];
    final isTaxIncluded = _isTaxIncluded(orderData);

    return Container(
      padding: EdgeInsets.all(MySize.getWidth(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: MySize.getWidth(1),
            blurRadius: MySize.getWidth(3),
            offset: Offset(0, MySize.getHeight(1)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TranslationKeys.items.tr}${itemsCount > 0 ? ' ($itemsCount)' : ''}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MySize.getHeight(14),
            ),
          ),
          SizedBox(height: MySize.getHeight(8)),

          if (totals?.subTotal != null)
            _buildPriceRow(
              '${TranslationKeys.subTotal.tr}:',
              CurrencyFormatter.formatPrice(totals!.subTotal.toString()),
            ),

          if (charges.isNotEmpty)
            ...charges.map((charge) {
              final chargeAmount =
                  charge.amount is num
                      ? (charge.amount as num).toDouble()
                      : double.tryParse(charge.amount?.toString() ?? '0') ??
                          0.0;
              if (chargeAmount <= 0) return const SizedBox.shrink();
              return _buildPriceRow(
                charge.chargeName ?? TranslationKeys.charge.tr,
                CurrencyFormatter.formatPrice(chargeAmount.toString()),
              );
            }),

          if (taxes.isNotEmpty)
            ...taxes.map((tax) {
              final taxAmount =
                  tax.amount is num
                      ? (tax.amount as num).toDouble()
                      : double.tryParse(tax.amount?.toString() ?? '0') ?? 0.0;
              if (taxAmount <= 0) return const SizedBox.shrink();

              final formattedAmount = CurrencyFormatter.formatPrice(
                taxAmount.toString(),
              );
              final percent = tax.percent?.toString() ?? '';
              final taxSuffix =
                  isTaxIncluded ? ' ${TranslationKeys.incl.tr}:' : ':';
              final taxLabel =
                  percent.isNotEmpty
                      ? '${tax.taxName ?? TranslationKeys.tax.tr} ($percent%)$taxSuffix'
                      : '${tax.taxName ?? TranslationKeys.tax.tr}$taxSuffix';
              return _buildPriceRow(taxLabel, formattedAmount);
            }),

          ...() {
            if (totals?.tipAmount == null) return <Widget>[];
            final tipAmountStr =
                totals!.tipAmount is num
                    ? totals.tipAmount.toString()
                    : (totals.tipAmount?.toString() ?? '0');
            if (!_isValidAmount(tipAmountStr)) return <Widget>[];
            return [
              _buildPriceRow(
                '${TranslationKeys.tip.tr}:',
                CurrencyFormatter.formatPrice(tipAmountStr),
              ),
            ];
          }(),
          ...() {
            if (orderDetails!.totals!.discountAmount == null) return <Widget>[];
            final discountValue =
                orderDetails.totals!.discountAmount is num
                    ? (orderDetails.totals!.discountAmount as num).toDouble()
                    : double.tryParse(
                          orderDetails.totals!.discountAmount.toString(),
                        ) ??
                        0.0;
            if (discountValue <= 0) return <Widget>[];
            final couponCode = orderDetails.couponCode;
            final discountLabel =
                couponCode != null && couponCode.isNotEmpty
                    ? '${TranslationKeys.discount.tr} ($couponCode):'
                    : '${TranslationKeys.discount.tr}:';
            return [
              _buildPriceRow(
                discountLabel,
                '-${CurrencyFormatter.formatPrice(discountValue.toString())}',
                valueColor: const Color(0xFF0B9F6E),
              ),
            ];
          }(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: MySize.getHeight(8)),
            child: Divider(
              height: MySize.getHeight(1),
              thickness: MySize.getHeight(1),
              color: Colors.grey,
            ),
          ),

          if (totals?.total != null)
            _buildPriceRow(
              '${TranslationKeys.total.tr}:',
              CurrencyFormatter.formatPrice(totals!.total.toString()),
              isBold: true,
              valueColor: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(orderDetailsModel.Customer customer) {
    return Container(
      padding: EdgeInsets.all(MySize.getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: MySize.getWidth(1),
            blurRadius: MySize.getWidth(3),
            offset: Offset(0, MySize.getHeight(1)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                size: MySize.getHeight(20),
                color: ColorConstants.primaryColor,
              ),
              SizedBox(width: MySize.getWidth(8)),
              Text(
                TranslationKeys.customerDetails.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(12)),
          if (customer.name != null && customer.name!.isNotEmpty)
            _buildDetailRow(TranslationKeys.name.tr, customer.name!),
          if (customer.email != null && customer.email!.isNotEmpty)
            _buildDetailRow(TranslationKeys.email.tr, customer.email!),
          if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty)
            _buildDetailRow(
              TranslationKeys.phone.tr,
              '${customer.phoneCode ?? ''}${customer.phoneNumber}',
            ),
        ],
      ),
    );
  }

  bool _hasCustomerInfo(orderDetailsModel.Customer? customer) {
    if (customer == null) return false;
    return (customer.name != null && customer.name!.isNotEmpty) ||
        (customer.email != null && customer.email!.isNotEmpty) ||
        (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty);
  }

  bool _isDineInOrder(String? orderType) {
    if (orderType == null) return false;
    final type = orderType.toLowerCase().replaceAll(' ', '_');
    return type == 'dine_in' || type == 'dinein' || type == 'dine in';
  }

  bool _hasWaiterInfo(orderDetailsModel.Waiter? waiter) {
    if (waiter == null) return false;
    return (waiter.name != null && waiter.name!.trim().isNotEmpty) ||
        waiter.id != null ||
        (waiter.email != null && waiter.email!.trim().isNotEmpty) ||
        (waiter.phoneNumber != null && waiter.phoneNumber!.trim().isNotEmpty);
  }

  Widget _buildWaiterDetails(orderDetailsModel.Waiter waiter) {
    final hasName = waiter.name != null && waiter.name!.trim().isNotEmpty;
    final hasId = waiter.id != null;

    if (!hasName && !hasId) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(MySize.getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: MySize.getWidth(1),
            blurRadius: MySize.getWidth(3),
            offset: Offset(0, MySize.getHeight(1)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                size: MySize.getHeight(20),
                color: ColorConstants.primaryColor,
              ),
              SizedBox(width: MySize.getWidth(8)),
              Text(
                TranslationKeys.waiter.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.getHeight(12)),
          if (waiter.name != null && waiter.name!.trim().isNotEmpty)
            _buildDetailRow(TranslationKeys.name.tr, waiter.name!),
          if (waiter.email != null && waiter.email!.trim().isNotEmpty)
            _buildDetailRow(TranslationKeys.email.tr, waiter.email!),
          if (waiter.phoneNumber != null &&
              waiter.phoneNumber!.trim().isNotEmpty)
            _buildDetailRow(
              TranslationKeys.phone.tr,
              '${waiter.phoneCode ?? ''}${waiter.phoneNumber}',
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: MySize.getHeight(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MySize.getWidth(80),
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: MySize.getHeight(12),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: MySize.getHeight(12),
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Branches? _getBranch() {
    try {
      final storedData = box.read(ArgumentConstant.restaurantDetailsKey);
      if (storedData == null || storedData is! Map<String, dynamic>) {
        return null;
      }
      final restaurantDetails = RestaurantModel.fromJson(storedData);
      if (restaurantDetails.data?.branches == null ||
          restaurantDetails.data!.branches!.isEmpty) {
        return null;
      }
      return restaurantDetails.data!.branches!.first;
    } catch (e) {
      return null;
    }
  }

  bool _isTaxIncluded(orderDetailsModel.Data orderData) {
    if (orderData.taxInclusive != null) {
      return orderData.taxInclusive == true;
    }
    final branch = _getBranch();
    return branch?.taxesIncluded == true;
  }

  Future<void> _printInvoice(
    BuildContext context,
    OrderScreenController controller,
    orderDetailsModel.Data orderData,
  ) async {
    if (Platform.isIOS) {
      safeGetSnackbar(
        TranslationKeys.warning.tr,
        TranslationKeys.printOnlyAvailableOnAndroid.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade700,
      );
      return;
    }

    if (orderData.order == null) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.invoiceDataNotFound.tr,
      );
      return;
    }

    try {
      controller.isPrinting.value = true;
      final printerService = SunmiInvoicePrinterService();
      await printerService.printInvoice(orderData);
    } catch (e) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        TranslationKeys.somethingWentWrong.tr,
      );
    } finally {
      controller.isPrinting.value = false;
    }
  }
}

bool _isValidAmount(String? amount) {
  if (amount == null ||
      amount.isEmpty ||
      amount == 'null' ||
      amount == '0' ||
      amount == '0.0' ||
      amount == '0.00') {
    return false;
  }
  final value = double.tryParse(amount);
  return value != null && value > 0;
}

Widget _buildPriceRow(
  String label,
  String value, {
  bool isBold = false,
  Color? valueColor,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: MySize.getHeight(4)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: MySize.getHeight(12),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: MySize.getHeight(12),
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
  required bool isTablet,
}) {
  return _OrderTypeButtonItem(
    icon: icon,
    label: label,
    isSelected: isSelected,
    onTap: onTap,
    isTablet: isTablet,
  );
}

class OrderCard extends StatelessWidget {
  final orderModel.Orders order;
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

    final formattedDateTime =
        order.dateTime != null && order.dateTime!.isNotEmpty
            ? OrderScreenView.formatOrderDateTimeForCard(order.dateTime)
            : (order.formattedDateTime ?? '');
    final itemsCount = order.itemsCount ?? 0;
    final formattedPrice = CurrencyFormatter.formatPrice(order.total ?? '0');
    final waiterName = order.waiter?.name ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        boxShadow: ColorConstants.getShadow2,
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
                    color: ColorConstants.primaryColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: ColorConstants.primaryColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(MySize.getHeight(6)),
                  ),
                  child:
                      order.orderType?.toLowerCase() == 'pickup'
                          ? Image.asset(
                            ImageConstant.pickup_all,
                            width: MySize.getHeight(16),
                            height: MySize.getHeight(16),
                          )
                          : order.orderType?.toLowerCase() == 'delivery'
                          ? Image.asset(
                            ImageConstant.delivery_all,
                            color: ColorConstants.primaryColor,
                            width: MySize.getHeight(16),
                            height: MySize.getHeight(16),
                          )
                          : Text(
                            tableCode,
                            style: TextStyle(
                              color: ColorConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: MySize.getHeight(10),
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
                          fontSize: MySize.getHeight(11),
                        ),
                      ),
                      if (order.customer != null && customerName.isNotEmpty)
                        Text(
                          customerName,
                          style: TextStyle(
                            color: ColorConstants.grey600,
                            fontSize: MySize.getHeight(10),
                          ),
                        ),
                    ],
                  ),
                ),
                _statusBadge(formattedStatus, statusColor),
              ],
            ),
            SizedBox(height: MySize.getHeight(6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formattedDateTime,
                    style: TextStyle(
                      color: ColorConstants.grey600,
                      fontSize: MySize.getHeight(11),
                    ),
                  ),
                ),
                Text(
                  "$itemsCount ${TranslationKeys.itemsPlural.tr}",
                  style: TextStyle(
                    color: ColorConstants.grey600,
                    fontSize: MySize.getHeight(11),
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey.shade300,
              thickness: MySize.getHeight(1),
              height: MySize.getHeight(10),
            ),
            Row(
              children: [
                Text(
                  formattedPrice,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MySize.getHeight(14),
                  ),
                ),
                SizedBox(width: MySize.getWidth(10)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (order.coupon != null && order.coupon!.code != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(6),
                          ),
                          border: Border.all(
                            color: Colors.purple.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${TranslationKeys.coupon.tr.toUpperCase()}: ${order.coupon!.code!.toUpperCase()}',
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontSize: MySize.getHeight(10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (order.coupon != null &&
                        order.coupon!.code != null &&
                        waiterName.isNotEmpty)
                      const Spacer(),
                    if (waiterName.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            ImageConstant.order,
                            width: MySize.getHeight(18),
                            height: MySize.getHeight(18),
                          ),
                          SizedBox(width: MySize.getWidth(6)),
                          Text(
                            waiterName,
                            style: TextStyle(fontSize: MySize.getHeight(11)),
                          ),
                        ],
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
          fontSize: MySize.getHeight(9),
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
                                    fontSize: MySize.getHeight(12),
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
                                        fontSize: MySize.getHeight(12),
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
