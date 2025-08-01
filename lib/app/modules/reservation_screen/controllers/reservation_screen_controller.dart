import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReservationScreenController extends GetxController {
  // Text Editing Controllers
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();

  // Observables
  RxString selectedFilter = 'Today'.obs;
  RxString selectedPerson = '1 Person'.obs;
  RxString selectedTimeSlot = ''.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DateTime> selectedDateReservation = DateTime.now().obs;

  // Validation
  RxBool isNameValid = false.obs;
  RxBool isPhoneValid = false.obs;
  RxString nameError = ''.obs;
  RxString phoneError = ''.obs;

  List<String> filterOptions = [
    'Today',
    'Future',
    'Current Week',
    'Last Week',
    'Last 7 Days',
    'Current Month',
    'Last Month',
    'Current Year',
    'Last Year',
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

  String get formattedDate =>
      DateFormat('dd MMM yyyy').format(selectedDate.value);

  String get formattedDateReservation =>
      DateFormat('EEE MMMM dd yyyy').format(selectedDateReservation.value);

  List<String> statusOptions = ['Pending', 'Confirmed', 'Cancelled'];

  RxList<Map<String, dynamic>> reservations =
      [
        {
          'guests': 3,
          'note': 'Allergic to peanuts',
          'time': '26 June, 12:00 PM',
          'name': 'Foggy Nelson',
          'phone': '+91 98765 43210',
          'status': 'Pending',
        },
        {
          'guests': 6,
          'note': 'Requires wheelchair access',
          'time': '26 June, 08:00 PM',
          'name': 'Karen Page',
          'phone': '+91 45620 45620',
          'status': 'Confirmed',
        },
        {
          'guests': 2,
          'note': 'Vegetarian meal requested',
          'time': '26 June, 09:30 AM',
          'name': 'Wilson Fisk',
          'phone': '+91 88812 88812',
          'status': 'Cancelled',
        },
        {
          'guests': 4,
          'note': 'Celebrating anniversary',
          'time': '26 June, 07:00 PM',
          'name': 'Matt Murdock',
          'phone': '+91 12345 67890',
          'status': 'Checked In',
        },
        {
          'guests': 5,
          'note': 'Requires high chair for child',
          'time': '26 June, 10:00 AM',
          'name': 'Jessica Jones',
          'phone': '+91 23456 78901',
          'status': 'No Show',
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();

    // Add listeners for real-time validation
    customerNameController.addListener(() {
      validateName(customerNameController.text);
    });

    customerPhoneController.addListener(() {
      validatePhone(customerPhoneController.text);
    });
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    customerNameController.dispose();
    customerPhoneController.dispose();
    specialRequestController.dispose();
    super.onClose();
  }

  void selectFilter(String value) => selectedFilter.value = value;

  void selectPerson(String value) => selectedPerson.value = value;

  void selectTimeSlot(String timeSlot) {
    selectedTimeSlot.value = timeSlot;
  }

  void updateStatus(int index, String newStatus) {
    reservations[index]['status'] = newStatus;
    reservations.refresh();
  }

  // Validation Methods
  bool validateName(String name) {
    if (name.isEmpty) {
      nameError.value = 'Customer name is required';
      isNameValid.value = false;
      return false;
    } else if (name.length < 2) {
      nameError.value = 'Name must be at least 2 characters';
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
      phoneError.value = 'Phone number is required';
      isPhoneValid.value = false;
      return false;
    } else if (cleanPhone.length < 10) {
      phoneError.value = 'Phone number must be at least 10 digits';
      isPhoneValid.value = false;
      return false;
    } else if (cleanPhone.length > 15) {
      phoneError.value = 'Phone number is too long';
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

  void clearForm() {
    customerNameController.clear();
    customerPhoneController.clear();
    specialRequestController.clear();
    selectedPerson.value = '1 Person';
    selectedTimeSlot.value = '';
    selectedDateReservation.value = DateTime.now();
    nameError.value = '';
    phoneError.value = '';
    isNameValid.value = false;
    isPhoneValid.value = false;
  }

  void saveReservation() {
    // Validate all fields
    bool nameValid = validateName(customerNameController.text);
    bool phoneValid = validatePhone(customerPhoneController.text);

    if (!nameValid || !phoneValid) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return;
    }

    if (selectedTimeSlot.value.isEmpty) {
      Get.snackbar(
        'Time Slot Required',
        'Please select a time slot',
        snackPosition: SnackPosition.BOTTOM,
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
      'phone': customerPhoneController.text.trim(),
      'status': 'Pending',
      'specialRequest': specialRequestController.text.trim(),
    };

    // Add to reservations list
    reservations.add(newReservation);

    // Show success message
    Get.snackbar(
      'Success',
      'Reservation created successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade700,
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
