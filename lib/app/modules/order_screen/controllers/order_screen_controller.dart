import 'package:custom_date_range_picker/custom_date_range_picker.dart';
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
  RxString selectedMonth = 'Today'.obs;
  RxString selectedOrderFilter = 'Show All Orders'.obs;

  final List<String> dateOptions = [
    'Today',
    'Yesterday',
    'Last 7 Days',
    'Last 30 Days',
    'Custom Date',
  ];

  final List<String> orderFilterOptions = [
    'Show All Orders',
    'Completed',
    'Pending',
    'Cancelled',
  ];

  RxString selectedOrderType = 'Dine In'.obs;

  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with today's date
    _updateDatesByOption('Today');
  }

  void updateOrderFilter(String value) => selectedOrderFilter.value = value;

  void updateDateOption(String option) {
    selectedMonth.value = option;
    if (option == 'Custom Date') {
      // Date picker will be opened from the view
    } else {
      _updateDatesByOption(option);
    }
  }

  void _updateDatesByOption(String option) {
    final now = DateTime.now();

    switch (option) {
      case 'Today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate.value = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );
        endDate.value = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          23,
          59,
          59,
        );
        break;
      case 'Last 7 Days':
        startDate.value = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Last 30 Days':
        startDate.value = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 29));
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
    }
  }

  Future<void> showCustomDateRangePickerPop(BuildContext context) async {
    try {
      showCustomDateRangePicker(
        context,
        dismissible: true,
        startDate: startDate.value,
        endDate: endDate.value,
        minimumDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
        backgroundColor: Colors.white,
        primaryColor: ColorConstants.primaryColor,
        onApplyClick: (DateTime start, DateTime end) {
          startDate.value = start;
          endDate.value = end;
          selectedMonth.value = 'Custom Date';
        },
        onCancelClick: () {},
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select date range: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
  }

  String getDisplayDate() {
    switch (selectedMonth.value) {
      case 'Today':
        return formatDate(DateTime.now());
      case 'Yesterday':
        return formatDate(DateTime.now().subtract(const Duration(days: 1)));
      case 'Last 7 Days':
        return "${formatDate(DateTime.now().subtract(const Duration(days: 6)))} - ${formatDate(DateTime.now())}";
      case 'Last 30 Days':
        return "${formatDate(DateTime.now().subtract(const Duration(days: 29)))} - ${formatDate(DateTime.now())}";
      case 'Custom Date':
        return "${formatDate(startDate.value)} - ${formatDate(endDate.value)}";
      default:
        return formatDate(DateTime.now());
    }
  }

  String getDropdownDisplayText() {
    switch (selectedMonth.value) {
      case 'Custom Date':
        return "${formatDate(startDate.value)} - ${formatDate(endDate.value)}";
      default:
        return selectedMonth.value;
    }
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
