import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/modules/tableReservation_screen/controllers/table_reservation_screen_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class AnimatedProgressIndicator extends ImplicitlyAnimatedWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;

  const AnimatedProgressIndicator({
    super.key,
    required this.value,
    this.backgroundColor = Colors.grey,
    this.valueColor = Colors.blue,
    this.minHeight = 4.0,
    super.curve = Curves.easeInOut,
    super.duration = const Duration(milliseconds: 500),
  });

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState
    extends AnimatedWidgetBaseState<AnimatedProgressIndicator> {
  Tween<double>? _valueTween;
  ColorTween? _colorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween =
        visitor(
              _valueTween,
              widget.value,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;

    _colorTween =
        visitor(
              _colorTween,
              widget.valueColor,
              (dynamic value) => ColorTween(begin: value as Color),
            )
            as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: _valueTween?.evaluate(animation),
      backgroundColor: widget.backgroundColor,
      valueColor: _colorTween!.animate(animation),
      minHeight: widget.minHeight,
    );
  }
}

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
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
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
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
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
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isActive
                                            ? ColorConstants.primaryColor
                                            : Colors.grey.shade400,
                                  ),
                                  child: Text(controller.getStepLabel(index)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AnimatedProgressIndicator(
                    value:
                        (controller.currentStep.value + 1) /
                        controller.steps.length,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: ColorConstants.primaryColor,
                    minHeight: 4,
                  ),
                  const SizedBox(height: 40),
                  Expanded(child: _buildCurrentStep(controller)),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCurrentStep(TableReservationScreenController controller) {
    switch (controller.currentStep.value) {
      case 0:
        return _buildPeopleStep(controller);
      case 1:
        return _buildDateStep(controller);
      case 2:
        return _buildTimeStep(controller);
      case 3:
        return _buildConfirmStep(controller);
      default:
        return Container();
    }
  }

  Widget _buildPeopleStep(TableReservationScreenController controller) {
    return Column(
      key: const ValueKey('people_step'),
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
              final isSelected = controller.selectedPeople.value == number;
              return GestureDetector(
                onTap: () => controller.selectPeople(number),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? ColorConstants.primaryColor
                              : Colors.grey.withOpacity(0.5),
                      width: isSelected ? 2 : 1.5,
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
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDateStep(TableReservationScreenController controller) {
    return Column(
      key: const ValueKey('date_step'),
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
            lastDay: DateTime.now().add(const Duration(days: 365)),
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
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.black54),
              weekdayStyle: TextStyle(color: Colors.black54),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.black),
              todayTextStyle: const TextStyle(color: Colors.black),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: Colors.black54),
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              selectedDecoration: const BoxDecoration(
                color: ColorConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              outsideTextStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
              weekendTextStyle: const TextStyle(color: Colors.black),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(controller.selectedDate.value, day);
            },
            onDaySelected: (selected, focused) {
              if (!selected.isBefore(
                DateTime.now().subtract(const Duration(days: 1)),
              )) {
                controller.selectedDate.value = selected;
                controller.jumpToStep(2);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStep(TableReservationScreenController controller) {
    return Column(
      key: const ValueKey('time_step'),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  controller.selectedTime.value!.hour == slotTime.hour &&
                  controller.selectedTime.value!.minute == slotTime.minute;

              return GestureDetector(
                onTap: () {
                  controller.selectedTime.value = slotTime;
                  controller.jumpToStep(3);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
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
    );
  }

  Widget _buildConfirmStep(TableReservationScreenController controller) {
    return Column(
      key: const ValueKey('confirm_step'),
      children: [
        Text(
          'Confirm Reservation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 30),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(
                  'People',
                  '${controller.selectedPeople.value} ${controller.selectedPeople.value == 1 ? 'Person' : 'People'}',
                ),
                Divider(),
                _buildDetailRow(
                  'Date',
                  '${controller.selectedDate.value.day} '
                      '${controller.getMonthAbbreviation(controller.selectedDate.value.month)} '
                      '${controller.selectedDate.value.year}',
                ),
                Divider(),
                _buildDetailRow(
                  'Time',
                  controller.selectedTime.value!.format(Get.context!),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // Handle reservation confirmation
            Get.snackbar(
              'Reservation Confirmed',
              'Your table has been booked successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Confirm Reservation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
