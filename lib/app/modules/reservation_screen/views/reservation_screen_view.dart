import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:country_picker/country_picker.dart';
import 'package:managerapp/app/widgets/access_limited_dialog.dart';
import 'package:managerapp/app/widgets/customer_search_fields_widget.dart';
import 'package:managerapp/app/widgets/time_slot_grid_widget.dart';

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
                        child: Padding(
                          padding: EdgeInsets.all(MySize.getHeight(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(MySize.getHeight(5)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    MySize.getHeight(12),
                                  ),
                                  boxShadow: ColorConstants.getShadow2,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
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
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              MySize.getWidth(
                                                                5,
                                                              ),
                                                          vertical:
                                                              MySize.getHeight(
                                                                6,
                                                              ),
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            _translateDateOption(
                                                              controller
                                                                  .getDropdownDisplayText(),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  MySize.getHeight(
                                                                    13,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          size:
                                                              MySize.getHeight(
                                                                20,
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
                                                      controller
                                                          .updateDateOption(
                                                            option,
                                                          );
                                                      if (option ==
                                                          'Custom Date') {
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
                                                      _translateDateOption(
                                                        option,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize:
                                                            MySize.getHeight(
                                                              13,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                        SizedBox(width: MySize.getWidth(4)),
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
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              MySize.getWidth(
                                                                6,
                                                              ),
                                                          vertical:
                                                              MySize.getHeight(
                                                                6,
                                                              ),
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            _translateOrderFilter(
                                                              controller
                                                                  .selectedOrderFilter
                                                                  .value,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  MySize.getHeight(
                                                                    13,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          size:
                                                              MySize.getHeight(
                                                                20,
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
                                                      _translateOrderFilter(
                                                        option,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize:
                                                            MySize.getHeight(
                                                              13,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: MySize.getHeight(12)),
                              Expanded(
                                child: Obx(() {
                                  if (controller.isReservationsLoading.value &&
                                      controller.reservations.isEmpty) {
                                    return Center(
                                      child: CupertinoActivityIndicator(
                                        radius: MySize.getHeight(8),
                                        color: ColorConstants.primaryColor,
                                      ),
                                    );
                                  }
                                  return _buildReservationList(
                                    controller,
                                    context,
                                  );
                                }),
                              ),
                            ],
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

  Widget _buildReservationList(
    ReservationScreenController controller,
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      color: ColorConstants.primaryColor,
      child: Obx(() {
        if (controller.reservations.isEmpty &&
            !controller.isReservationsLoading.value) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MySize.getHeight(400),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade400,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        ImageConstant.noReservation,
                        width: MySize.getWidth(120),
                        height: MySize.getHeight(120),
                      ),
                    ),
                    Text(
                      TranslationKeys.noReservationsFound.tr,
                      style: TextStyle(
                        fontSize: MySize.getHeight(17),
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          controller: controller.reservationsScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount:
              controller.reservations.length +
              (controller.isReservationsLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: MySize.getHeight(4)),
          itemBuilder: (context, index) {
            if (index == controller.reservations.length) {
              return Padding(
                padding: EdgeInsets.all(MySize.getWidth(16)),
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: MySize.getHeight(8),
                    color: ColorConstants.primaryColor,
                  ),
                ),
              );
            }
            return _buildReservationCard(context, controller, index);
          },
        );
      }),
    );
  }

  void _showReservationBottomSheet(
    BuildContext context,
    ReservationScreenController controller, {
    int? editIndex,
  }) {
    void scrollToField(GlobalKey key) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = key.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: 0.25,
          );
        }
      });
    }

    if (editIndex != null) {
      controller.prefillForEdit(editIndex);
    } else {
      controller.clearForm();
    }
    controller.fetchAvailableTimeSlots();
    controller.onReservationNameFocusGained =
        () => scrollToField(controller.reservationNameFieldKey);
    controller.onReservationPhoneFocusGained =
        () => scrollToField(controller.reservationPhoneFieldKey);
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
      builder: (modalContext) {
        final keyboardHeight = MediaQuery.of(modalContext).viewInsets.bottom;
        const double kDoneBarHeight = 44.0;
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: keyboardHeight > 0 ? kDoneBarHeight : 0,
                ),
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.85,
                  maxChildSize: 0.9,
                  minChildSize: 0.5,
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
                          controller: scrollController,
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
                                      style: _sectionTitleStyle(),
                                    ),
                                    SizedBox(height: MySize.getHeight(4)),
                                    Obx(() => _buildTimeSlotsContent(context, controller)),
                                    SizedBox(height: MySize.getHeight(4)),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          controller:
                                              controller.specialRequestController,
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
                                                controller
                                                    .isTableExpanded
                                                    .value = !controller
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
                                                          ? Icons
                                                              .keyboard_arrow_up
                                                          : Icons
                                                              .keyboard_arrow_down,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (controller
                                                    .selectedTable
                                                    .value !=
                                                null)
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: MySize.getWidth(12),
                                                  right: MySize.getWidth(12),
                                                  bottom: MySize.getHeight(12),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: MySize.getWidth(
                                                    12,
                                                  ),
                                                  vertical: MySize.getHeight(8),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: ColorConstants
                                                      .successGreen
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
                                                        fontSize:
                                                            MySize.getHeight(
                                                              14,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        controller
                                                            .selectedTable
                                                            .value = null;
                                                      },
                                                      child: Text(
                                                        TranslationKeys
                                                            .remove
                                                            .tr,
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize:
                                                              MySize.getHeight(
                                                                13,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (controller
                                                .isTableExpanded
                                                .value)
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
                                                              MySize.getHeight(
                                                                13,
                                                              ),
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
                                                                          table.availableStatus?.toLowerCase() ==
                                                                              'available' &&
                                                                          table.status?.toLowerCase() ==
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
                                                              MySize.getHeight(
                                                                13,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return GridView.builder(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.only(
                                                      bottom: MySize.getHeight(
                                                        15,
                                                      ),
                                                    ),
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing:
                                                              MySize.getWidth(
                                                                10,
                                                              ),
                                                          mainAxisSpacing:
                                                              MySize.getHeight(
                                                                10,
                                                              ),
                                                          childAspectRatio: 1.4,
                                                        ),
                                                    itemCount: allTables.length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
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
                                                                    : Colors
                                                                        .white,
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
                                                                      Colors
                                                                          .black,
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
                                    CustomerSearchFieldsWidget(
                                      controller: controller,
                                      onShowCountryPicker: () =>
                                          _showCountrySelectionSheet(context),
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      MySize.getHeight(8),
                                                    ),
                                                border: Border.all(
                                                  color:
                                                      ColorConstants.grey9E9E9E,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                TranslationKeys.cancel.tr,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: MySize.getHeight(
                                                    14,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Obx(() => InkWell(
                                            onTap: controller.isSavingReservation.value
                                                ? null
                                                : () => controller.saveReservation(),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: MySize.getWidth(16),
                                                vertical: MySize.getHeight(8),
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    controller.isSavingReservation.value
                                                        ? ColorConstants.primaryColor.withOpacity(0.6)
                                                        : ColorConstants.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      MySize.getHeight(8),
                                                    ),
                                              ),
                                              child: controller.isSavingReservation.value
                                                  ? SizedBox(
                                                      width: MySize.getHeight(20),
                                                      height: MySize.getHeight(20),
                                                      child: const CupertinoActivityIndicator(
                                                        radius: 9,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Obx(
                                                      () => Text(
                                                        controller.isEditingReservation
                                                            ? 'Update Reservation'
                                                            : TranslationKeys.reserveNow.tr,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: MySize.getHeight(14),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: MySize.getHeight(20)),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
              ),
              if (keyboardHeight > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    height: kDoneBarHeight,
                    color: CupertinoColors.systemGrey6,
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(16),
                      vertical: MySize.getHeight(8),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: ColorConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: MySize.getHeight(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ).then((_) {
      controller.onReservationNameFocusGained = null;
      controller.onReservationPhoneFocusGained = null;
    });
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

  static TextStyle _sectionTitleStyle() => TextStyle(
        color: Colors.black,
        fontSize: MySize.getHeight(14),
        fontWeight: FontWeight.w600,
      );

  Widget _buildTimeSlotsContent(
    BuildContext context,
    ReservationScreenController controller,
  ) {
    if (controller.isTimeSlotsLoading.value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: MySize.getHeight(16)),
        child: const Center(child: CupertinoActivityIndicator(radius: 12)),
      );
    }
    if (controller.isTimeSlotsClosed.value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: MySize.getHeight(12)),
        child: Text(
          'Closed',
          style: TextStyle(
            color: ColorConstants.grey9E9E9E,
            fontSize: MySize.getHeight(14),
          ),
        ),
      );
    }
    if (controller.timeSlotSections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: controller.timeSlotSections.map((section) {
        return Padding(
          padding: EdgeInsets.only(bottom: MySize.getHeight(16)),
          child: TimeSlotSectionWidget(
            sectionTitle: section.title,
            timeSlots: section.slots,
            selectedSectionTitle: controller.selectedTimeSlotTitle.value,
            selectedTimeSlot: controller.selectedTimeSlot.value,
            onSlotSelected: controller.selectTimeSlot,
            checkingSectionTitle: controller.checkingSlotSectionTitle.value.isEmpty
                ? null
                : controller.checkingSlotSectionTitle.value,
            checkingSlot: controller.checkingSlotValue.value.isEmpty
                ? null
                : controller.checkingSlotValue.value,
            titleStyle: _sectionTitleStyle(),
          ),
        );
      }).toList(),
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
          controller.fetchAvailableTimeSlots();
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
        margin: EdgeInsets.only(bottom: MySize.getHeight(4)),
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
                if (_hasNote(item)) ...[
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
                ] else
                  const Spacer(),
                GestureDetector(
                  onTap:
                      () => _showAvailableTablesBottomSheet(
                        context,
                        controller,
                        index,
                      ),
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
                    return Obx(() {
                      final isUpdating =
                          controller.statusUpdatingReservationIndex.value ==
                          index;
                      return GestureDetector(
                        onTap: () {
                          if (isUpdating) return;
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isUpdating)
                                SizedBox(
                                  width: MySize.getHeight(18),
                                  height: MySize.getHeight(18),
                                  child: CupertinoActivityIndicator(
                                    radius: MySize.getHeight(8),
                                    color: ColorConstants.primaryColor,
                                  ),
                                )
                              else ...[
                                Text(
                                  _translateStatus(item['status']),
                                  style: TextStyle(
                                    fontSize: MySize.getHeight(12),
                                  ),
                                ),
                                SizedBox(width: MySize.getWidth(4)),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: MySize.getHeight(18),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    });
                  },
                  menuChildren:
                      controller.statusOptions.map((status) {
                        return MenuItemButton(
                          onPressed:
                              () => controller.updateReservationStatus(
                                index,
                                status,
                              ),
                          child: Text(
                            _translateStatus(status),
                            style: TextStyle(fontSize: MySize.getHeight(12)),
                          ),
                        );
                      }).toList(),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      _showReservationBottomSheet(context, controller, editIndex: index),
                  child: Container(
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
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  bool _hasNote(Map<String, dynamic> item) {
    final note = item['note'];
    return note != null && note.toString().trim().isNotEmpty;
  }

  String _translateDateOption(String option) {
    switch (option) {
      case 'Today':
        return TranslationKeys.today.tr;
      case 'Current Week':
        return TranslationKeys.currentWeek.tr;
      case 'Last Week':
        return TranslationKeys.lastWeek.tr;
      case 'Last 7 Days':
        return TranslationKeys.last7Days.tr;
      case 'Current Month':
        return TranslationKeys.currentMonth.tr;
      case 'Last Month':
        return TranslationKeys.lastMonth.tr;
      case 'Current Year':
        return TranslationKeys.currentYear.tr;
      case 'Last Year':
        return TranslationKeys.lastYear.tr;
      case 'Custom Date':
        return TranslationKeys.customDate.tr;
      default:
        return option;
    }
  }

  String _translateOrderFilter(String option) {
    switch (option) {
      case 'All':
        return TranslationKeys.all.tr;
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
                controller.reservationFormStatusOptions.map((status) {
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
    int reservationIndex,
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
                                                reservationIndex,
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
    int reservationIndex,
  ) {
    return Obx(() {
      final assignedTable =
          controller.reservations.length > reservationIndex
              ? (controller.reservations[reservationIndex]['table'] ??
                  controller.reservations[reservationIndex]['tableCode'])
              : null;
      final isSelected =
          assignedTable != null && assignedTable == table.tableCode;
      return GestureDetector(
        onTap: () {
          controller.assignTableToReservationAt(reservationIndex, table);
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
