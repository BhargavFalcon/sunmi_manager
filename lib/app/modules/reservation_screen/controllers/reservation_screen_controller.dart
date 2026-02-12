import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import '../../../constants/sizeConstant.dart';
import '../../../constants/translation_keys.dart';
import '../../../constants/api_constants.dart';
import '../../../model/MobileAppModulesModel.dart';
import '../../../model/tableModel.dart' as tableModel;
import '../../../model/reservation_list_model.dart';
import '../../../data/NetworkClient.dart';
import '../../../../main.dart';

class ReservationScreenController extends GetxController {
  // Text Editing Controllers
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController customerEmailController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();

  RxString selectedPerson = '1 Person'.obs;
  RxString selectedTimeSlot = ''.obs;
  RxString selectedReservationStatus = 'Pending'.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DateTime> selectedDateReservation = DateTime.now().obs;
  RxString selectedMonth = 'Today'.obs;
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  RxString selectedOrderFilter = 'All'.obs;
  final RxBool showAccessDialog = false.obs;
  // Validation
  RxBool isNameValid = false.obs;
  RxBool isPhoneValid = false.obs;
  RxString nameError = ''.obs;
  RxString phoneError = ''.obs;

  // Country Code Selection
  RxString selectedCountryCode = '+49'.obs;
  RxString selectedCountryFlag = '🇩🇪'.obs;

  // Table Selection
  final networkClient = NetworkClient();
  final RxList<tableModel.Data> tableAreasList = <tableModel.Data>[].obs;
  final Rx<tableModel.Tables?> selectedTable = Rx<tableModel.Tables?>(null);
  final RxBool isTableExpanded = false.obs;

  final RxBool isReservationsLoading = false.obs;
  final RxBool isReservationsLoadingMore = false.obs;
  final RxInt currentReservationsPage = 1.obs;
  final RxInt lastReservationsPage = 1.obs;
  static const int reservationsPerPage = 20;
  final ScrollController reservationsScrollController = ScrollController();

  bool get hasMoreReservations =>
      currentReservationsPage.value < lastReservationsPage.value;

  // Same date options as All Orders page
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
    'All',
    'Confirmed',
    'Checked In',
    'Cancelled',
    'No Show',
    'Pending',
  ];

  // Same 5 statuses as filter dropdown (for per-card status change)
  List<String> statusOptions = [
    'Confirmed',
    'Checked In',
    'Cancelled',
    'No Show',
    'Pending',
  ];

  List<String> personOptions = [
    '1 Person',
    '2 Persons',
    '3 Persons',
    '4 Persons',
    '5 Persons',
    '6 Persons',
    '7 Persons',
    '8 Persons',
    '9 Persons',
    '10 Persons',
  ];

  List<String> timeSlots = [
    '08:00 AM',
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
  ];

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
  }

  String getDisplayDate() {
    switch (selectedMonth.value) {
      case 'Today':
        return formatDate(DateTime.now());
      case 'Last 7 Days':
        return "${formatDate(DateTime.now().subtract(const Duration(days: 6)))} - ${formatDate(DateTime.now())}";
      case 'Custom Date':
        return "${formatDate(startDate.value)} - ${formatDate(endDate.value)}";
      case 'Current Week':
      case 'Last Week':
      case 'Current Month':
      case 'Last Month':
      case 'Current Year':
      case 'Last Year':
        return "${formatDate(startDate.value)} - ${formatDate(endDate.value)}";
      default:
        return formatDate(DateTime.now());
    }
  }

  /// Same as All Orders: raw key for menu, Custom Date shows range.
  String getDropdownDisplayText() {
    if (selectedMonth.value == 'Custom Date') {
      return "${formatDate(startDate.value)} - ${formatDate(endDate.value)}";
    }
    return selectedMonth.value;
  }

  void selectReservationStatus(String status) {
    selectedReservationStatus.value = status;
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy').format(selectedDate.value);

  String get formattedDateReservation =>
      DateFormat('EEE MMM dd yyyy').format(selectedDateReservation.value);

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

  RxList<Map<String, dynamic>> reservations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    customerNameController.addListener(() {
      validateName(customerNameController.text);
    });

    customerPhoneController.addListener(() {
      validatePhone(customerPhoneController.text);
    });
    _updateDatesByOption('Today');
    fetchTablesAreas();
    fetchReservations();
    reservationsScrollController.addListener(_onReservationsScroll);
  }

  void _onReservationsScroll() {
    if (isReservationsLoading.value || isReservationsLoadingMore.value) return;
    if (!hasMoreReservations) return;
    final pos = reservationsScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.8) {
      loadMoreReservations();
    }
  }

  @override
  void onReady() {
    super.onReady();
    _checkAndShowDialog();
  }

  void _checkAndShowDialog() {
    try {
      final modulesData = box.read(ArgumentConstant.mobileAppModulesKey);
      if (modulesData != null && modulesData is Map<String, dynamic>) {
        final modulesModel = MobileAppModulesModel.fromJson(modulesData);
        final modules = modulesModel.data?.modules ?? [];
        if (!modules.contains('Table Reservations')) {
          showAccessDialog.value = true;
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void updateOrderFilter(String value) {
    selectedOrderFilter.value = value;
    fetchReservations();
  }

  void updateDateOption(String option) {
    selectedMonth.value = option;
    if (option == 'Custom Date') {
      // Date picker will be opened from the view
    } else {
      _updateDatesByOption(option);
      fetchReservations();
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
        final start = now.subtract(const Duration(days: 6));
        _setDateRange(start, now);
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

  Future<void> showCustomDateRangePickerPop(BuildContext context) async {
    MySize().init(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? selectedStartDate =
        startDate.value.isBefore(today) ? today : startDate.value;
    DateTime? selectedEndDate =
        endDate.value.isBefore(today) ? today : endDate.value;
    final primaryColor = ColorConstants.primaryColor;
    final textStyle = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
      fontSize: MySize.getHeight(16),
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (dialogContext) => Dialog(
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
                              minDate: today,
                              maxDate: now.add(const Duration(days: 365 * 5)),
                              rangeSelectionColor: primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              startRangeSelectionColor: primaryColor,
                              endRangeSelectionColor: primaryColor,
                              selectionColor: primaryColor,
                              todayHighlightColor: primaryColor,
                              headerStyle: DateRangePickerHeaderStyle(
                                textStyle: textStyle.copyWith(
                                  fontSize: MySize.getHeight(16),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              monthCellStyle: DateRangePickerMonthCellStyle(
                                textStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: MySize.getHeight(14),
                                ),
                                todayTextStyle: textStyle.copyWith(
                                  color: primaryColor,
                                  fontSize: MySize.getHeight(14),
                                ),
                              ),
                              yearCellStyle: DateRangePickerYearCellStyle(
                                textStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: MySize.getHeight(14),
                                ),
                                todayTextStyle: textStyle.copyWith(
                                  color: primaryColor,
                                  fontSize: MySize.getHeight(14),
                                ),
                              ),
                              monthViewSettings:
                                  DateRangePickerMonthViewSettings(
                                    firstDayOfWeek: 1,
                                    dayFormat: 'EEE',
                                    showTrailingAndLeadingDates: true,
                                  ),
                              onSelectionChanged: (args) {
                                if (args.value is PickerDateRange) {
                                  final range = args.value as PickerDateRange;
                                  // Ensure dates are not in the past
                                  selectedStartDate =
                                      range.startDate != null &&
                                              range.startDate!.isBefore(today)
                                          ? today
                                          : range.startDate;
                                  selectedEndDate =
                                      range.endDate != null &&
                                              range.endDate!.isBefore(today)
                                          ? today
                                          : range.endDate;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                          onPressed: () => Navigator.of(dialogContext).pop(),
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
                              fontSize: MySize.getHeight(14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedStartDate != null &&
                                selectedEndDate != null) {
                              // Ensure dates are not in the past
                              final start =
                                  selectedStartDate!.isBefore(today)
                                      ? today
                                      : selectedStartDate!;
                              final end =
                                  selectedEndDate!.isBefore(today)
                                      ? today
                                      : selectedEndDate!;
                              startDate.value = start;
                              endDate.value = end;
                              selectedMonth.value = 'Custom Date';
                              Navigator.of(dialogContext).pop();
                              fetchReservations();
                            } else {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
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
                              fontSize: MySize.getHeight(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  void onClose() {
    reservationsScrollController.removeListener(_onReservationsScroll);
    reservationsScrollController.dispose();
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerEmailController.dispose();
    specialRequestController.dispose();
    super.onClose();
  }

  void selectPerson(String value) => selectedPerson.value = value;

  void selectTimeSlot(String timeSlot) {
    selectedTimeSlot.value = timeSlot;
  }

  /// -1 means no card is updating
  final RxInt statusUpdatingReservationIndex = (-1).obs;

  String _statusToApiValue(String status) {
    switch (status) {
      case 'No Show':
        return 'No_Show';
      case 'Checked In':
        return 'Checked_In';
      case 'Cancelled':
        return 'Cancelled';
      case 'Confirmed':
        return 'Confirmed';
      case 'Pending':
        return 'Pending';
      default:
        return status.replaceAll(' ', '_');
    }
  }

  Future<void> updateReservationStatus(int index, String newStatus) async {
    if (index < 0 || index >= reservations.length) return;
    final id = reservations[index]['id'];
    if (id == null) return;
    statusUpdatingReservationIndex.value = index;
    try {
      final apiStatus = _statusToApiValue(newStatus);
      final endpoint = ArgumentConstant.reservationStatusEndpoint.replaceAll(
        ':reservation_id',
        id.toString(),
      );
      final response = await networkClient.patch(
        endpoint,
        data: {'status': apiStatus},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        reservations[index]['status'] = newStatus;
        reservations.refresh();
      }
    } catch (e) {
      safeGetSnackbar(
        TranslationKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      statusUpdatingReservationIndex.value = -1;
    }
  }

  void assignTableToReservationAt(int index, tableModel.Tables table) {
    if (index < 0 || index >= reservations.length) return;
    reservations[index]['table'] = table.tableCode ?? '${table.id}';
    reservations.refresh();
  }

  // Validation Methods
  bool validateName(String name) {
    if (name.isEmpty) {
      nameError.value = TranslationKeys.customerNameRequired.tr;
      isNameValid.value = false;
      return false;
    } else if (name.length < 2) {
      nameError.value = TranslationKeys.nameMustBeAtLeast2Characters.tr;
      isNameValid.value = false;
      return false;
    } else {
      nameError.value = '';
      isNameValid.value = true;
      return true;
    }
  }

  bool validatePhone(String phone) {
    // Remove spaces and special characters for validation
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (phone.isEmpty) {
      phoneError.value = TranslationKeys.phoneNumberRequired.tr;
      isPhoneValid.value = false;
      return false;
    } else if (cleanPhone.length < 10) {
      phoneError.value = TranslationKeys.phoneNumberMustBeAtLeast10Digits.tr;
      isPhoneValid.value = false;
      return false;
    } else if (cleanPhone.length > 15) {
      phoneError.value = TranslationKeys.phoneNumberTooLong.tr;
      isPhoneValid.value = false;
      return false;
    } else {
      phoneError.value = '';
      isPhoneValid.value = true;
      return true;
    }
  }

  bool get isFormValid =>
      isNameValid.value &&
      isPhoneValid.value &&
      selectedTimeSlot.value.isNotEmpty;

  Future<void> fetchTablesAreas() async {
    tableAreasList.clear();
    try {
      final response = await networkClient.get(
        ArgumentConstant.tablesAreasEndpoint,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        final tableModelData = tableModel.TableModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (tableModelData.data != null) {
          tableAreasList.assignAll(tableModelData.data!);
        }
      }
    } catch (e) {}
  }

  String _statusToApiFilter(String filter) {
    switch (filter) {
      case 'No Show':
        return 'No_Show';
      case 'Checked In':
        return 'Checked_In';
      case 'Cancelled':
        return 'Cancelled';
      case 'Confirmed':
        return 'Confirmed';
      case 'Pending':
        return 'Pending';
      default:
        return filter.replaceAll(' ', '_');
    }
  }

  String _formatReservationTime(String? date, String? time) {
    if (date == null || date.isEmpty) return '';
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;
      final d = int.tryParse(parts[2]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 1;
      final y = int.tryParse(parts[0]) ?? 0;
      String timeStr = time ?? '00:00:00';
      final timeParts = timeStr.split(':');
      final hour = int.tryParse(timeParts.isNotEmpty ? timeParts[0] : '0') ?? 0;
      final minute =
          timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
      final dt = DateTime(y, m, d, hour, minute);
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (_) {
      return '$date ${time ?? ''}';
    }
  }

  List<Map<String, dynamic>> _mapReservationList(
    List<ReservationListItem> list,
  ) {
    return list.map((r) {
      final tableLabel =
          (r.table != null && r.table!.isNotEmpty)
              ? (r.table!.first.raw?['table_code'] ??
                  r.table!.first.raw?['name'] ??
                  '')
              : null;
      return <String, dynamic>{
        'id': r.id,
        'guests': r.partySize ?? 0,
        'note': r.specialRequests ?? '',
        'time': _formatReservationTime(r.reservationDate, r.reservationTime),
        'name': r.customer?.name ?? '',
        'phone': r.customer?.phone ?? '',
        'email': r.customer?.email ?? '',
        'status': r.statusLabel ?? r.reservationStatus ?? 'Pending',
        if (tableLabel != null && tableLabel.toString().isNotEmpty)
          'table': tableLabel.toString(),
      };
    }).toList();
  }

  Future<void> fetchReservations({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreReservations || isReservationsLoadingMore.value) return;
      isReservationsLoadingMore.value = true;
    } else {
      isReservationsLoading.value = true;
      currentReservationsPage.value = 1;
      lastReservationsPage.value = 1;
    }

    try {
      final page = loadMore ? currentReservationsPage.value + 1 : 1;
      final queryParams = <String, dynamic>{
        'date_from': _formatDateForApi(startDate.value),
        'date_to': _formatDateForApi(endDate.value),
        'per_page': reservationsPerPage,
        'page': page,
      };
      if (selectedOrderFilter.value != 'All') {
        queryParams['status'] = _statusToApiFilter(selectedOrderFilter.value);
      }
      final response = await networkClient.get(
        ArgumentConstant.reservationsEndpoint,
        queryParameters: queryParams,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        final model = ReservationListModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        final list = model.data?.reservations ?? [];
        final pagination = model.data?.pagination;
        if (pagination != null) {
          currentReservationsPage.value = pagination.currentPage ?? page;
          lastReservationsPage.value = pagination.lastPage ?? 1;
        }
        final mapped = _mapReservationList(list);
        if (loadMore) {
          reservations.addAll(mapped);
        } else {
          reservations.assignAll(mapped);
        }
      } else {
        if (!loadMore) reservations.clear();
      }
    } catch (e) {
      if (!loadMore) reservations.clear();
    } finally {
      if (loadMore) {
        isReservationsLoadingMore.value = false;
      } else {
        isReservationsLoading.value = false;
      }
    }
  }

  Future<void> loadMoreReservations() async {
    await fetchReservations(loadMore: true);
  }

  Future<void> onRefresh() async {
    currentReservationsPage.value = 1;
    await fetchReservations();
  }

  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void clearForm() {
    customerNameController.clear();
    customerPhoneController.clear();
    customerEmailController.clear();
    specialRequestController.clear();
    selectedCountryCode.value = '+49';
    selectedCountryFlag.value = '🇩🇪';
    selectedPerson.value = '1 Person';
    selectedTimeSlot.value = '';
    selectedDateReservation.value = DateTime.now();
    nameError.value = '';
    phoneError.value = '';
    isNameValid.value = false;
    isPhoneValid.value = false;
    selectedTable.value = null;
    isTableExpanded.value = false;
    selectedReservationStatus.value = 'Pending';
  }

  void saveReservation() {
    // Validate all fields
    bool nameValid = validateName(customerNameController.text);
    bool phoneValid = validatePhone(customerPhoneController.text);

    if (!nameValid || !phoneValid) {
      safeGetSnackbar(
        TranslationKeys.validationError.tr,
        TranslationKeys.pleaseFillAllRequiredFields.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (selectedTimeSlot.value.isEmpty) {
      safeGetSnackbar(
        TranslationKeys.timeSlotRequired.tr,
        TranslationKeys.pleaseSelectTimeSlot.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade700,
      );
      return;
    }

    // Create new reservation
    Map<String, dynamic> newReservation = {
      'guests': int.parse(selectedPerson.value.split(' ')[0]),
      'time':
          '${DateFormat('dd MMMM').format(selectedDateReservation.value)}, ${selectedTimeSlot.value}',
      'name': customerNameController.text.trim(),
      'phone':
          '${selectedCountryCode.value} ${customerPhoneController.text.trim()}',
      'email': customerEmailController.text.trim(),
      'status': selectedReservationStatus.value,
      'specialRequest': specialRequestController.text.trim(),
    };

    // Add to reservations list
    reservations.add(newReservation);

    // Show success message
    safeGetSnackbar(
      TranslationKeys.success.tr,
      TranslationKeys.reservationCreatedSuccessfully.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorConstants.successGreen.withOpacity(0.2),
      colorText: ColorConstants.successGreen,
    );

    // Clear form and close bottom sheet
    clearForm();
    Get.back();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFF723B13);
      case 'Confirmed':
        return const Color(0xFF03543F);
      case 'Cancelled':
        return const Color(0xFF9B1C1C);
      case 'Checked In':
        return const Color(0xFF1E429F);
      case 'No Show':
        return const Color(0xFF1F2937);
      default:
        return Colors.grey.shade300;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFDF6B2);
      case 'Confirmed':
        return const Color(0xFFDEF7EC);
      case 'Cancelled':
        return const Color(0xFFFDE8E8);
      case 'Checked In':
        return const Color(0xFFE1EFFE);
      case 'No Show':
        return const Color(0xFFF3F4F6);
      default:
        return Colors.grey.shade300;
    }
  }

  Color getStatusBorderColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFE3A008);
      case 'Confirmed':
        return const Color(0xFF31C48D);
      case 'Cancelled':
        return const Color(0xFFF98080);
      case 'Checked In':
        return const Color(0xFF76A9FA);
      case 'No Show':
        return const Color(0xFF9CA3AF);
      default:
        return Colors.grey.shade300;
    }
  }
}
