import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/AllOrdersModel.dart';
import '../../../model/getorderModel.dart' as orderModel;

class OrderScreenController extends GetxController {
  final networkClient = NetworkClient();

  RxString selectedMonth = 'Today'.obs;
  RxString selectedOrderFilter = 'All Orders'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isNavigatingToOrder = false.obs;
  final RxBool isLoadingOrderDetails = false.obs;
  final Rx<orderModel.GetOrderModel?> orderDetails =
      Rx<orderModel.GetOrderModel?>(null);
  final RxList<Orders> allOrders = <Orders>[].obs;
  Pagination? pagination;
  int currentPage = 1;
  final ScrollController scrollController = ScrollController();

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
    _updateDatesByOption('Today');
    scrollController.addListener(_onScroll);
  }

  @override
  void onReady() {
    super.onReady();
    fetchAllOrders();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    if (currentScroll >= maxScroll - 200) {
      if (!isLoadingMore.value && !isLoading.value) {
        if (pagination == null) {
          currentPage++;
          fetchAllOrders(isLoadMore: true);
        } else {
          final lastPage = pagination!.lastPage ?? 1;
          if (currentPage < lastPage) {
            currentPage++;
            fetchAllOrders(isLoadMore: true);
          }
        }
      }
    }
  }

  Future<void> fetchAllOrders({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      currentPage = 1;
      allOrders.clear();
    }

    final dateFrom =
        "${startDate.value.year}-${startDate.value.month.toString().padLeft(2, '0')}-${startDate.value.day.toString().padLeft(2, '0')}";
    final dateTo =
        "${endDate.value.year}-${endDate.value.month.toString().padLeft(2, '0')}-${endDate.value.day.toString().padLeft(2, '0')}";

    final queryParams = <String, dynamic>{
      'page': currentPage,
      'date_from': dateFrom,
      'date_to': dateTo,
    };

    const orderTypeMap = {
      'Dine In': 'dine_in',
      'Pickup': 'pickup',
      'Delivery': 'delivery',
    };
    const statusMap = {
      'Kitchen': 'kot',
      'Billed': 'billed',
      'Paid': 'paid',
      'Canceled': 'canceled',
      'Payment Due': 'payment_due',
    };

    if (selectedOrderType.value != 'All Orders' &&
        orderTypeMap.containsKey(selectedOrderType.value)) {
      queryParams['order_type'] = orderTypeMap[selectedOrderType.value];
    }

    if (selectedOrderFilter.value != 'All Orders' &&
        statusMap.containsKey(selectedOrderFilter.value)) {
      queryParams['status'] = statusMap[selectedOrderFilter.value];
    }

    final response = await networkClient.get(
      ArgumentConstant.allOrdersEndpoint,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final allOrdersModel = AllOrdersModel.fromJson(response.data);
      if (allOrdersModel.success == true && allOrdersModel.data != null) {
        final ordersList = allOrdersModel.data!.orders ?? [];
        if (isLoadMore) {
          allOrders.addAll(ordersList);
        } else {
          allOrders.value = ordersList;
        }
        pagination = allOrdersModel.data!.pagination;
      }
    }

    if (isLoadMore) {
      isLoadingMore.value = false;
    } else {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    currentPage = 1;
    await fetchAllOrders();
  }

  Future<void> fetchOrderDetails(String orderUuid) async {
    isLoadingOrderDetails.value = true;
    orderDetails.value = null;
    final response = await networkClient.get(
      ArgumentConstant.getOrderEndpoint.replaceAll(':order_uuid', orderUuid),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final orderDetailsModel = orderModel.GetOrderModel.fromJson(
        response.data,
      );
      if (orderDetailsModel.success == true) {
        orderDetails.value = orderDetailsModel;
      }
    }
    isLoadingOrderDetails.value = false;
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    if (scrollController.hasClients) {
      scrollController.dispose();
    }
    super.onClose();
  }

  Future<void> loadMoreOrders() async {
    if (pagination != null &&
        currentPage < (pagination!.lastPage ?? 1) &&
        !isLoadingMore.value) {
      currentPage++;
      await fetchAllOrders(isLoadMore: true);
    }
  }

  bool get hasMorePages =>
      pagination != null && currentPage < (pagination!.lastPage ?? 1);

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
    if (option != 'Custom Date') {
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
        final daysFromMonday = now.weekday - 1;
        final monday = now.subtract(Duration(days: daysFromMonday));
        startDate.value = DateTime(monday.year, monday.month, monday.day);
        endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Last Week':
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
}
