import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      ...controller.tableModel.value!.data!.asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final area = entry.value;
                          final isSelected =
                              controller.selectedAreaIndex.value == index;
                          final runningCount =
                              area.tables
                                  ?.where(
                                    (table) =>
                                        table.availableStatus?.toLowerCase() ==
                                        'running',
                                  )
                                  .length ??
                              0;
                          return GestureDetector(
                            onTap: () {
                              controller.selectedAreaIndex.value = index;
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 16),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
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
                                              ? ColorConstants.primaryColor
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
                                        color: ColorConstants.primaryColor,
                                        borderRadius: BorderRadius.circular(10),
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
                        },
                      ),
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
                                              (table.width ?? 100).toDouble();
                                          final height =
                                              (table.height ?? 100).toDouble();
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
                                              table.status?.toLowerCase() ?? '';
                                          final isActive = status == 'active';
                                          final tableColor =
                                              !isActive
                                                  ? ColorConstants.primaryColor
                                                      .withValues(alpha: 0.3)
                                                  : availableStatus == 'running'
                                                  ? ColorConstants.tableBlue
                                                  : availableStatus ==
                                                      'available'
                                                  ? ColorConstants.tableGreen
                                                  : Colors.grey;

                                          return Positioned(
                                            left: left,
                                            top: top,
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
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                              if (table
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
                                                                        Colors
                                                                            .white,
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
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                            if (table
                                                                    .seatingCapacity !=
                                                                null)
                                                              Text(
                                                                '${table.seatingCapacity} Seat(s)',
                                                                style: TextStyle(
                                                                  fontSize: MySize
                                                                      .getHeight(
                                                                        10,
                                                                      ),
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                          ],
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
