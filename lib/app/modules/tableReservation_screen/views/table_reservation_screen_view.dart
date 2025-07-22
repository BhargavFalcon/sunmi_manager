import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

import '../controllers/table_reservation_screen_controller.dart';

class TableReservationScreenView
    extends GetView<TableReservationScreenController> {
  const TableReservationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TableReservationScreenController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Reservation'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            children: [
              // Stepper with connector line and tap support
              Stack(
                children: [
                  // Connector Line
                  Positioned(
                    top: MySize.getHeight(20),
                    left: 0,
                    right: 0,
                    child: Row(
                      children: List.generate(controller.steps.length - 1, (
                        index,
                      ) {
                        return Expanded(
                          child: Container(
                            height: 2,
                            color:
                                index < controller.currentStep.value
                                    ? ColorConstants.primaryColor
                                    : Colors.grey.shade300,
                          ),
                        );
                      }),
                    ),
                  ),

                  // Stepper Icons & Labels with Tap
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(controller.steps.length, (index) {
                      final isActive = index <= controller.currentStep.value;
                      return GestureDetector(
                        onTap: () => controller.jumpToStep(index),
                        child: Column(
                          children: [
                            Container(
                              width: MySize.getHeight(40),
                              height: MySize.getHeight(40),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? ColorConstants.primaryColor
                                        : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                controller.icons[index],
                                color:
                                    isActive
                                        ? Colors.white
                                        : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.steps[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    isActive
                                        ? ColorConstants.primaryColor
                                        : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Progress Bar
              LinearProgressIndicator(
                value:
                    (controller.currentStep.value + 1) /
                    controller.steps.length,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  ColorConstants.primaryColor,
                ),
                minHeight: 4,
              ),

              const Spacer(),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed:
                        controller.currentStep.value > 0
                            ? controller.prevStep
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 10,
                      ),
                      child: Text("Back"),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        controller.currentStep.value <
                                controller.steps.length - 1
                            ? controller.nextStep
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEE3FF),
                      foregroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 10,
                      ),
                      child: Text("Next"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
