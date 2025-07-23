import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/table_reservation_screen_controller.dart';

class TableReservationScreenView
    extends GetView<TableReservationScreenController> {
  const TableReservationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TableReservationScreenController>(
      init: TableReservationScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reservation'),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Positioned(
                        top: MySize.getHeight(20),
                        left: 0,
                        right: 0,
                        child: Row(
                          children: List.generate(controller.steps.length - 1, (
                            index,
                          ) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Container(
                                  height: 2,
                                  color:
                                      index < controller.currentStep.value
                                          ? ColorConstants.primaryColor
                                          : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(controller.steps.length, (
                          index,
                        ) {
                          final isActive =
                              index <= controller.currentStep.value;
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
                                  controller.getStepLabel(index),
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
                  const SizedBox(height: 40),
                  if (controller.currentStep.value == 0)
                    Column(
                      children: [
                        const Text(
                          'How many people?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: MySize.getWidth(300),
                          child: Wrap(
                            spacing: MySize.getWidth(50),
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: List.generate(10, (index) {
                              final number = index + 1;
                              final isSelected =
                                  controller.selectedPeople.value == number;
                              return GestureDetector(
                                onTap: () => controller.selectPeople(number),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                    color:
                                        isSelected
                                            ? ColorConstants.primaryColor
                                            : Colors.transparent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$number',
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  if (controller.currentStep.value == 1)
                    Column(
                      children: [
                        const Text(
                          'Which day?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TableCalendar(
                            focusedDay: controller.selectedDate.value,
                            firstDay: DateTime.now(),
                            lastDay: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            calendarFormat: CalendarFormat.month,
                            startingDayOfWeek: StartingDayOfWeek.sunday,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: Colors.black,
                              ),
                            ),
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekendStyle: TextStyle(color: Colors.black54),
                              weekdayStyle: TextStyle(color: Colors.black54),
                            ),
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              todayTextStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              todayDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(color: Colors.black54),
                              ),
                              selectedTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              selectedDecoration: const BoxDecoration(
                                color: ColorConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              outsideTextStyle: TextStyle(
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              weekendTextStyle: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            selectedDayPredicate: (day) {
                              return isSameDay(
                                controller.selectedDate.value,
                                day,
                              );
                            },
                            onDaySelected: (selected, focused) {
                              if (!selected.isBefore(
                                DateTime.now().subtract(
                                  const Duration(days: 1),
                                ),
                              )) {
                                controller.selectedDate.value = selected;
                                controller.jumpToStep(2);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  if (controller.currentStep.value == 2)
                    Column(
                      children: [
                        const Text(
                          'Which time?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.timeSlots.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 2.5,
                                ),
                            itemBuilder: (context, index) {
                              final time = controller.timeSlots[index];
                              final parts = time.split(':');
                              final slotTime = TimeOfDay(
                                hour: int.parse(parts[0]),
                                minute: int.parse(parts[1]),
                              );

                              final isSelected =
                                  controller.selectedTime.value != null &&
                                  controller.selectedTime.value!.hour ==
                                      slotTime.hour &&
                                  controller.selectedTime.value!.minute ==
                                      slotTime.minute;

                              return GestureDetector(
                                onTap: () {
                                  controller.selectedTime.value = slotTime;
                                  controller.jumpToStep(3);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? ColorConstants.primaryColor
                                              : Colors.grey.shade700,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.transparent,
                                  ),
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? ColorConstants.primaryColor
                                              : Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
