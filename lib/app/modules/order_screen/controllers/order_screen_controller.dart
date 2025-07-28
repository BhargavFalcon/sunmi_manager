import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';

class OrderModel {
  final String id;
  final String name;
  final String type;
  final String statusText;
  final String datetime;
  final String kot;
  final String note;
  final double total;
  final Color statusColor;
  final String tag;
  final Color tagColor;

  OrderModel({
    required this.id,
    required this.name,
    required this.type,
    required this.statusText,
    required this.datetime,
    required this.kot,
    required this.note,
    required this.total,
    required this.statusColor,
    required this.tag,
    required this.tagColor,
  });
}

class OrderScreenController extends GetxController {
  RxString selectedMonth = 'Current Month'.obs;
  RxString selectedOrderFilter = 'Show All Orders'.obs;

  final List<String> monthOptions = [
    'Current Month',
    'Last Month',
    'Custom Range',
  ];

  final List<String> orderFilterOptions = [
    'Show All Orders',
    'Completed',
    'Pending',
    'Cancelled',
  ];

  Rx<DateTime> startDate = DateTime(2025, 6, 1).obs;
  Rx<DateTime> endDate = DateTime(2025, 6, 30).obs;

  void updateMonth(String value) => selectedMonth.value = value;
  void updateOrderFilter(String value) => selectedOrderFilter.value = value;

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorConstants.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) startDate.value = picked;
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorConstants.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) endDate.value = picked;
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${_monthName(date.month)}-${date.year}";
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  List<OrderModel> orders = [
    OrderModel(
      id: "356",
      name: "Luke Cage",
      type: "Dine In",
      datetime: "June 21, 2025 | 10:21 AM",
      kot: "397",
      note: "None",
      total: 201.81,
      statusText: "Order Preparing",
      statusColor: Colors.purple,
      tag: "PREPARING",
      tagColor: Colors.purple,
    ),
    OrderModel(
      id: "355",
      name: "Jessica Jones",
      type: "Takeaway",
      datetime: "June 20, 2025 | 02:53 AM",
      kot: "376",
      note: "None",
      total: 153.64,
      statusText: "Order Placed",
      statusColor: Colors.orange,
      tag: "PAYMENT VERIFICATION",
      tagColor: Colors.orange,
    ),
    OrderModel(
      id: "354",
      name: "Trish Walker",
      type: "Delivery",
      datetime: "June 20, 2025 | 07:16 PM",
      kot: "390",
      note: "None",
      total: 106.53,
      statusText: "Order Placed",
      statusColor: Colors.orange,
      tag: "PAID",
      tagColor: Colors.green,
    ),
    OrderModel(
      id: "353",
      name: "Turk Barrett",
      type: "Dine In",
      datetime: "June 19, 2025 | 10:14 PM",
      kot: "394",
      note: "None",
      total: 13.87,
      statusText: "Order Served",
      statusColor: Colors.green,
      tag: "PAID",
      tagColor: Colors.green,
    ),
    OrderModel(
      id: "352",
      name: "Malcolm Ducasse",
      type: "Delivery",
      datetime: "June 18, 2025 | 05:48 PM",
      kot: "395",
      note: "None",
      total: 39.46,
      statusText: "Delivered",
      statusColor: Colors.blue,
      tag: "OUT FOR DELIVERY",
      tagColor: Colors.blue,
    ),
    OrderModel(
      id: "351",
      name: "Claire Temple",
      type: "Dine In",
      datetime: "June 20, 2025 | 09:06 PM",
      kot: "392",
      note: "None",
      total: 369.76,
      statusText: "Delivered",
      statusColor: Colors.green,
      tag: "PAID",
      tagColor: Colors.green,
    ),
    OrderModel(
      id: "350",
      name: "Marci Stahl",
      type: "Takeaway",
      datetime: "June 18, 2025 | 10:06 PM",
      kot: "391",
      note: "None",
      total: 166.56,
      statusText: "Delivered",
      statusColor: Colors.green,
      tag: "PAID",
      tagColor: Colors.green,
    ),
  ];
}
