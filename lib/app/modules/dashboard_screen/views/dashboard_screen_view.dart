import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/model/chartModel.dart';

import '../controllers/dashboard_screen_controller.dart';

class DashboardScreenView extends GetWidget<DashboardScreenController> {
  const DashboardScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardScreenController>(
      init: DashboardScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          backgroundColor: ColorConstants.bgColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabSwitcher(
                    title: "Statistics",
                    tabs: controller.statisticTabs,
                    selectedTabIndex: controller.statisticSelectedTabIndex,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2,
                    children: [
                      statCard(
                        title: "Today's Orders",
                        value: "11",
                        percentage: "+80.48%",
                        status: true,
                        subtitle: "Since yesterday",
                      ),
                      statCard(
                        title: "Today's Earnings",
                        value: "€ 56.33",
                        percentage: "+49%",
                        status: true,
                        subtitle: "Since yesterday",
                      ),
                      statCard(
                        title: "Today's Customer",
                        value: "3",
                        percentage: "-67.48%",
                        status: false,
                        subtitle: "Since yesterday",
                      ),
                      statCard(
                        title: "Average Daily Earnings (June)",
                        value: "€ 186.54",
                        percentage: "+49%",
                        status: true,
                        subtitle: "Since previous month",
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Obx(() {
                    if (controller.chartData.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return salesChartCard(controller);
                  }),

                  const SizedBox(height: 20),

                  TabSwitcher(
                    title: "Order Details",
                    tabs: controller.orderTabs,
                    selectedTabIndex: controller.orderSelectedTabIndex,
                  ),

                  const SizedBox(height: 20),

                  Obx(() {
                    return Column(
                      children:
                          controller.orders
                              .map((order) => OrderCard(order: order))
                              .toList(),
                    );
                  }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Alerts for low stock :",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${controller.lowStockItems.length} alerts",
                          style: TextStyle(
                            color: ColorConstants.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    return Column(
                      children:
                          controller.lowStockItems.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            size: 16,
                                            color: ColorConstants.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Current: ${item.current} pc',
                                            style: TextStyle(
                                              color: ColorConstants.red,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        item.category,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Threshold: ${item.threshold.toStringAsFixed(2)} pc',
                                        style: TextStyle(
                                          color: ColorConstants.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  }),
                  const SizedBox(height: 10),
                  Text(
                    "Top Selling Tables (Today)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  buildTopTableList(controller.tables),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget salesChartCard(DashboardScreenController controller) {
    ChartDataModel currentData =
        controller.chartData[controller.statisticSelectedTabIndex.value];

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentData.amount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sales This ${controller.statisticTabs[controller.statisticSelectedTabIndex.value]}',
                    style: const TextStyle(
                      color: ColorConstants.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        currentData.status
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color:
                            currentData.status
                                ? ColorConstants.green
                                : ColorConstants.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentData.percentage,
                        style: TextStyle(
                          color:
                              currentData.status
                                  ? ColorConstants.green
                                  : ColorConstants.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Since Previous Month',
                    style: TextStyle(
                      color: ColorConstants.grey600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '€ ${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: ColorConstants.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                    spots: currentData.points,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statCard({
    required String title,
    required String value,
    required String percentage,
    required bool status,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ColorConstants.getShadow2,
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: ColorConstants.grey800, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                status ? Icons.arrow_upward : Icons.arrow_downward,
                color: status ? ColorConstants.green : ColorConstants.red,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: TextStyle(
                  color: status ? ColorConstants.green : ColorConstants.red,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: ColorConstants.grey600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TabSwitcher extends StatelessWidget {
  final String title;
  final List<String> tabs;
  final RxInt selectedTabIndex;

  const TabSwitcher({
    super.key,
    required this.title,
    required this.tabs,
    required this.selectedTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title :",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Obx(() {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                bool isSelected = selectedTabIndex.value == index;
                return GestureDetector(
                  onTap: () {
                    selectedTabIndex.value = index;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
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

Widget buildTopTableList(List<TableData> tables) {
  return Column(
    children: List.generate(tables.length, (index) {
      final table = tables[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ColorConstants.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "#${index + 1}",
                    style: const TextStyle(
                      color: ColorConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  table.tableName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              "€ ${table.total.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }),
  );
}
