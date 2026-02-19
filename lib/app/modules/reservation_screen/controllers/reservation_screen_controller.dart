import 'dart:async';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import '../../../constants/sizeConstant.dart';
import '../../../widgets/app_toast.dart';
import '../../../constants/translation_keys.dart';
import '../../../constants/api_constants.dart';
import '../../../model/MobileAppModulesModel.dart';
import '../../../model/tableModel.dart' as tableModel;
import '../../../model/reservation_list_model.dart';
import '../../../model/available_time_slots_model.dart';
import '../../../model/LoginModels.dart';
import '../../../model/customer_list_model.dart';
import '../../../data/NetworkClient.dart';
import '../../../../main.dart';

class ReservationScreenController extends GetxController {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController customerEmailController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();

  RxString selectedPerson = '1 Person'.obs;
  RxString selectedTimeSlot = ''.obs;
  RxString selectedTimeSlotTitle = ''.obs;
  RxString selectedReservationStatus = 'Pending'.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DateTime> selectedDateReservation = DateTime.now().obs;
  RxString selectedMonth = 'Today'.obs;
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  RxString selectedOrderFilter = 'All'.obs;
  final RxBool showAccessDialog = false.obs;
  RxBool isNameValid = false.obs;
  RxBool isPhoneValid = false.obs;
  RxString nameError = ''.obs;
  RxString phoneError = ''.obs;

  RxString selectedCountryCode = '+49'.obs;
  RxString selectedCountryFlag = '🇩🇪'.obs;

  final networkClient = NetworkClient();
  final RxList<tableModel.Data> tableAreasList = <tableModel.Data>[].obs;
  final Rx<tableModel.Tables?> selectedTable = Rx<tableModel.Tables?>(null);
  final RxBool isTableExpanded = false.obs;

  final FocusNode reservationNameFocusNode = FocusNode();
  final FocusNode reservationPhoneFocusNode = FocusNode();
  final GlobalKey reservationNameFieldKey = GlobalKey();
  final GlobalKey reservationPhoneFieldKey = GlobalKey();
  VoidCallback? onReservationPhoneFocusGained;
  VoidCallback? onReservationNameFocusGained;

  final RxList<CustomerListItem> customerSearchResults = <CustomerListItem>[].obs;
  final RxBool isCustomerSearching = false.obs;
  final Rx<CustomerListItem?> selectedReservationCustomer = Rx<CustomerListItem?>(null);
  Timer? _customerSearchDebounce;
  VoidCallback? onCustomerSearchResultsChanged;
  bool _isPrefillingFromCustomerSelection = false;

  bool get isReservationCustomerSelected => selectedReservationCustomer.value != null;

  final RxBool isSavingReservation = false.obs;

  final RxBool isReservationsLoading = false.obs;
  final RxBool isReservationsLoadingMore = false.obs;
  final RxInt currentReservationsPage = 1.obs;
  final RxInt lastReservationsPage = 1.obs;
  static const int reservationsPerPage = 20;
  final ScrollController reservationsScrollController = ScrollController();

  bool get hasMoreReservations =>
      currentReservationsPage.value < lastReservationsPage.value;

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

  final RxList<TimeSlotSection> timeSlotSections = <TimeSlotSection>[].obs;
  final RxBool isTimeSlotsLoading = false.obs;
  final RxBool isTimeSlotsClosed = false.obs;
  final RxBool isCheckingAvailability = false.obs;
  final RxString checkingSlotSectionTitle = ''.obs;
  final RxString checkingSlotValue = ''.obs;

  final RxInt editingReservationIndex = (-1).obs;

  bool get isEditingReservation => editingReservationIndex.value >= 0;

  List<String> get reservationFormStatusOptions {
    if (!isEditingReservation || editingReservationIndex.value >= reservations.length) {
      return ['Pending', 'Confirmed'];
    }
    final current = reservations[editingReservationIndex.value]['status'] as String?;
    if (current == null || current == 'Pending' || current == 'Confirmed') {
      return ['Pending', 'Confirmed'];
    }
    return ['Pending', 'Confirmed', current];
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
  }

  String getDisplayDate() {
    switch (selectedMonth.value) {
      case 'Today':
        return formatDate(DateTime.now());
      case 'Last 7 Days':
        final now = DateTime.now();
        return '${formatDate(now.subtract(const Duration(days: 6)))} - ${formatDate(now)}';
      case 'Custom Date':
      case 'Current Week':
      case 'Last Week':
      case 'Current Month':
      case 'Last Month':
      case 'Current Year':
      case 'Last Year':
        return '${formatDate(startDate.value)} - ${formatDate(endDate.value)}';
      default:
        return formatDate(DateTime.now());
    }
  }

  String getDropdownDisplayText() {
    if (selectedMonth.value == 'Custom Date') {
      return "${formatDate(startDate.value)} - ${formatDate(endDate.value)}";
    }
    return selectedMonth.value;
  }

  void selectReservationStatus(String status) {
    selectedReservationStatus.value = status;
  }

  Future<void> fetchAvailableTimeSlots() async {
    isTimeSlotsLoading.value = true;
    isTimeSlotsClosed.value = false;
    timeSlotSections.clear();
    if (editingReservationIndex.value < 0) {
      selectedTimeSlot.value = '';
      selectedTimeSlotTitle.value = '';
    }
    try {
      final branchId = _getBranchIdFromStorage();
      if (branchId == null) return;

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDateReservation.value);
      final response = await networkClient.get(
        ArgumentConstant.reservationsAvailableTimeSlotsEndpoint,
        queryParameters: <String, dynamic>{'date': dateStr, 'branch_id': branchId},
      );

      if (!_isSuccessResponse(response)) return;

      final model = AvailableTimeSlotsModel.fromJson(response.data as Map<String, dynamic>);
      final data = model.data;
      if (model.success != true || data == null) return;

      isTimeSlotsClosed.value = data.isClosed ?? false;
      final rawSlots = data.timeSlots;
      if (rawSlots == null || rawSlots.isEmpty) return;

      final sections = <TimeSlotSection>[];
      for (final entry in rawSlots.entries) {
        final displaySlots = entry.value.map(_timeSlotToDisplay).toList();
        displaySlots.sort(_compareTimeSlotDisplay);
        sections.add(TimeSlotSection(title: entry.key, slots: displaySlots));
      }
      timeSlotSections.assignAll(sections);
      if (editingReservationIndex.value >= 0) _ensureEditingSlotInSections();
    } catch (_) {
      timeSlotSections.clear();
    } finally {
      isTimeSlotsLoading.value = false;
    }
  }

  void _ensureEditingSlotInSections() {
    if (editingReservationIndex.value < 0 ||
        editingReservationIndex.value >= reservations.length) return;
    final title = selectedTimeSlotTitle.value;
    final display = selectedTimeSlot.value;
    if (title.isEmpty && display.isEmpty) return;
    final existing = timeSlotSections.where((s) => s.title == title).toList();
    if (existing.isNotEmpty && existing.first.slots.contains(display)) return;
    if (existing.isNotEmpty) {
      final updated = existing.first.slots.toList()..add(display);
      updated.sort(_compareTimeSlotDisplay);
      timeSlotSections.remove(existing.first);
      timeSlotSections.add(TimeSlotSection(title: title, slots: updated));
    } else {
      timeSlotSections.add(TimeSlotSection(title: title, slots: [display]));
    }
  }

  void prefillForEdit(int index) {
    if (index < 0 || index >= reservations.length) return;
    editingReservationIndex.value = index;
    final item = reservations[index];
    final dateStr = item['reservationDate'] as String?;
    if (dateStr != null && dateStr.isNotEmpty) {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) selectedDateReservation.value = parsed;
    }
    final timeStr = item['reservationTime'] as String?;
    if (timeStr != null && timeStr.isNotEmpty) {
      selectedTimeSlot.value = _timeSlotToDisplay(timeStr);
      selectedTimeSlotTitle.value = (item['reservationSlotType'] as String?) ?? '';
    }
    final guests = (item['guests'] as int?) ?? 1;
    selectedPerson.value = guests == 1 ? '1 Person' : '$guests Persons';
    selectedReservationStatus.value = (item['status'] as String?) ?? 'Pending';
    specialRequestController.text = (item['note'] as String?) ?? '';
    customerNameController.text = (item['name'] as String?) ?? '';
    customerPhoneController.text = (item['phone'] as String?) ?? '';
    customerEmailController.text = (item['email'] as String?) ?? '';
    selectedReservationCustomer.value = null;
    nameError.value = '';
    phoneError.value = '';
    isNameValid.value = true;
    isPhoneValid.value = true;
    selectedTable.value = null;
  }

  int? _getBranchIdFromStorage() {
    try {
      final loginData = box.read(ArgumentConstant.loginModelKey);
      if (loginData is! Map<String, dynamic>) return null;
      final loginModel = LoginModel.fromJson(loginData);
      return loginModel.data?.defaultBranchId ?? loginModel.data?.user?.branchId;
    } catch (_) {
      return null;
    }
  }

  static bool _isSuccessResponse(dynamic response) {
    final code = response.statusCode;
    return (code == 200 || code == 201) && response.data is Map<String, dynamic>;
  }

  static int? _displayTimeToMinutes(String display) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(display.trim());
    if (match == null) return null;
    var h = int.tryParse(match.group(1) ?? '0') ?? 0;
    final m = int.tryParse(match.group(2) ?? '0') ?? 0;
    final amPm = (match.group(3) ?? '').toUpperCase();
    if (amPm == 'PM' && h != 12) h += 12;
    if (amPm == 'AM' && h == 12) h = 0;
    return h * 60 + m;
  }

  static String _displayTimeToApiTime(String display) {
    final minutes = _displayTimeToMinutes(display);
    if (minutes == null) return '12:00:00';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00';
  }

  static String _timeSlotToDisplay(String apiTime) {
    final parts = apiTime.split(':');
    if (parts.length < 2) return apiTime;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final isPm = h >= 12;
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
  }

  static int _compareTimeSlotDisplay(String a, String b) =>
      (_displayTimeToMinutes(a) ?? 0).compareTo(_displayTimeToMinutes(b) ?? 0);

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
      _onCustomerNameChangedForSearch();
    });

    customerPhoneController.addListener(() {
      validatePhone(customerPhoneController.text);
      _onCustomerPhoneOrEmailChanged();
    });
    customerEmailController.addListener(_onCustomerPhoneOrEmailChanged);
    reservationNameFocusNode.addListener(_onReservationNameFocusChange);
    reservationPhoneFocusNode.addListener(_onReservationPhoneFocusChange);
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

  void _onReservationNameFocusChange() {
    if (reservationNameFocusNode.hasFocus) {
      onReservationNameFocusGained?.call();
    }
  }

  void _onReservationPhoneFocusChange() {
    if (reservationPhoneFocusNode.hasFocus) {
      onReservationPhoneFocusGained?.call();
    }
  }

  void _onCustomerPhoneOrEmailChanged() {
    if (_isPrefillingFromCustomerSelection) return;
    if (isReservationCustomerSelected) {
      selectedReservationCustomer.value = null;
      customerSearchResults.clear();
    }
  }

  void _onCustomerNameChangedForSearch() {
    if (_isPrefillingFromCustomerSelection) return;
    if (isReservationCustomerSelected) {
      selectedReservationCustomer.value = null;
    }
    final query = customerNameController.text.trim();
    if (query.length < 2) {
      _customerSearchDebounce?.cancel();
      customerSearchResults.clear();
      onCustomerSearchResultsChanged?.call();
      return;
    }
    _customerSearchDebounce?.cancel();
    _customerSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      fetchReservationCustomerSearch(query);
    });
  }

  Future<void> fetchReservationCustomerSearch(String query) async {
    if (query.trim().length < 2) return;
    isCustomerSearching.value = true;
    customerSearchResults.clear();
    onCustomerSearchResultsChanged?.call();
    try {
      final response = await networkClient.get(
        ArgumentConstant.customersEndpoint,
        queryParameters: {'search': query.trim(), 'page': 1, 'per_page': 20},
      );
      if (!_isSuccessResponse(response)) return;
      final model = CustomerListModel.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {},
      );
      if (model.data?.data != null) {
        customerSearchResults.assignAll(model.data!.data!);
      }
      onCustomerSearchResultsChanged?.call();
    } catch (_) {
      customerSearchResults.clear();
      onCustomerSearchResultsChanged?.call();
    } finally {
      isCustomerSearching.value = false;
    }
  }

  void selectReservationCustomer(CustomerListItem customer) {
    _isPrefillingFromCustomerSelection = true;
    selectedReservationCustomer.value = customer;
    customerNameController.text = customer.name ?? '';
    customerEmailController.text = customer.email ?? '';
    final phoneCode = (customer.phoneCode ?? '').toString().trim();
    if (phoneCode.isNotEmpty && !phoneCode.startsWith('+')) {
      selectedCountryCode.value = '+$phoneCode';
    } else if (phoneCode.isNotEmpty) {
      selectedCountryCode.value = phoneCode;
    } else {
      selectedCountryCode.value = '+49';
    }
    selectedCountryFlag.value = _flagFromPhoneCode(selectedCountryCode.value);
    customerPhoneController.text = customer.phoneNumber ?? '';
    validateName(customerNameController.text);
    validatePhone(customerPhoneController.text);
    customerSearchResults.clear();
    onCustomerSearchResultsChanged?.call();
    _customerSearchDebounce?.cancel();
    _isPrefillingFromCustomerSelection = false;
  }

  void clearReservationCustomer() {
    selectedReservationCustomer.value = null;
    customerNameController.clear();
    customerPhoneController.clear();
    customerEmailController.clear();
    selectedCountryCode.value = '+49';
    selectedCountryFlag.value = '🇩🇪';
    nameError.value = '';
    phoneError.value = '';
    isNameValid.value = false;
    isPhoneValid.value = false;
  }

  static String _flagFromPhoneCode(String? phoneCode) {
    final code = phoneCode?.replaceFirst(RegExp(r'^\+\s*'), '').trim();
    if (code == null || code.isEmpty) return '🇩🇪';
    final country = CountryParser.tryParsePhoneCode(code);
    return country?.flagEmoji ?? '🇩🇪';
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
    } catch (e) {}
  }

  void updateOrderFilter(String value) {
    selectedOrderFilter.value = value;
    fetchReservations();
  }

  void updateDateOption(String option) {
    selectedMonth.value = option;
    if (option != 'Custom Date') {
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
    _customerSearchDebounce?.cancel();
    onCustomerSearchResultsChanged = null;
    reservationNameFocusNode.removeListener(_onReservationNameFocusChange);
    reservationNameFocusNode.dispose();
    reservationPhoneFocusNode.removeListener(_onReservationPhoneFocusChange);
    reservationPhoneFocusNode.dispose();
    onReservationNameFocusGained = null;
    onReservationPhoneFocusGained = null;
    reservationsScrollController.removeListener(_onReservationsScroll);
    reservationsScrollController.dispose();
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerEmailController.dispose();
    specialRequestController.dispose();
    super.onClose();
  }

  void selectPerson(String value) => selectedPerson.value = value;

  Future<void> selectTimeSlot(String title, String timeSlot) async {
    if (isCheckingAvailability.value) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDateReservation.value);
    final timeSlotApi = _displayTimeToApiTime(timeSlot);
    isCheckingAvailability.value = true;
    checkingSlotSectionTitle.value = title;
    checkingSlotValue.value = timeSlot;
    try {
      final body = <String, dynamic>{'date': dateStr, 'time_slot': timeSlotApi};
      final tableId = selectedTable.value?.id;
      if (tableId != null) body['table_id'] = tableId;
      final response = await networkClient.post(
        ArgumentConstant.reservationsCheckAvailabilityEndpoint,
        data: body,
      );
      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (ok && _isCheckAvailabilitySuccess(response)) {
        selectedTimeSlotTitle.value = title;
        selectedTimeSlot.value = timeSlot;
      } else {
        _showCheckAvailabilityError(response);
      }
    } catch (e) {
      AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isCheckingAvailability.value = false;
      checkingSlotSectionTitle.value = '';
      checkingSlotValue.value = '';
    }
  }

  bool _isCheckAvailabilitySuccess(dynamic response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) return false;
    if (data['success'] != true) return false;
    final inner = data['data'];
    return inner is Map<String, dynamic> && inner['available'] == true;
  }

  void _showCheckAvailabilityError(dynamic response) {
    String message = TranslationKeys.somethingWentWrong.tr;
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final inner = data['data'];
      if (inner is Map<String, dynamic> && inner['message'] is String) {
        message = inner['message'] as String;
      } else if (data['message'] is String) {
        message = data['message'] as String;
      } else if (data['error'] is String) {
        message = data['error'] as String;
      }
    }
    AppToast.showError(message);
  }

  final RxInt statusUpdatingReservationIndex = (-1).obs;

  String _statusToApiValue(String status) => _statusToApi(status);

  String _statusToApiFilter(String filter) => _statusToApi(filter);

  static String _statusToApi(String status) {
    const apiRequestStatuses = [
      'Pending',
      'Confirmed',
      'Checked In',
      'Cancelled',
      'No Show',
    ];
    if (apiRequestStatuses.contains(status)) return status;
    return status.replaceAll('_', ' ');
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
    } on ApiException catch (e) {
      AppToast.showError(e.message);
    } catch (e) {
      AppToast.showError(
        e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString(),
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

  bool validateName(String name) {
    if (name.isEmpty) {
      nameError.value = TranslationKeys.customerNameRequired.tr;
      isNameValid.value = false;
      return false;
    }
    if (name.length < 2) {
      nameError.value = TranslationKeys.nameMustBeAtLeast2Characters.tr;
      isNameValid.value = false;
      return false;
    }
    nameError.value = '';
    isNameValid.value = true;
    return true;
  }

  bool validatePhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (phone.isEmpty) {
      phoneError.value = TranslationKeys.phoneNumberRequired.tr;
      isPhoneValid.value = false;
      return false;
    }
    if (cleanPhone.length < 10) {
      phoneError.value = TranslationKeys.phoneNumberMustBeAtLeast10Digits.tr;
      isPhoneValid.value = false;
      return false;
    }
    if (cleanPhone.length > 15) {
      phoneError.value = TranslationKeys.phoneNumberTooLong.tr;
      isPhoneValid.value = false;
      return false;
    }
    phoneError.value = '';
    isPhoneValid.value = true;
    return true;
  }

  bool get isFormValid =>
      isNameValid.value &&
      isPhoneValid.value &&
      selectedTimeSlot.value.isNotEmpty;

  Future<void> fetchTablesAreas() async {
    tableAreasList.clear();
    try {
      final response = await networkClient.get(ArgumentConstant.tablesAreasEndpoint);
      if (!_isSuccessResponse(response)) return;
      final tableModelData = tableModel.TableModel.fromJson(response.data as Map<String, dynamic>);
      if (tableModelData.data != null) {
        tableAreasList.assignAll(tableModelData.data!);
      }
    } catch (_) {}
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
        'reservationDate': r.reservationDate,
        'reservationTime': r.reservationTime,
        'reservationSlotType': r.reservationSlotType ?? '',
        'customer_id': r.customer?.id,
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
      if (!_isSuccessResponse(response)) {
        if (!loadMore) reservations.clear();
        return;
      }
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
    } catch (_) {
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

  String _formatDateForApi(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  void clearForm() {
    editingReservationIndex.value = -1;
    _customerSearchDebounce?.cancel();
    selectedReservationCustomer.value = null;
    customerSearchResults.clear();
    customerNameController.clear();
    customerPhoneController.clear();
    customerEmailController.clear();
    specialRequestController.clear();
    selectedCountryCode.value = '+49';
    selectedCountryFlag.value = '🇩🇪';
    selectedPerson.value = '1 Person';
    selectedTimeSlot.value = '';
    selectedTimeSlotTitle.value = '';
    selectedDateReservation.value = DateTime.now();
    nameError.value = '';
    phoneError.value = '';
    isNameValid.value = false;
    isPhoneValid.value = false;
    selectedTable.value = null;
    isTableExpanded.value = false;
    selectedReservationStatus.value = 'Pending';
  }

  Future<void> saveReservation() async {
    final nameValid = validateName(customerNameController.text);
    final phoneValid = validatePhone(customerPhoneController.text);
    if (!nameValid || !phoneValid) {
      AppToast.showError(
        TranslationKeys.pleaseFillAllRequiredFields.tr,
        title: TranslationKeys.validationError.tr,
      );
      return;
    }
    if (selectedTimeSlot.value.isEmpty) {
      AppToast.showWarning(
        TranslationKeys.pleaseSelectTimeSlot.tr,
        title: TranslationKeys.timeSlotRequired.tr,
      );
      return;
    }

    isSavingReservation.value = true;
    try {
      if (isEditingReservation) {
        await _updateReservation();
      } else {
        await _createReservation();
      }
    } catch (e) {
      AppToast.showError(
        e.toString().replaceFirst('Exception: ', ''),
        title: TranslationKeys.error.tr,
      );
    } finally {
      isSavingReservation.value = false;
    }
  }

  Map<String, dynamic> _reservationBody() {
    final timeSlotApi = _displayTimeToApiTime(selectedTimeSlot.value);
    final body = <String, dynamic>{
      'date': DateFormat('yyyy-MM-dd').format(selectedDateReservation.value),
      'time_slot': timeSlotApi,
      'party_size': int.parse(selectedPerson.value.split(' ')[0]),
      'reservation_status': _statusToApiValue(selectedReservationStatus.value),
      'special_requests': specialRequestController.text.trim(),
      'customer_name': customerNameController.text.trim(),
      'customer_phone': customerPhoneController.text.trim(),
      'customer_email': customerEmailController.text.trim(),
    };
    if (selectedTable.value?.id != null) {
      body['table_id'] = selectedTable.value!.id;
    }
    final customer = selectedReservationCustomer.value;
    if (customer?.id != null) {
      body['customer_id'] = customer!.id;
    }
    return body;
  }

  Future<void> _createReservation() async {
    final response = await networkClient.post(
      ArgumentConstant.reservationsEndpoint,
      data: _reservationBody(),
    );
    if (!_isSuccessResponse(response)) {
      AppToast.showError(
        TranslationKeys.pleaseFillAllRequiredFields.tr,
        title: TranslationKeys.error.tr,
      );
      return;
    }
    AppToast.showSuccess(
      TranslationKeys.reservationCreatedSuccessfully.tr,
      title: TranslationKeys.success.tr,
    );
    clearForm();
    Get.back();
    fetchReservations();
  }

  Future<void> _updateReservation() async {
    final index = editingReservationIndex.value;
    if (index < 0 || index >= reservations.length) return;
    final id = reservations[index]['id'];
    if (id == null) return;
    final endpoint =
        '${ArgumentConstant.reservationsEndpoint}/${id}';
    final response = await networkClient.put(endpoint, data: _reservationBody());
    if (!_isSuccessResponse(response)) {
      AppToast.showError(
        TranslationKeys.pleaseFillAllRequiredFields.tr,
        title: TranslationKeys.error.tr,
      );
      return;
    }
    AppToast.showSuccess(
      'Reservation updated',
      title: TranslationKeys.success.tr,
    );
    clearForm();
    Get.back();
    fetchReservations();
  }

  static const Map<String, Color> _statusTextColor = {
    'Pending': Color(0xFF723B13),
    'Confirmed': Color(0xFF03543F),
    'Cancelled': Color(0xFF9B1C1C),
    'Checked In': Color(0xFF1E429F),
    'No Show': Color(0xFF1F2937),
  };
  static const Map<String, Color> _statusBgColor = {
    'Pending': Color(0xFFFDF6B2),
    'Confirmed': Color(0xFFDEF7EC),
    'Cancelled': Color(0xFFFDE8E8),
    'Checked In': Color(0xFFE1EFFE),
    'No Show': Color(0xFFF3F4F6),
  };
  static const Map<String, Color> _statusBorderColor = {
    'Pending': Color(0xFFE3A008),
    'Confirmed': Color(0xFF31C48D),
    'Cancelled': Color(0xFFF98080),
    'Checked In': Color(0xFF76A9FA),
    'No Show': Color(0xFF9CA3AF),
  };

  Color getStatusColor(String status) =>
      _statusTextColor[status] ?? Colors.grey.shade300;

  Color getStatusBgColor(String status) =>
      _statusBgColor[status] ?? Colors.grey.shade300;

  Color getStatusBorderColor(String status) =>
      _statusBorderColor[status] ?? Colors.grey.shade300;
}
