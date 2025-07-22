import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableReservationScreenController extends GetxController {
  RxInt currentStep = 0.obs;

  final List<String> steps = ['People', 'Date', 'Time', 'Submit'];
  final List<IconData> icons = [
    Icons.group,
    Icons.calendar_today,
    Icons.access_time,
    Icons.check,
  ];

  void nextStep() {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void jumpToStep(int index) {
    currentStep.value = index;
  }
}
