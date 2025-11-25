import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../data/NetworkClient.dart';
import '../../../routes/app_pages.dart';
import '../../../model/chartModel.dart';

class DashboardScreenController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;

  RxInt statisticSelectedTabIndex = 0.obs;
  final List<String> statisticTabs = ['Today', 'Weekly', 'Monthly'];

  RxInt orderSelectedTabIndex = 0.obs;
  final List<String> orderTabs = ['Today', 'Weekly', 'Monthly'];

  RxList<LowStockItem> lowStockItems =
      <LowStockItem>[
        LowStockItem(
          name: 'Lettuce',
          category: 'Fresh Produce',
          current: 1,
          threshold: 20,
        ),
        LowStockItem(
          name: 'Tomato',
          category: 'Fresh Produce',
          current: 5,
          threshold: 15,
        ),
      ].obs;

  final RxList<ChartDataModel> chartData = <ChartDataModel>[].obs;

  final RxList<Order> orders =
      <Order>[
        Order(
          id: "#352",
          customerName: "Rey Nadeem",
          datetime: "June 26, 2025 | 09:01 AM",
          statusText: "Order Preparing",
          statusColor: Colors.purple,
          tag: "KOT",
          tagColor: Colors.purple,
          total: "46.63",
        ),
        Order(
          id: "#353",
          customerName: "Frank Castle",
          datetime: "June 26, 2025 | 01:33 AM",
          statusText: "Order Preparing",
          statusColor: Colors.green,
          tag: "SERVED",
          tagColor: Colors.green,
          total: "24.75",
        ),
        Order(
          id: "#354",
          customerName: "Matt Murdock",
          datetime: "June 26, 2025 | 07:46 PM",
          statusText: "Order Placed",
          statusColor: Colors.orange,
          tag: "PAID",
          tagColor: Colors.orange,
          total: "72.86",
        ),
      ].obs;

  List<TableData> tables = [
    TableData(tableName: 'Table - 05', total: 3240.19),
    TableData(tableName: 'Table - 12', total: 628.54),
    TableData(tableName: 'Table - 07', total: 170.34),
  ];

  @override
  void onInit() {
    super.onInit();
    loadChartData();
  }

  void loadChartData() {
    final List<Map<String, dynamic>> fakeJson = [
      {
        "amount": "€ 18,053.36",
        "percentage": "-49.64%",
        "status": false,
        "points": [
          {"x": 0, "y": 0},
          {"x": 1, "y": 800},
          {"x": 2, "y": 1000},
          {"x": 3, "y": 500},
          {"x": 4, "y": 1500},
          {"x": 5, "y": 2000},
        ],
      },
      {
        "amount": "€ 54,782.90",
        "percentage": "+23.18%",
        "status": true,
        "points": [
          {"x": 0, "y": 0},
          {"x": 1, "y": 2000},
          {"x": 2, "y": 3500},
          {"x": 3, "y": 4000},
          {"x": 4, "y": 3800},
          {"x": 5, "y": 4200},
        ],
      },
      {
        "amount": "€ 1,20,430.12",
        "percentage": "+5.03%",
        "status": true,
        "points": [
          {"x": 0, "y": 0},
          {"x": 1, "y": 3000},
          {"x": 2, "y": 6000},
          {"x": 3, "y": 9000},
          {"x": 4, "y": 7000},
          {"x": 5, "y": 8000},
        ],
      },
    ];

    chartData.assignAll(
      fakeJson.map((e) => ChartDataModel.fromJson(e)).toList(),
    );
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      final response = await networkClient.post(
        ArgumentConstant.logoutEndpoint,
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        networkClient.removeAuthToken();
        box.remove(ArgumentConstant.loginModelKey);
        box.remove(ArgumentConstant.menuItemsKey);
        Get.offAllNamed(Routes.LOGIN_SCREEN);
      }
    } on ApiException catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      isLoading.value = false;
      networkClient.removeAuthToken();
      box.remove(ArgumentConstant.loginModelKey);
      box.remove(ArgumentConstant.menuItemsKey);
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    }
  }
}

class Order {
  final String id;
  final String customerName;
  final String datetime;
  final String statusText;
  final Color statusColor;
  final String tag;
  final Color tagColor;
  final String total;

  const Order({
    required this.id,
    required this.customerName,
    required this.datetime,
    required this.statusText,
    required this.statusColor,
    required this.tag,
    required this.tagColor,
    required this.total,
  });
}

class LowStockItem {
  final String name;
  final String category;
  final int current;
  final double threshold;

  LowStockItem({
    required this.name,
    required this.category,
    required this.current,
    required this.threshold,
  });
}

class TableData {
  final String tableName;
  final double total;

  TableData({required this.tableName, required this.total});
}
