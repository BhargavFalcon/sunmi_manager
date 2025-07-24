import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReservationScreenController extends GetxController {
  RxString selectedFilter = 'Today'.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

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

  String get formattedDate =>
      DateFormat('dd MMM yyyy').format(selectedDate.value);

  List<String> statusOptions = ['Pending', 'Confirmed', 'Cancelled'];

  RxList<Map<String, dynamic>> reservations =
      [
        {
          'guests': 3,
          'time': '26 June, 12:00 PM',
          'name': 'Foggy Nelson',
          'phone': '+91 98765 43210',
          'status': 'Pending',
        },
        {
          'guests': 6,
          'time': '26 June, 08:00 PM',
          'name': 'Karen Page',
          'phone': '+91 45620 45620',
          'status': 'Confirmed',
        },
        {
          'guests': 2,
          'time': '26 June, 09:30 AM',
          'name': 'Wilson Fisk',
          'phone': '+91 88812 88812',
          'status': 'Cancelled',
        },
        {
          'guests': 4,
          'time': '26 June, 07:00 PM',
          'name': 'Matt Murdock',
          'phone': '+91 12345 67890',
          'status': 'Checked In',
        },
        {
          'guests': 5,
          'time': '26 June, 10:00 AM',
          'name': 'Jessica Jones',
          'phone': '+91 23456 78901',
          'status': 'No Show',
        },
      ].obs;

  void selectFilter(String value) => selectedFilter.value = value;

  void updateStatus(int index, String newStatus) {
    reservations[index]['status'] = newStatus;
    reservations.refresh();
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
