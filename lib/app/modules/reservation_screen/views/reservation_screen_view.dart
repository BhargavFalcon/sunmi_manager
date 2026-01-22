import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/widgets/access_limited_dialog.dart';

import '../controllers/reservation_screen_controller.dart';

class ReservationScreenView extends GetView<ReservationScreenController> {
  const ReservationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return GetBuilder<ReservationScreenController>(
      init: ReservationScreenController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showReservationBottomSheet(context, controller),
            backgroundColor: ColorConstants.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Obx(() {
            return Stack(
              children: [
                IgnorePointer(
                  ignoring: controller.showAccessDialog.value,
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Expanded(
                        child: SingleChildScrollView(
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
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Colors.white,
                                              ),
                                        ),
                                        builder: (
                                          context,
                                          controllerMenu,
                                          child,
                                        ) {
                                          return GestureDetector(
                                            onTap: () {
                                              if (controllerMenu.isOpen) {
                                                controllerMenu.close();
                                              } else {
                                                controllerMenu.open();
                                              }
                                            },
                                            child: Obx(() {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        controller
                                                            .getDropdownDisplayText(),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              MySize.getHeight(
                                                                12,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.keyboard_arrow_down,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                        menuChildren:
                                            controller.dateOptions.map((
                                              option,
                                            ) {
                                              return MenuItemButton(
                                                onPressed: () {
                                                  controller.updateDateOption(
                                                    option,
                                                  );
                                                  if (option == 'Custom Date') {
                                                    Future.delayed(
                                                      const Duration(
                                                        milliseconds: 10,
                                                      ),
                                                      () {
                                                        controller
                                                            .showCustomDateRangePickerPop(
                                                              context,
                                                            );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  _translateDateOption(option),
                                                  style: TextStyle(
                                                    fontSize: MySize.getHeight(
                                                      12,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                    SizedBox(width: MySize.getWidth(12)),
                                    Expanded(
                                      child: MenuAnchor(
                                        style: MenuStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Colors.white,
                                              ),
                                        ),
                                        builder: (
                                          context,
                                          controllerMenu,
                                          child,
                                        ) {
                                          return GestureDetector(
                                            onTap: () {
                                              if (controllerMenu.isOpen) {
                                                controllerMenu.close();
                                              } else {
                                                controllerMenu.open();
                                              }
                                            },
                                            child: Obx(() {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      _translateOrderFilter(
                                                        controller
                                                            .selectedOrderFilter
                                                            .value,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize:
                                                            MySize.getHeight(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.keyboard_arrow_down,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                        menuChildren:
                                            controller.orderFilterOptions.map((
                                              option,
                                            ) {
                                              return MenuItemButton(
                                                onPressed:
                                                    () => controller
                                                        .updateOrderFilter(
                                                          option,
                                                        ),
                                                child: Text(
                                                  _translateOrderFilter(option),
                                                  style: TextStyle(
                                                    fontSize: MySize.getHeight(
                                                      12,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MySize.getHeight(12)),
                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.reservations.length,
                                  itemBuilder: (context, index) {
                                    return _buildReservationCard(
                                      controller,
                                      index,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.showAccessDialog.value)
                  const AccessLimitedDialog(),
              ],
            );
          }),
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
                            child: Text(
                              TranslationKeys.reservation.tr,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MySize.getHeight(18),
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
                                  SizedBox(width: MySize.getWidth(12)),
                                  Expanded(
                                    child: _buildSelectPersonDropdown(
                                      controller,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: MySize.getHeight(10)),
                              Text(
                                TranslationKeys.selectTimeSlot.tr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: MySize.getHeight(16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: MySize.getHeight(10)),
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
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              time,
                                              style: TextStyle(
                                                fontSize: MySize.getHeight(14),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                              SizedBox(height: MySize.getHeight(10)),
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
                                          SizedBox(width: MySize.getWidth(8)),
                                          Text(
                                            TranslationKeys
                                                .anySpecialRequest
                                                .tr,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: MySize.getHeight(8)),
                                      CupertinoTextField(
                                        maxLines: 2,
                                        placeholder:
                                            TranslationKeys
                                                .enterYourSpecialRequest
                                                .tr,
                                        decoration: BoxDecoration(
                                          color: ColorConstants.bgColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: ColorConstants.grey9E9E9E,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        placeholderStyle: TextStyle(
                                          color: ColorConstants.grey9E9E9E,
                                          fontSize: MySize.getHeight(14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: MySize.getHeight(10)),
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
                                          SizedBox(width: MySize.getWidth(8)),
                                          Text(
                                            "${TranslationKeys.customerName.tr} *",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: MySize.getHeight(8)),
                                      CupertinoTextField(
                                        placeholder:
                                            TranslationKeys.enterName.tr,
                                        decoration: BoxDecoration(
                                          color: ColorConstants.bgColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: ColorConstants.grey9E9E9E,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        placeholderStyle: TextStyle(
                                          color: ColorConstants.grey9E9E9E,
                                          fontSize: MySize.getHeight(14),
                                        ),
                                      ),
                                      SizedBox(height: MySize.getHeight(10)),
                                      Row(
                                        children: [
                                          Icon(Icons.phone_outlined),
                                          SizedBox(width: MySize.getWidth(8)),
                                          Text(
                                            "${TranslationKeys.customerPhone.tr} *",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: MySize.getHeight(8)),
                                      CupertinoTextField(
                                        placeholder:
                                            TranslationKeys.enterPhoneNumber.tr,
                                        keyboardType: TextInputType.phone,
                                        decoration: BoxDecoration(
                                          color: ColorConstants.bgColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: ColorConstants.grey9E9E9E,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        placeholderStyle: TextStyle(
                                          color: ColorConstants.grey9E9E9E,
                                          fontSize: MySize.getHeight(14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: MySize.getHeight(20)),
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
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          TranslationKeys.cancel.tr,
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
                                        TranslationKeys.reserveNow.tr,
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
                              SizedBox(height: MySize.getHeight(20)),
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
                  Text(
                    _translatePersonOption(controller.selectedPerson.value),
                    style: TextStyle(fontSize: MySize.getHeight(16)),
                  ),
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
                  child: Text(
                    _translatePersonOption(option),
                    style: TextStyle(fontSize: MySize.getHeight(14)),
                  ),
                ),
              )
              .toList(),
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
            border: Border.all(color: ColorConstants.grey9E9E9E, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.date_range_rounded),
              Text(
                controller.formattedDateReservation,
                style: TextStyle(fontSize: MySize.getHeight(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(
    ReservationScreenController controller,
    int index,
  ) {
    return Obx(() {
      final item = controller.reservations[index];

      return Container(
        margin: EdgeInsets.only(bottom: MySize.getHeight(16)),
        padding: EdgeInsets.all(MySize.getHeight(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MySize.getHeight(12)),
          boxShadow: ColorConstants.getShadow2,
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (item['table'] != null || item['tableCode'] != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(8),
                          vertical: MySize.getHeight(6),
                        ),
                        margin: EdgeInsets.only(right: MySize.getWidth(8)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                        ),
                        child: Text(
                          item['table'] ?? item['tableCode'] ?? '',
                          style: TextStyle(
                            fontSize: MySize.getHeight(12),
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['guests']} ${TranslationKeys.guests.tr}',
                          style: TextStyle(
                            fontSize: MySize.getHeight(12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: MySize.getHeight(4)),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: MySize.getHeight(16),
                              color: Colors.red,
                            ),
                            SizedBox(width: MySize.getWidth(4)),
                            Text(
                              item['time'],
                              style: TextStyle(
                                fontSize: MySize.getHeight(12),
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: MySize.getWidth(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MySize.getWidth(12),
                    vertical: MySize.getHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: controller.getStatusBgColor(item['status']),
                    borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    border: Border.all(
                      color: controller.getStatusBorderColor(item['status']),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _translateStatus(item['status']).toUpperCase(),
                    style: TextStyle(
                      color: controller.getStatusColor(item['status']),
                      fontWeight: FontWeight.w600,
                      fontSize: MySize.getHeight(12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MySize.getHeight(10)),
            Row(
              children: [
                Icon(Icons.note_alt_outlined, size: MySize.getHeight(16)),
                SizedBox(width: MySize.getWidth(4)),
                Expanded(
                  child: Text(
                    "${item['note']}",
                    style: TextStyle(fontSize: MySize.getHeight(12)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: MySize.getWidth(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MySize.getWidth(12),
                    vertical: MySize.getHeight(6),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorConstants.grey9E9E9E,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.table_bar_outlined,
                        size: MySize.getHeight(18),
                      ),
                      SizedBox(width: MySize.getWidth(4)),
                      Text(
                        TranslationKeys.assignTable.tr,
                        style: TextStyle(fontSize: MySize.getHeight(12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: MySize.getHeight(10)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(8),
                vertical: MySize.getHeight(8),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                color: Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: MySize.getHeight(18)),
                  SizedBox(width: MySize.getWidth(6)),
                  Expanded(
                    child: Text(
                      item['name'],
                      style: TextStyle(fontSize: MySize.getHeight(12)),
                    ),
                  ),
                  Icon(Icons.call_outlined, size: MySize.getHeight(18)),
                  SizedBox(width: MySize.getWidth(6)),
                  Text(
                    item['phone'],
                    style: TextStyle(fontSize: MySize.getHeight(12)),
                  ),
                ],
              ),
            ),
            SizedBox(height: MySize.getHeight(12)),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(16),
                          vertical: MySize.getHeight(8),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorConstants.grey9E9E9E,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _translateStatus(item['status']),
                              style: TextStyle(fontSize: MySize.getHeight(12)),
                            ),
                            SizedBox(width: MySize.getWidth(4)),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: MySize.getHeight(18),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  menuChildren:
                      controller.statusOptions.map((status) {
                        return MenuItemButton(
                          onPressed:
                              () => controller.updateStatus(index, status),
                          child: Text(
                            _translateStatus(status),
                            style: TextStyle(fontSize: MySize.getHeight(12)),
                          ),
                        );
                      }).toList(),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MySize.getWidth(8),
                    vertical: MySize.getHeight(8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    border: Border.all(
                      color: ColorConstants.grey9E9E9E,
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.edit_outlined, size: MySize.getHeight(20)),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _translateDateOption(String option) {
    switch (option) {
      case 'Today':
        return TranslationKeys.today.tr;
      case 'Yesterday':
        return TranslationKeys.yesterday.tr;
      case 'Last 7 Days':
        return TranslationKeys.last7Days.tr;
      case 'Last 30 Days':
        return TranslationKeys.last30Days.tr;
      case 'Custom Date':
        return TranslationKeys.customDate.tr;
      default:
        return option;
    }
  }

  String _translateOrderFilter(String option) {
    switch (option) {
      case 'Pending':
        return TranslationKeys.pending.tr;
      case 'Confirmed':
        return TranslationKeys.confirmed.tr;
      case 'Cancelled':
        return TranslationKeys.cancelled.tr;
      case 'Checked In':
        return TranslationKeys.checkedIn.tr;
      case 'No Show':
        return TranslationKeys.noShow.tr;
      default:
        return option;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Pending':
        return TranslationKeys.pending.tr;
      case 'Confirmed':
        return TranslationKeys.confirmed.tr;
      case 'Cancelled':
        return TranslationKeys.cancelled.tr;
      case 'Checked In':
        return TranslationKeys.checkedIn.tr;
      case 'No Show':
        return TranslationKeys.noShow.tr;
      default:
        return status;
    }
  }

  String _translatePersonOption(String option) {
    switch (option) {
      case '1 Person':
        return TranslationKeys.onePerson.tr;
      case '2 Persons':
        return TranslationKeys.twoPersons.tr;
      case '3 Persons':
        return TranslationKeys.threePersons.tr;
      case '4 Persons':
        return TranslationKeys.fourPersons.tr;
      case '5 Persons':
        return TranslationKeys.fivePersons.tr;
      case '6 Persons':
        return TranslationKeys.sixPersons.tr;
      case '7 Persons':
        return TranslationKeys.sevenPersons.tr;
      case '8 Persons':
        return TranslationKeys.eightPersons.tr;
      case '9 Persons':
        return TranslationKeys.ninePersons.tr;
      case '10 Persons':
        return TranslationKeys.tenPersons.tr;
      default:
        return option;
    }
  }
}
