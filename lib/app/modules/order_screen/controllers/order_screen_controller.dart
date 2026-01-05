import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/AllOrdersModel.dart';
import '../../../model/getorderModel.dart' as orderModel;
import '../../../model/MobileAppModulesModel.dart';
import '../../../../main.dart';

class OrderScreenController extends GetxController {
  final networkClient = NetworkClient();

  RxString selectedMonth = 'Today'.obs;
  RxString selectedOrderFilter = 'All Orders'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isNavigatingToOrder = false.obs;
  final RxBool isLoadingOrderDetails = false.obs;
  final RxBool showAccessDialog = false.obs;
  final Rx<orderModel.GetOrderModel?> orderDetails =
      Rx<orderModel.GetOrderModel?>(null);
  final RxList<Orders> allOrders = <Orders>[].obs;
  Pagination? pagination;
  int currentPage = 1;
  final ScrollController scrollController = ScrollController();
  VoidCallback? _scrollListener;

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
  }

  @override
  void onReady() {
    super.onReady();
    _setupScrollListener();
    fetchAllOrders();
    _checkAndShowDialog();
  }

  void _setupScrollListener() {
    _scrollListener = () {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        if (hasMorePages && !isLoadingMore.value && !isLoading.value) {
          loadMoreOrders();
        }
      }
    };
    scrollController.addListener(_scrollListener!);
  }

  void _checkAndShowDialog() {
    try {
      final modulesData = box.read(ArgumentConstant.mobileAppModulesKey);
      if (modulesData != null && modulesData is Map<String, dynamic>) {
        final modulesModel = MobileAppModulesModel.fromJson(modulesData);
        final modules = modulesModel.data?.modules ?? [];
        if (!modules.contains('All Orders')) {
          Future.delayed(const Duration(milliseconds: 100), () {
            showAccessDialog.value = true;
          });
        }
      }
    } catch (e) {
      // Handle error silently
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

    final dateFrom = _formatDateForApi(startDate.value);
    final dateTo = _formatDateForApi(endDate.value);

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
    if (_scrollListener != null && scrollController.hasClients) {
      scrollController.removeListener(_scrollListener!);
    }
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
        _setDateRange(now, now);
        break;
      case 'Current Week':
        final monday = _getMonday(now);
        final sunday = monday.add(const Duration(days: 6));
        _setDateRange(monday, sunday);
        break;
      case 'Last Week':
        final lastWeekMonday = _getMonday(
          now,
        ).subtract(const Duration(days: 7));
        final lastWeekSunday = lastWeekMonday.add(const Duration(days: 6));
        _setDateRange(lastWeekMonday, lastWeekSunday);
        break;
      case 'Last 7 Days':
        final startDate = now.subtract(const Duration(days: 6));
        _setDateRange(startDate, now);
        break;
      case 'Current Month':
        final monthStart = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        _setDateRange(monthStart, lastDayOfMonth);
        break;
      case 'Last Month':
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0);
        _setDateRange(lastMonthStart, lastMonthEnd);
        break;
      case 'Current Year':
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year, 12, 31);
        _setDateRange(yearStart, yearEnd);
        break;
      case 'Last Year':
        final lastYearStart = DateTime(now.year - 1, 1, 1);
        final lastYearEnd = DateTime(now.year - 1, 12, 31);
        _setDateRange(lastYearStart, lastYearEnd);
        break;
    }
  }

  DateTime _getMonday(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  void _setDateRange(DateTime start, DateTime end) {
    startDate.value = DateTime(start.year, start.month, start.day);
    endDate.value = DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> showCustomDateRangePickerPop(BuildContext context) async {
    DateTime? selectedStartDate = startDate.value;
    DateTime? selectedEndDate = endDate.value;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Picker
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Theme(
                      data: ThemeData(
                        colorScheme: ColorScheme.light(
                          primary: Colors.black87,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        iconTheme: IconThemeData(color: Colors.black87),
                      ),
                      child: SizedBox(
                        height: 300,
                        child: Localizations.override(
                          context: context,
                          locale: Get.locale ?? const Locale('en'),
                          child: SfDateRangePicker(
                            backgroundColor: Colors.white,
                            view: DateRangePickerView.month,
                            selectionMode: DateRangePickerSelectionMode.range,
                            initialSelectedRange:
                                selectedStartDate != null &&
                                        selectedEndDate != null
                                    ? PickerDateRange(
                                      selectedStartDate,
                                      selectedEndDate,
                                    )
                                    : null,
                            minDate: DateTime.now().subtract(
                              const Duration(days: 365 * 5),
                            ),
                            maxDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                            rangeSelectionColor: ColorConstants.primaryColor
                                .withValues(alpha: 0.3),
                            startRangeSelectionColor:
                                ColorConstants.primaryColor,
                            endRangeSelectionColor: ColorConstants.primaryColor,
                            selectionColor: ColorConstants.primaryColor,
                            todayHighlightColor: ColorConstants.primaryColor,
                            headerStyle: DateRangePickerHeaderStyle(
                              textStyle: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              backgroundColor: Colors.white,
                            ),
                            monthCellStyle: DateRangePickerMonthCellStyle(
                              textStyle: TextStyle(color: Colors.black87),
                              todayTextStyle: TextStyle(
                                color: ColorConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            yearCellStyle: DateRangePickerYearCellStyle(
                              textStyle: TextStyle(color: Colors.black87),
                              todayTextStyle: TextStyle(
                                color: ColorConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            monthViewSettings: DateRangePickerMonthViewSettings(
                              firstDayOfWeek: 1,
                              dayFormat: 'EEE',
                              showTrailingAndLeadingDates: true,
                            ),
                            onSelectionChanged: (
                              DateRangePickerSelectionChangedArgs args,
                            ) {
                              if (args.value is PickerDateRange) {
                                final range = args.value as PickerDateRange;
                                selectedStartDate = range.startDate;
                                selectedEndDate = range.endDate;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          TranslationKeys.cancel.tr,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedStartDate != null &&
                              selectedEndDate != null) {
                            startDate.value = selectedStartDate!;
                            endDate.value = selectedEndDate!;
                            selectedMonth.value = 'Custom Date';
                            Navigator.of(dialogContext).pop();
                            fetchAllOrders();
                          } else {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          TranslationKeys.apply.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
  }

  String getDisplayDate() {
    final now = DateTime.now();

    switch (selectedMonth.value) {
      case 'Today':
        return formatDate(now);
      case 'Current Week':
        final monday = _getMonday(now);
        final sunday = monday.add(const Duration(days: 6));
        return "${formatDate(monday)} - ${formatDate(sunday)}";
      case 'Last Week':
        final lastWeekMonday = _getMonday(
          now,
        ).subtract(const Duration(days: 7));
        final lastWeekSunday = lastWeekMonday.add(const Duration(days: 6));
        return "${formatDate(lastWeekMonday)} - ${formatDate(lastWeekSunday)}";
      case 'Last 7 Days':
        final startDate = now.subtract(const Duration(days: 6));
        return "${formatDate(startDate)} - ${formatDate(now)}";
      case 'Current Month':
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        return "${formatDate(DateTime(now.year, now.month, 1))} - ${formatDate(lastDayOfMonth)}";
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        return "${formatDate(lastMonth)} - ${formatDate(lastDayOfLastMonth)}";
      case 'Current Year':
        return "${formatDate(DateTime(now.year, 1, 1))} - ${formatDate(now)}";
      case 'Last Year':
        return "${formatDate(DateTime(now.year - 1, 1, 1))} - ${formatDate(DateTime(now.year - 1, 12, 31))}";
      case 'Custom Date':
        return "${formatDate(startDate.value)} - ${formatDate(endDate.value)}";
      default:
        return formatDate(now);
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
