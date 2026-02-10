import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:country_picker/country_picker.dart';
import 'package:managerapp/app/widgets/access_limited_dialog.dart';

import '../controllers/reservation_screen_controller.dart';
import '../../../model/tableModel.dart' as tableModel;

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
                            padding: EdgeInsets.all(MySize.getWidth(16)),
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
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: MySize.getWidth(
                                                    8,
                                                  ),
                                                  vertical: MySize.getHeight(
                                                    10,
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        MySize.getHeight(8),
                                                      ),
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
                                                    Icon(
                                                      Icons.keyboard_arrow_down,
                                                      size: MySize.getHeight(
                                                        16,
                                                      ),
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
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: MySize.getWidth(
                                                    8,
                                                  ),
                                                  vertical: MySize.getHeight(
                                                    10,
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        MySize.getHeight(8),
                                                      ),
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
                                                    Icon(
                                                      Icons.keyboard_arrow_down,
                                                      size: MySize.getHeight(
                                                        16,
                                                      ),
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
                                      context,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MySize.getHeight(16)),
        ),
      ),
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              builder:
                  (_, scrollController) => Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(MySize.getHeight(16)),
                      ),
                      boxShadow: ColorConstants.getShadow2,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(16),
                              vertical: MySize.getHeight(16),
                            ),
                            child: Text(
                              TranslationKeys.reservation.tr,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MySize.getHeight(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(MySize.getWidth(8)),
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
                                    fontSize: MySize.getHeight(14),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: MySize.getHeight(4)),
                                _buildTimeSlotsGrid(
                                  context,
                                  controller.timeSlots,
                                  controller,
                                ),
                                SizedBox(height: MySize.getHeight(4)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      TranslationKeys.anySpecialRequest.tr,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MySize.getHeight(12),
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                          MySize.getHeight(8),
                                        ),
                                        border: Border.all(
                                          color: ColorConstants.grey9E9E9E,
                                          width: 1,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(
                                        MySize.getWidth(12),
                                      ),
                                      placeholderStyle: TextStyle(
                                        color: ColorConstants.grey600,
                                        fontSize: MySize.getHeight(14),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MySize.getHeight(15)),
                                Obx(
                                  () => Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: ColorConstants.grey9E9E9E,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        MySize.getHeight(8),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            controller.isTableExpanded.value =
                                                !controller
                                                    .isTableExpanded
                                                    .value;
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              MySize.getWidth(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        TranslationKeys
                                                            .table
                                                            .tr,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              MySize.getHeight(
                                                                14,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            MySize.getHeight(2),
                                                      ),
                                                      Text(
                                                        TranslationKeys
                                                            .selectingTableOptional
                                                            .tr,
                                                        style: TextStyle(
                                                          color:
                                                              ColorConstants
                                                                  .grey9E9E9E,
                                                          fontSize:
                                                              MySize.getHeight(
                                                                11,
                                                              ),
                                                        ),
                                                      ),
                                                      if (controller
                                                              .selectedTable
                                                              .value ==
                                                          null) ...[
                                                        SizedBox(
                                                          height:
                                                              MySize.getHeight(
                                                                2,
                                                              ),
                                                        ),
                                                        Text(
                                                          TranslationKeys
                                                              .noTableSelectedYet
                                                              .tr,
                                                          style: TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .grey9E9E9E,
                                                            fontSize:
                                                                MySize.getHeight(
                                                                  11,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  controller
                                                          .isTableExpanded
                                                          .value
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  color: Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (controller.selectedTable.value !=
                                            null)
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: MySize.getWidth(12),
                                              right: MySize.getWidth(12),
                                              bottom: MySize.getHeight(12),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MySize.getWidth(12),
                                              vertical: MySize.getHeight(8),
                                            ),
                                            decoration: BoxDecoration(
                                              color: ColorConstants.successGreen
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    MySize.getHeight(8),
                                                  ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  controller
                                                          .selectedTable
                                                          .value
                                                          ?.tableCode ??
                                                      '',
                                                  style: TextStyle(
                                                    color:
                                                        ColorConstants
                                                            .successGreen,
                                                    fontSize: MySize.getHeight(
                                                      14,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    controller
                                                        .selectedTable
                                                        .value = null;
                                                  },
                                                  child: Text(
                                                    TranslationKeys.remove.tr,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          MySize.getHeight(13),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (controller.isTableExpanded.value)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: MySize.getWidth(12),
                                              right: MySize.getWidth(12),
                                              top: MySize.getHeight(6),
                                            ),
                                            child: Obx(() {
                                              if (controller
                                                  .tableAreasList
                                                  .isEmpty) {
                                                return Center(
                                                  child: Text(
                                                    TranslationKeys
                                                        .noTablesAvailable
                                                        .tr,
                                                    style: TextStyle(
                                                      color:
                                                          ColorConstants
                                                              .grey9E9E9E,
                                                      fontSize:
                                                          MySize.getHeight(13),
                                                    ),
                                                  ),
                                                );
                                              }
                                              final allTables =
                                                  controller.tableAreasList
                                                      .expand(
                                                        (area) =>
                                                            area.tables
                                                                ?.where(
                                                                  (table) =>
                                                                      table.availableStatus
                                                                              ?.toLowerCase() ==
                                                                          'available' &&
                                                                      table.status
                                                                              ?.toLowerCase() ==
                                                                          'active',
                                                                )
                                                                .toList() ??
                                                            [],
                                                      )
                                                      .toList();
                                              if (allTables.isEmpty) {
                                                return Center(
                                                  child: Text(
                                                    TranslationKeys
                                                        .noAvailableTables
                                                        .tr,
                                                    style: TextStyle(
                                                      color:
                                                          ColorConstants
                                                              .grey9E9E9E,
                                                      fontSize:
                                                          MySize.getHeight(13),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return GridView.builder(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.only(
                                                  bottom: MySize.getHeight(15),
                                                ),
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing:
                                                          MySize.getWidth(10),
                                                      mainAxisSpacing:
                                                          MySize.getHeight(10),
                                                      childAspectRatio: 1.4,
                                                    ),
                                                itemCount: allTables.length,
                                                itemBuilder: (context, index) {
                                                  final table =
                                                      allTables[index];
                                                  final isSelected =
                                                      controller
                                                          .selectedTable
                                                          .value
                                                          ?.id ==
                                                      table.id;
                                                  return InkWell(
                                                    onTap: () {
                                                      controller
                                                          .selectedTable
                                                          .value = table;
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isSelected
                                                                ? ColorConstants
                                                                    .successGreen
                                                                    .withValues(
                                                                      alpha:
                                                                          0.1,
                                                                    )
                                                                : Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              MySize.getHeight(
                                                                8,
                                                              ),
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              isSelected
                                                                  ? ColorConstants
                                                                      .successGreen
                                                                  : ColorConstants
                                                                      .grey9E9E9E,
                                                          width:
                                                              isSelected
                                                                  ? 2
                                                                  : 1,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            table.tableCode ??
                                                                '${table.id}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize:
                                                                  MySize.getHeight(
                                                                    14,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                MySize.getHeight(
                                                                  2,
                                                                ),
                                                          ),
                                                          Text(
                                                            '${table.seatingCapacity ?? 0} Seat(s)',
                                                            style: TextStyle(
                                                              color:
                                                                  ColorConstants
                                                                      .grey9E9E9E,
                                                              fontSize:
                                                                  MySize.getHeight(
                                                                    11,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: MySize.getHeight(15)),
                                _buildStatusSelection(controller),
                                SizedBox(height: MySize.getHeight(10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${TranslationKeys.customerName.tr} *",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MySize.getHeight(12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: MySize.getHeight(8)),
                                    CupertinoTextField(
                                      controller:
                                          controller.customerNameController,
                                      placeholder: TranslationKeys.enterName.tr,
                                      decoration: BoxDecoration(
                                        color: ColorConstants.bgColor,
                                        borderRadius: BorderRadius.circular(
                                          MySize.getHeight(8),
                                        ),
                                        border: Border.all(
                                          color: ColorConstants.grey9E9E9E,
                                          width: 1,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MySize.getWidth(8),
                                        vertical: MySize.getHeight(12),
                                      ),
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(14),
                                        color: Colors.black,
                                      ),
                                      placeholderStyle: TextStyle(
                                        color: ColorConstants.grey600,
                                        fontSize: MySize.getHeight(14),
                                      ),
                                    ),
                                    SizedBox(height: MySize.getHeight(10)),
                                    Text(
                                      "${TranslationKeys.customerPhone.tr} *",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MySize.getHeight(12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: MySize.getHeight(8)),
                                    CupertinoTextField(
                                      controller:
                                          controller.customerPhoneController,
                                      prefix: _buildCountryPicker(context),
                                      placeholder:
                                          TranslationKeys.enterPhoneNumber.tr,
                                      keyboardType: TextInputType.phone,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: BoxDecoration(
                                        color: ColorConstants.bgColor,
                                        borderRadius: BorderRadius.circular(
                                          MySize.getHeight(8),
                                        ),
                                        border: Border.all(
                                          color: ColorConstants.grey9E9E9E,
                                          width: 1,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MySize.getWidth(8),
                                        vertical: MySize.getHeight(12),
                                      ),
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(14),
                                        color: Colors.black,
                                      ),
                                      placeholderStyle: TextStyle(
                                        color: ColorConstants.grey600,
                                        fontSize: MySize.getHeight(14),
                                      ),
                                      onChanged: (value) {
                                        controller.validatePhone(value);
                                      },
                                    ),
                                    SizedBox(height: MySize.getHeight(10)),
                                    Text(
                                      TranslationKeys.customerEmail.tr,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MySize.getHeight(12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: MySize.getHeight(8)),
                                    CupertinoTextField(
                                      controller:
                                          controller.customerEmailController,
                                      placeholder:
                                          TranslationKeys.enterCustomerEmail.tr,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: BoxDecoration(
                                        color: ColorConstants.bgColor,
                                        borderRadius: BorderRadius.circular(
                                          MySize.getHeight(8),
                                        ),
                                        border: Border.all(
                                          color: ColorConstants.grey9E9E9E,
                                          width: 1,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MySize.getWidth(8),
                                        vertical: MySize.getHeight(12),
                                      ),
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(14),
                                        color: Colors.black,
                                      ),
                                      placeholderStyle: TextStyle(
                                        color: ColorConstants.grey600,
                                        fontSize: MySize.getHeight(14),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MySize.getHeight(20)),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: MySize.getWidth(8),
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
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MySize.getWidth(16),
                                            vertical: MySize.getHeight(8),
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              MySize.getHeight(8),
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
                                              fontSize: MySize.getHeight(14),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MySize.getWidth(16),
                                          vertical: MySize.getHeight(8),
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorConstants.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            MySize.getHeight(8),
                                          ),
                                        ),
                                        child: Text(
                                          TranslationKeys.reserveNow.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MySize.getHeight(14),
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
          ),
    );
  }

  Widget _buildSelectPersonDropdown(ReservationScreenController controller) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(MySize.getHeight(4)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MySize.getHeight(8)),
          ),
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
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(12),
                vertical: MySize.getHeight(10),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(MySize.getHeight(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _translatePersonOption(controller.selectedPerson.value),
                    style: TextStyle(fontSize: MySize.getHeight(14)),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: MySize.getHeight(16)),
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

  Widget _buildTimeSlotsGrid(
    BuildContext context,
    List<String> timeSlots,
    ReservationScreenController controller,
  ) {
    if (timeSlots.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemsPerRow = 4;
        final spacing = MySize.getWidth(6);
        final availableWidth = constraints.maxWidth;
        final itemWidth =
            (availableWidth - (spacing * (itemsPerRow - 1))) / itemsPerRow;

        final rows = <Widget>[];
        for (int i = 0; i < timeSlots.length; i += itemsPerRow) {
          final rowItems = <Widget>[];
          for (int j = 0; j < itemsPerRow && i + j < timeSlots.length; j++) {
            if (j > 0) rowItems.add(SizedBox(width: spacing));
            rowItems.add(
              SizedBox(
                width: itemWidth,
                child: GestureDetector(
                  onTap:
                      () =>
                          controller.selectedTimeSlot.value = timeSlots[i + j],
                  child: Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.getWidth(2),
                        vertical: MySize.getHeight(8),
                      ),
                      decoration: BoxDecoration(
                        color:
                            controller.selectedTimeSlot.value ==
                                    timeSlots[i + j]
                                ? ColorConstants.primaryColor.withValues(
                                  alpha: 0.1,
                                )
                                : Colors.white,
                        border: Border.all(
                          color:
                              controller.selectedTimeSlot.value ==
                                      timeSlots[i + j]
                                  ? ColorConstants.primaryColor
                                  : ColorConstants.grey9E9E9E,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(8),
                        ),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            timeSlots[i + j],
                            style: TextStyle(
                              fontSize: MySize.getHeight(11),
                              color:
                                  controller.selectedTimeSlot.value ==
                                          timeSlots[i + j]
                                      ? ColorConstants.primaryColor
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: MySize.getHeight(6)),
              child: Row(children: rowItems),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }

  Widget _buildAddDatePicker(
    BuildContext context,
    ReservationScreenController controller,
  ) {
    return GestureDetector(
      onTap: () async {
        final today = DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate:
              controller.selectedDate.value.isBefore(today)
                  ? today
                  : controller.selectedDate.value,
          firstDate: DateTime(today.year, today.month, today.day),
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
          padding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(6),
            vertical: MySize.getHeight(10),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: ColorConstants.grey9E9E9E, width: 1),
            borderRadius: BorderRadius.circular(MySize.getHeight(8)),
          ),
          child: Row(
            children: [
              Icon(Icons.date_range_rounded, size: MySize.getHeight(14)),
              SizedBox(width: MySize.getWidth(4)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    controller.formattedDateReservation,
                    style: TextStyle(fontSize: MySize.getHeight(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
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
                GestureDetector(
                  onTap:
                      () =>
                          _showAvailableTablesBottomSheet(context, controller),
                  child: Container(
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
                    elevation: WidgetStateProperty.all(MySize.getHeight(4)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(8),
                        ),
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

  Widget _buildCountryPicker(BuildContext context) {
    return InkWell(
      onTap: () => _showCountrySelectionSheet(context),
      child: Center(
        child: Container(
          padding: EdgeInsets.only(
            left: MySize.getWidth(4),
            right: MySize.getWidth(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(
                () => Text(
                  controller.selectedCountryFlag.value,
                  style: TextStyle(fontSize: MySize.getHeight(16)),
                ),
              ),
              SizedBox(width: MySize.getWidth(4)),
              Obx(
                () => Text(
                  controller.selectedCountryCode.value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MySize.getHeight(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: ColorConstants.grey9E9E9E,
                size: MySize.getHeight(18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountrySelectionSheet(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(MySize.getHeight(20)),
          topRight: Radius.circular(MySize.getHeight(20)),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: ColorConstants.grey9E9E9E.withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        controller.selectedCountryCode.value = '+${country.phoneCode}';
        controller.selectedCountryFlag.value = country.flagEmoji;
      },
    );
  }

  Widget _buildStatusSelection(ReservationScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.status.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: MySize.getHeight(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MySize.getHeight(8)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                controller.statusOptions.map((status) {
                  return Obx(() {
                    final isSelected =
                        controller.selectedReservationStatus.value == status;
                    return GestureDetector(
                      onTap: () => controller.selectReservationStatus(status),
                      child: Container(
                        margin: EdgeInsets.only(right: MySize.getWidth(8)),
                        padding: EdgeInsets.symmetric(
                          horizontal: MySize.getWidth(16),
                          vertical: MySize.getHeight(8),
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? controller.getStatusBgColor(status)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(20),
                          ),
                          border: Border.all(
                            color:
                                isSelected
                                    ? controller.getStatusBorderColor(status)
                                    : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status.tr,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? controller.getStatusColor(status)
                                    : Colors.black54,
                            fontSize: MySize.getHeight(13),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAvailableTablesBottomSheet(
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
          (bottomSheetContext) => DraggableScrollableSheet(
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
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TranslationKeys.availableTables.tr,
                              style: TextStyle(
                                fontSize: MySize.getHeight(18),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.close,
                                size: MySize.getHeight(24),
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          if (controller.tableAreasList.isEmpty) {
                            return Center(
                              child: Text(
                                TranslationKeys.noTablesAvailable.tr,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: MySize.getHeight(14),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.tableAreasList.length,
                            itemBuilder: (context, areaIndex) {
                              final area = controller.tableAreasList[areaIndex];
                              final availableTables =
                                  area.tables
                                      ?.where(
                                        (table) =>
                                            table.availableStatus
                                                    ?.toLowerCase() ==
                                                'available' &&
                                            table.status?.toLowerCase() ==
                                                'active',
                                      )
                                      .toList() ??
                                  [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      area.name ??
                                          TranslationKeys.unnamedArea.tr,
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(16),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (availableTables.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: Text(
                                        TranslationKeys.noAvailableTables.tr,
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(12),
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    )
                                  else
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: 1.2,
                                          ),
                                      itemCount: availableTables.length,
                                      itemBuilder:
                                          (context, tableIndex) =>
                                              _buildTableItem(
                                                availableTables[tableIndex],
                                                controller,
                                              ),
                                    ),
                                  SizedBox(height: MySize.getHeight(20)),
                                ],
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildTableItem(
    tableModel.Tables table,
    ReservationScreenController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedTable.value?.id == table.id;
      return GestureDetector(
        onTap: () {
          controller.selectedTable.value = table;
          Get.back();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected
                      ? ColorConstants.primaryColor
                      : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: ColorConstants.primaryColor.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.tableGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  table.tableCode ?? '${table.id}',
                  style: TextStyle(
                    fontSize: MySize.getHeight(12),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: MySize.getHeight(4)),
              Text(
                '${table.seatingCapacity ?? 0} Seat(s)',
                style: TextStyle(
                  fontSize: MySize.getHeight(10),
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
