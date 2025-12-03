import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import '../../../constants/api_constants.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/AllOrdersModel.dart';

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

class OrderScreenController extends GetxController {
  final networkClient = NetworkClient();
  final RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  RxString selectedMonth = 'Today'.obs;
  RxString selectedOrderFilter = 'All Orders'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<Orders> allOrders = <Orders>[].obs;
  Pagination? pagination;
  int currentPage = 1;

  final List<String> dateOptions = [
    'Today',
    'Current Week',
    'Last Week',
    'Last 7 Days',
    'Current Month',
    'Last Month',
    'Current Year',
    'Last Year',
    'Custom Date',
  ];

  final List<String> orderFilterOptions = [
    'All Orders',
    'Kitchen',
    'Billed',
    'Paid',
    'Canceled',
    'Payment Due',
  ];

  RxString selectedOrderType = 'All Orders'.obs;

  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with today's date
    _updateDatesByOption('Today');
    fetchAllOrders();
  }

  /// Fetch all orders from API
  Future<void> fetchAllOrders({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      currentPage = 1;
      allOrders.clear();
    }

    // Format dates for API (YYYY-MM-DD format)
    final dateFrom =
        "${startDate.value.year}-${startDate.value.month.toString().padLeft(2, '0')}-${startDate.value.day.toString().padLeft(2, '0')}";
    final dateTo =
        "${endDate.value.year}-${endDate.value.month.toString().padLeft(2, '0')}-${endDate.value.day.toString().padLeft(2, '0')}";

    // Build query parameters
    final queryParams = <String, dynamic>{
      'page': currentPage,
      'date_from': dateFrom,
      'date_to': dateTo,
    };

    // Add order_type only if not "All Orders"
    if (selectedOrderType.value != 'All Orders') {
      String orderTypeValue = '';
      switch (selectedOrderType.value) {
        case 'Dine In':
          orderTypeValue = 'dine_in';
          break;
        case 'Pickup':
          orderTypeValue = 'pickup';
          break;
        case 'Delivery':
          orderTypeValue = 'delivery';
          break;
      }
      if (orderTypeValue.isNotEmpty) {
        queryParams['order_type'] = orderTypeValue;
      }
    }

    // Add status only if not "All Orders"
    if (selectedOrderFilter.value != 'All Orders') {
      String statusValue = '';
      switch (selectedOrderFilter.value) {
        case 'Kitchen':
          statusValue = 'kot';
          break;
        case 'Billed':
          statusValue = 'billed';
          break;
        case 'Paid':
          statusValue = 'paid';
          break;
        case 'Canceled':
          statusValue = 'canceled';
          break;
        case 'Payment Due':
          statusValue = 'payment_due';
          break;
      }
      if (statusValue.isNotEmpty) {
        queryParams['status'] = statusValue;
      }
    }

    final response = await networkClient.get(
      ArgumentConstant.allOrdersEndpoint,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final allOrdersModel = AllOrdersModel.fromJson(response.data);
      if (allOrdersModel.success == true && allOrdersModel.data != null) {
        if (isLoadMore) {
          allOrders.addAll(allOrdersModel.data!.orders ?? []);
        } else {
          allOrders.value = allOrdersModel.data!.orders ?? [];
        }
        pagination = allOrdersModel.data!.pagination;
      }
    }

    if (isLoadMore) {
      isLoadingMore.value = false;
      if (pagination != null && currentPage >= (pagination!.lastPage ?? 1)) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    } else {
      isLoading.value = false;
      refreshController.refreshCompleted();
    }
  }

  /// Handle pull to refresh
  Future<void> onRefresh() async {
    currentPage = 1;
    await fetchAllOrders();
  }

  /// Handle load more (pagination)
  Future<void> onLoading() async {
    if (pagination != null &&
        currentPage < (pagination!.lastPage ?? 1) &&
        !isLoadingMore.value) {
      currentPage++;
      await fetchAllOrders(isLoadMore: true);
    } else {
      refreshController.loadNoData();
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  /// Load more orders (next page)
  Future<void> loadMoreOrders() async {
    if (pagination != null &&
        currentPage < (pagination!.lastPage ?? 1) &&
        !isLoadingMore.value) {
      currentPage++;
      await fetchAllOrders(isLoadMore: true);
    }
  }

  /// Check if there are more pages to load
  bool get hasMorePages {
    if (pagination == null) return false;
    return currentPage < (pagination!.lastPage ?? 1);
  }

  void updateOrderFilter(String value) {
    selectedOrderFilter.value = value;
    currentPage = 1;
    fetchAllOrders();
  }

  void updateOrderType(String value) {
    selectedOrderType.value = value;
    currentPage = 1;
    fetchAllOrders();
  }

  void updateDateOption(String option) {
    selectedMonth.value = option;
    if (option == 'Custom Date') {
      // Date picker will be opened from the view
    } else {
      _updateDatesByOption(option);
      fetchAllOrders();
    }
  }

  void _updateDatesByOption(String option) {
    final now = DateTime.now();

    switch (option) {
      case 'Today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Current Week':
        // Get Monday of current week
        final daysFromMonday = now.weekday - 1;
        final monday = now.subtract(Duration(days: daysFromMonday));
        startDate.value = DateTime(monday.year, monday.month, monday.day);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Last Week':
        // Get Monday of last week
        final daysFromMonday = now.weekday - 1;
        final lastWeekMonday = now.subtract(Duration(days: daysFromMonday + 7));
        final lastWeekSunday = lastWeekMonday.add(const Duration(days: 6));
        startDate.value = DateTime(
          lastWeekMonday.year,
          lastWeekMonday.month,
          lastWeekMonday.day,
        );
        endDate.value = DateTime(
          lastWeekSunday.year,
          lastWeekSunday.month,
          lastWeekSunday.day,
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
      case 'Current Month':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        startDate.value = DateTime(lastMonth.year, lastMonth.month, 1);
        endDate.value = DateTime(
          lastDayOfLastMonth.year,
          lastDayOfLastMonth.month,
          lastDayOfLastMonth.day,
          23,
          59,
          59,
        );
        break;
      case 'Current Year':
        startDate.value = DateTime(now.year, 1, 1);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Last Year':
        startDate.value = DateTime(now.year - 1, 1, 1);
        endDate.value = DateTime(now.year - 1, 12, 31, 23, 59, 59);
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
          fetchAllOrders();
        },
        onCancelClick: () {},
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select date range: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
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
      case 'Current Week':
        final now = DateTime.now();
        final daysFromMonday = now.weekday - 1;
        final monday = now.subtract(Duration(days: daysFromMonday));
        return "${formatDate(monday)} - ${formatDate(now)}";
      case 'Last Week':
        final now = DateTime.now();
        final daysFromMonday = now.weekday - 1;
        final lastWeekMonday = now.subtract(Duration(days: daysFromMonday + 7));
        final lastWeekSunday = lastWeekMonday.add(const Duration(days: 6));
        return "${formatDate(lastWeekMonday)} - ${formatDate(lastWeekSunday)}";
      case 'Last 7 Days':
        return "${formatDate(DateTime.now().subtract(const Duration(days: 6)))} - ${formatDate(DateTime.now())}";
      case 'Current Month':
        final now = DateTime.now();
        return "${formatDate(DateTime(now.year, now.month, 1))} - ${formatDate(now)}";
      case 'Last Month':
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        return "${formatDate(lastMonth)} - ${formatDate(lastDayOfLastMonth)}";
      case 'Current Year':
        final now = DateTime.now();
        return "${formatDate(DateTime(now.year, 1, 1))} - ${formatDate(now)}";
      case 'Last Year':
        final now = DateTime.now();
        return "${formatDate(DateTime(now.year - 1, 1, 1))} - ${formatDate(DateTime(now.year - 1, 12, 31))}";
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

  List<Order> orders = [
    Order(
      id: "356",
      customerName: "Luke Cage",
      datetime: "June 21, 2025 | 10:21 AM",
      total: "201.81",
      statusText: "Order Preparing",
      statusColor: Colors.purple,
      tag: "PREPARING",
      tagColor: Colors.purple,
    ),
    Order(
      id: "355",
      customerName: "Jessica Jones",
      datetime: "June 20, 2025 | 02:53 AM",
      total: "153.64",
      statusText: "Order Placed",
      statusColor: Colors.orange,
      tag: "PAYMENT VERIFICATION",
      tagColor: Colors.orange,
    ),
    Order(
      id: "354",
      customerName: "Trish Walker",
      datetime: "June 20, 2025 | 07:16 PM",
      total: "106.53",
      statusText: "Order Placed",
      statusColor: Colors.orange,
      tag: "PAID",
      tagColor: Colors.green,
    ),
    Order(
      id: "353",
      customerName: "Turk Barrett",
      datetime: "June 19, 2025 | 10:14 PM",
      total: "13.87",
      statusText: "Order Served",
      statusColor: Colors.green,
      tag: "PAID",
      tagColor: Colors.green,
    ),
    Order(
      id: "352",
      customerName: "Malcolm Ducasse",
      datetime: "June 18, 2025 | 05:48 PM",
      total: "39.46",
      statusText: "Delivered",
      statusColor: Colors.blue,
      tag: "OUT FOR DELIVERY",
      tagColor: Colors.blue,
    ),
    Order(
      id: "351",
      customerName: "Claire Temple",
      datetime: "June 20, 2025 | 09:06 PM",
      total: "369.76",
      statusText: "Delivered",
      statusColor: Colors.green,
      tag: "PAID",
      tagColor: Colors.green,
    ),
    Order(
      id: "350",
      customerName: "Marci Stahl",
      datetime: "June 18, 2025 | 10:06 PM",
      total: "166.56",
      statusText: "Delivered",
      statusColor: Colors.green,
      tag: "PAID",
      tagColor: Colors.green,
    ),
  ];
}
