import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';

import '../controllers/reservation_screen_controller.dart';

class ReservationScreenView extends GetView<ReservationScreenController> {
  const ReservationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationScreenController>(
      init: ReservationScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          appBar: AppBar(
            title: const Text('Reservation'),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            actions: [
              InkWell(
                onTap: () => _showReservationBottomSheet(context, controller),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: MySize.getWidth(80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorConstants.primaryColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 6),
                          const Text(
                            "New",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MenuAnchor(
                          style: MenuStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                          ),
                          builder: (context, controllerMenu, child) {
                            return GestureDetector(
                              onTap: () => controllerMenu.open(),
                              child: Obx(() {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          controller.getDropdownDisplayText(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                );
                              }),
                            );
                          },
                          menuChildren:
                              controller.dateOptions.map((option) {
                                return MenuItemButton(
                                  onPressed: () {
                                    controller.updateDateOption(option);
                                    if (option == 'Custom Date') {
                                      Future.delayed(
                                        const Duration(milliseconds: 10),
                                        () {
                                          controller
                                              .showCustomDateRangePickerPop(
                                                context,
                                              );
                                        },
                                      );
                                    }
                                  },
                                  child: Text(option),
                                );
                              }).toList(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MenuAnchor(
                          style: MenuStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                          ),
                          builder: (context, controllerMenu, child) {
                            return GestureDetector(
                              onTap: () => controllerMenu.open(),
                              child: Obx(() {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.selectedOrderFilter.value,
                                      ),
                                      const Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                );
                              }),
                            );
                          },
                          menuChildren:
                              controller.orderFilterOptions.map((option) {
                                return MenuItemButton(
                                  onPressed:
                                      () =>
                                          controller.updateOrderFilter(option),
                                  child: Text(option),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.reservations.length,
                    itemBuilder: (context, index) {
                      final item = controller.reservations[index];
                      return _buildReservationCard(controller, item, index);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReservationBottomSheet(
    BuildContext context,
    ReservationScreenController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            builder:
                (_, scrollController) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorConstants.bgColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: ColorConstants.getShadow2,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: const Text(
                              "Reservation",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAddDatePicker(
                                      context,
                                      controller,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSelectPersonDropdown(
                                      controller,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Select Time Slot",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  boxShadow: ColorConstants.getShadow2,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children:
                                        controller.timeSlots.map((time) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color:
                                                    ColorConstants.grey9E9E9E,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(time),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  boxShadow: ColorConstants.getShadow2,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline_rounded,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Any special request ?",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      CupertinoTextField(
                                        maxLines: 2,
                                        placeholder:
                                            "Enter your special request here",
                                        decoration: BoxDecoration(
                                          color: ColorConstants.bgColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: ColorConstants.grey9E9E9E,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        placeholderStyle: TextStyle(
                                          color: ColorConstants.grey9E9E9E,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  boxShadow: ColorConstants.getShadow2,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person_2_rounded),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Customer Name *",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      CupertinoTextField(
                                        placeholder: "Enter name",
                                        decoration: BoxDecoration(
                                          color: ColorConstants.bgColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: ColorConstants.grey9E9E9E,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        placeholderStyle: TextStyle(
                                          color: ColorConstants.grey9E9E9E,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.phone_outlined),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Customer Phone *",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      CupertinoTextField(
                                        placeholder: "Enter phone number",
                                        keyboardType: TextInputType.phone,
                                        decoration: BoxDecoration(
                                          color: ColorConstants.bgColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: ColorConstants.grey9E9E9E,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        placeholderStyle: TextStyle(
                                          color: ColorConstants.grey9E9E9E,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: ColorConstants.grey9E9E9E,
                                          ),
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorConstants.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Reserve Now",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildSelectPersonDropdown(ReservationScreenController controller) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      builder: (context, menuController, _) {
        return Obx(
          () => GestureDetector(
            onTap:
                () =>
                    menuController.isOpen
                        ? menuController.close()
                        : menuController.open(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(controller.selectedPerson.value),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        );
      },
      menuChildren:
          controller.personOptions
              .map(
                (option) => MenuItemButton(
                  onPressed: () => controller.selectPerson(option),
                  child: Text(option),
                ),
              )
              .toList(),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    ReservationScreenController controller,
  ) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF3B82F6),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          controller.selectedDate.value = pickedDate;
        }
      },
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(controller.formattedDate),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddDatePicker(
    BuildContext context,
    ReservationScreenController controller,
  ) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: ColorConstants.primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          controller.selectedDateReservation.value = pickedDate;
        }
      },
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: ColorConstants.grey9E9E9E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.date_range_rounded),
              Text(controller.formattedDateReservation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(
    ReservationScreenController controller,
    Map<String, dynamic> item,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ColorConstants.getShadow2,
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['guests']} Guests',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['time'],
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: controller.getStatusBgColor(item['status']),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.getStatusBorderColor(item['status']),
                  ),
                ),
                child: Text(
                  item['status'].toUpperCase(),
                  style: TextStyle(
                    color: controller.getStatusColor(item['status']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.note_alt_outlined, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text("${item['note']}", overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorConstants.grey9E9E9E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.table_bar_outlined),
                    const SizedBox(width: 4),
                    Text("Assign Table"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(item['name'])),
                const Icon(Icons.call_outlined, size: 18),
                const SizedBox(width: 6),
                Text(item['phone']),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MenuAnchor(
                style: MenuStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  elevation: WidgetStateProperty.all(4),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                builder: (context, menuController, _) {
                  return GestureDetector(
                    onTap: () {
                      menuController.isOpen
                          ? menuController.close()
                          : menuController.open();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorConstants.grey9E9E9E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(item['status']),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  );
                },
                menuChildren:
                    controller.statusOptions
                        .map(
                          (status) => MenuItemButton(
                            onPressed:
                                () => controller.updateStatus(index, status),
                            child: Text(status),
                          ),
                        )
                        .toList(),
              ),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorConstants.grey9E9E9E),
                ),
                child: Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
