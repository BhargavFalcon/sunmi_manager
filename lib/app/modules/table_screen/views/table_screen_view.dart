import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/model/tableModel.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';

import '../controllers/table_screen_controller.dart';

class TableScreenView extends GetWidget<TableScreenController> {
  const TableScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return GetBuilder<TableScreenController>(
      init: TableScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Stack(
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
                        "Table",
                        style: TextStyle(
                          fontSize: MySize.getHeight(20),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Expanded(
                        child: Center(
                          child: CupertinoActivityIndicator(
                            radius: 15,
                            color: ColorConstants.primaryColor,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return SizedBox.shrink();
                    }
                    if (controller.tableModel.value?.data == null ||
                        controller.tableModel.value!.data!.isEmpty) {
                      return SizedBox.shrink();
                    }
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          ...controller.tableModel.value!.data!
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final area = entry.value;
                                final isSelected =
                                    controller.selectedAreaIndex.value == index;
                                final runningCount =
                                    area.tables
                                        ?.where(
                                          (table) =>
                                              table.availableStatus
                                                  ?.toLowerCase() ==
                                              'running',
                                        )
                                        .length ??
                                    0;
                                return GestureDetector(
                                  onTap: () {
                                    controller.selectedAreaIndex.value = index;
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 12),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? ColorConstants.primaryColor
                                                  .withValues(alpha: 0.1)
                                              : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          area.name ?? '',
                                          style: TextStyle(
                                            fontSize: MySize.getHeight(12),
                                            color:
                                                isSelected
                                                    ? ColorConstants
                                                        .primaryColor
                                                    : Colors.grey,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                        if (runningCount > 0)
                                          Container(
                                            margin: EdgeInsets.only(left: 6),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  ColorConstants.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '$runningCount',
                                              style: TextStyle(
                                                fontSize: MySize.getHeight(8),
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: ColorConstants.tableGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Available',
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(10),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: ColorConstants.tableBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Running',
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(10),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return SizedBox.shrink();
                    }
                    final selectedArea =
                        controller.tableModel.value?.data != null &&
                                controller.selectedAreaIndex.value <
                                    controller.tableModel.value!.data!.length
                            ? controller.tableModel.value!.data![controller
                                .selectedAreaIndex
                                .value]
                            : null;
                    final tables = selectedArea?.tables ?? [];

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          controller: controller.verticalScrollController,
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            controller: controller.horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Center(
                              child: SizedBox(
                                width: 1000,
                                height: 1000,
                                child: CustomPaint(
                                  painter: DottedBorderPainter(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Container(
                                      width: 1000,
                                      height: 1000,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: ColorConstants.getShadow2,
                                      ),
                                      child: Stack(
                                        children:
                                            tables.map((table) {
                                              final left =
                                                  (table.left ?? 0).toDouble();
                                              final top =
                                                  (table.top ?? 0).toDouble();
                                              final width =
                                                  (table.width ?? 100)
                                                      .toDouble();
                                              final height =
                                                  (table.height ?? 100)
                                                      .toDouble();
                                              final shape =
                                                  (table.shape ?? 'rectangle')
                                                      .toLowerCase();
                                              final isCircle =
                                                  shape == 'circle' ||
                                                  shape == 'round' ||
                                                  shape == 'circular';
                                              final isOval = shape == 'oval';
                                              final availableStatus =
                                                  table.availableStatus
                                                      ?.toLowerCase() ??
                                                  '';
                                              final status =
                                                  table.status?.toLowerCase() ??
                                                  '';
                                              final isActive =
                                                  status == 'active';
                                              final tableColor =
                                                  !isActive
                                                      ? ColorConstants
                                                          .primaryColor
                                                          .withValues(
                                                            alpha: 0.3,
                                                          )
                                                      : availableStatus ==
                                                          'running'
                                                      ? ColorConstants.tableBlue
                                                      : availableStatus ==
                                                          'available'
                                                      ? ColorConstants
                                                          .tableGreen
                                                      : Colors.grey;

                                              final isGreenTable =
                                                  availableStatus ==
                                                      'available' &&
                                                  isActive;
                                              final isBlueTable =
                                                  availableStatus ==
                                                      'running' &&
                                                  isActive;

                                              final activeOrder =
                                                  table.activeOrder;
                                              final activeOrderTotal =
                                                  activeOrder?.total;
                                              final formattedActiveTotal =
                                                  (isBlueTable &&
                                                          activeOrderTotal !=
                                                              null)
                                                      ? CurrencyFormatter.formatPriceFromDouble(
                                                        activeOrderTotal,
                                                      )
                                                      : null;

                                              return Positioned(
                                                left: left,
                                                top: top,
                                                child: GestureDetector(
                                                  onTap:
                                                      isGreenTable
                                                          ? () {
                                                            controller
                                                                .navigateToTakeOrderScreen(
                                                                  table,
                                                                );
                                                          }
                                                          : isBlueTable
                                                          ? () {
                                                            _showRunningTablePopup(
                                                              context,
                                                              controller,
                                                              table,
                                                            );
                                                          }
                                                          : null,
                                                  child:
                                                      isOval
                                                          ? ClipOval(
                                                            child: Container(
                                                              width: width,
                                                              height: height,
                                                              color: tableColor,
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      table.tableCode ??
                                                                          '${table.id}',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            MySize.getHeight(
                                                                              14,
                                                                            ),
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                    if (formattedActiveTotal !=
                                                                        null)
                                                                      Container(
                                                                        margin: const EdgeInsets.only(
                                                                          top:
                                                                              4,
                                                                        ),
                                                                        padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              4,
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.black.withOpacity(
                                                                            0.7,
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                        ),
                                                                        child: Text(
                                                                          formattedActiveTotal,
                                                                          style: TextStyle(
                                                                            fontSize: MySize.getHeight(
                                                                              12,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    else if (table
                                                                            .seatingCapacity !=
                                                                        null)
                                                                      Text(
                                                                        '${table.seatingCapacity} Seat(s)',
                                                                        style: TextStyle(
                                                                          fontSize: MySize.getHeight(
                                                                            10,
                                                                          ),
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          : Container(
                                                            width: width,
                                                            height: height,
                                                            decoration: BoxDecoration(
                                                              color: tableColor,
                                                              shape:
                                                                  isCircle
                                                                      ? BoxShape
                                                                          .circle
                                                                      : BoxShape
                                                                          .rectangle,
                                                              borderRadius:
                                                                  isCircle
                                                                      ? null
                                                                      : BorderRadius.circular(
                                                                        4,
                                                                      ),
                                                            ),
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    table.tableCode ??
                                                                        '${table.id}',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                                  if (formattedActiveTotal !=
                                                                      null)
                                                                    Container(
                                                                      margin:
                                                                          const EdgeInsets.only(
                                                                            top:
                                                                                4,
                                                                          ),
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(
                                                                              0.7,
                                                                            ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              16,
                                                                            ),
                                                                      ),
                                                                      child: Text(
                                                                        formattedActiveTotal,
                                                                        style: TextStyle(
                                                                          fontSize: MySize.getHeight(
                                                                            12,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  else if (table
                                                                          .seatingCapacity !=
                                                                      null)
                                                                    Text(
                                                                      '${table.seatingCapacity} Seat(s)',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            MySize.getHeight(
                                                                              10,
                                                                            ),
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              Obx(() {
                if (controller.isNavigatingToOrder.value) {
                  return Container(
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
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        );
      },
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final dashPath = _dashPath(path, dashArray: [8, 4]);
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path path, {List<double> dashArray = const [5, 5]}) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      var distance = 0.0;
      while (distance < pathMetric.length) {
        final length = dashArray[distance.toInt() % dashArray.length];
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance +=
            length +
            dashArray[(distance.toInt() % dashArray.length + 1) %
                dashArray.length];
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

void _showRunningTablePopup(
  BuildContext context,
  TableScreenController controller,
  Tables table,
) {
  final activeOrder = table.activeOrder;
  final orderNumber = activeOrder?.orderNumber ?? 0;
  final orderTotal =
      activeOrder?.total != null
          ? CurrencyFormatter.formatPriceFromDouble(activeOrder!.total!)
          : CurrencyFormatter.formatPriceFromDouble(0.0);

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${table.tableCode ?? table.id} (Order #$orderNumber)',
                          style: TextStyle(
                            fontSize: MySize.getHeight(16),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(4)),
                        Text(
                          orderTotal,
                          style: TextStyle(
                            fontSize: MySize.getHeight(18),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        ImageConstant.close,
                        width: MySize.getHeight(20),
                        height: MySize.getHeight(20),
                        fit: BoxFit.contain,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MySize.getHeight(20)),
              _buildActionButton(
                imagePath: ImageConstant.continueOrder,
                label: 'Continue to order',
                onTap: () {
                  Navigator.of(context).pop();
                  controller.navigateToTakeOrderScreen(table);
                },
              ),
              SizedBox(height: MySize.getHeight(12)),
              _buildActionButton(
                imagePath: ImageConstant.pay,
                label: 'Pay',
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement pay functionality
                },
              ),
              SizedBox(height: MySize.getHeight(12)),
              _buildActionButton(
                imagePath: ImageConstant.changeTable,
                label: 'Change table',
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement change table functionality
                },
              ),
              SizedBox(height: MySize.getHeight(12)),
              _buildActionButton(
                imagePath: ImageConstant.close,
                label: 'Cancel order',
                textColor: Colors.red,
                imageColor: Colors.red,
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement cancel order functionality
                },
              ),
              SizedBox(height: MySize.getHeight(12)),
              _buildActionButton(
                imagePath: ImageConstant.delete,
                label: 'Delete order',
                textColor: Colors.red,
                imageColor: Colors.red,
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement delete order functionality
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildActionButton({
  String? imagePath,
  IconData? icon,
  required String label,
  required VoidCallback onTap,
  Color? textColor,
  Color? imageColor,
}) {
  return InkWell(
    onTap: onTap,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath,
              width: MySize.getHeight(20),
              height: MySize.getHeight(20),
              fit: BoxFit.contain,
              color: imageColor ?? Colors.black87,
            )
          else if (icon != null)
            Icon(
              icon,
              size: MySize.getHeight(20),
              color: imageColor ?? Colors.black87,
            ),
          SizedBox(width: MySize.getWidth(12)),
          Text(
            label,
            style: TextStyle(
              fontSize: MySize.getHeight(14),
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
