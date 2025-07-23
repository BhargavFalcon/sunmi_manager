import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableReservationScreenController extends GetxController {
  RxInt currentStep = 0.obs;
  RxInt selectedPeople = 0.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  List<String> steps = ['People', 'Date', 'Time', 'Confirm'];
  List<IconData> icons = [
    Icons.people,
    Icons.calendar_today,
    Icons.access_time,
    Icons.check_circle,
  ];

  final List<String> timeSlots = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];

  void jumpToStep(int step) {
    if (step >= 0 && step < steps.length) {
      currentStep.value = step;
    }
  }

  void selectPeople(int count) {
    selectedPeople.value = count;
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
    }
  }

  String getStepLabel(int index) {
    switch (index) {
      case 0:
        return selectedPeople.value > 0
            ? '${selectedPeople.value} ${selectedPeople.value == 1 ? 'Person' : 'People'}'
            : 'People';
      case 1:
        final now = DateTime.now();
        final selected = selectedDate.value;
        final showYear = selected.year != now.year;
        return showYear
            ? '${selected.day} ${getMonthAbbreviation(selected.month)} ${selected.year}'
            : '${selected.day} ${getMonthAbbreviation(selected.month)}';
      case 2:
        if (selectedTime.value == null) return 'Time';
        final hour = selectedTime.value!.hour;
        final minute = selectedTime.value!.minute;
        final period = hour < 12 ? 'AM' : 'PM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      case 3:
        return 'Confirm';
      default:
        return steps[index];
    }
  }

  String getMonthAbbreviation(int month) {
    return [
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
    ][month - 1];
  }
}
