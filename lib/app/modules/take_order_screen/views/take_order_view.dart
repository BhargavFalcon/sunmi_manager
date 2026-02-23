import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/model/menu_items_model.dart';
import 'package:managerapp/app/modules/take_order_screen/controllers/take_order_controller.dart';
import 'package:managerapp/app/modules/cart_screen/controllers/cart_screen_controller.dart';
import 'package:managerapp/app/widgets/access_limited_dialog.dart';
import 'package:managerapp/app/widgets/add_customer_dialog.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';
import 'package:managerapp/app/widgets/pre_order_datetime_picker.dart';

class TakeOrderView extends GetWidget<TakeOrderController> {
  const TakeOrderView({super.key});

  static void openCustomerDialog(TakeOrderController controller) {
    Get.dialog(
      AddCustomerDialog(
        initialName: controller.customerName.value,
        initialPhone: controller.customerPhone.value,
        initialEmail: controller.customerEmail.value,
        initialPhoneCode: controller.customerPhoneCode.value,
        initialZipcode: controller.customerZipcode.value,
        initialHouseNumber: controller.customerHouseNumber.value,
        initialAddress: controller.customerAddress.value,
        isDelivery: controller.selectedOrderType.value == 'Delivery',
        zipcodeList: controller.zipcodeList.toList(),
        onCustomerSelected: (customer) {
          if (customer.id != null && Get.isRegistered<TakeOrderController>()) {
            Get.find<TakeOrderController>().selectedCustomerId.value =
                customer.id;
          }
        },
        onSave: ({
          required name,
          required phone,
          required email,
          required phoneCode,
          zipcode,
          houseNumber,
          address,
          customerId,
        }) {
          controller.updateCustomerDetails(
            name: name,
            phone: phone,
            email: email,
            phoneCode: phoneCode,
            zipcode: zipcode,
            houseNumber: houseNumber,
            address: address,
            customerId: customerId,
          );
        },
      ),
    );
  }

  CartScreenController? _getCartController() {
    if (Get.isRegistered<CartScreenController>()) {
      return Get.find<CartScreenController>();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    return GetBuilder<TakeOrderController>(
      init: TakeOrderController(),
      assignId: true,
      builder: (controller) {
        final cartController = _getCartController();

        return PopScope<Object?>(
          canPop: cartController == null || cartController.cartItems.isEmpty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop &&
                cartController != null &&
                cartController.cartItems.isNotEmpty) {
              _showCancelOrderDialog(context, cartController);
            }
          },
          child: Scaffold(
            backgroundColor: ColorConstants.bgColor,
            body: Stack(
              children: [
                Obx(
                  () => IgnorePointer(
                    ignoring: controller.showAccessDialog.value,
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top),
                        _buildSearchAndCategoryBox(
                          context,
                          controller,
                          categoryController:
                              controller.categoryScrollController,
                        ),
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return Center(
                                child: Container(
                                  width: MySize.getWidth(60),
                                  height: MySize.getHeight(60),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      MySize.getHeight(8),
                                    ),
                                    boxShadow: ColorConstants.getShadow2,
                                  ),
                                  child: Center(
                                    child: CupertinoActivityIndicator(
                                      radius: MySize.getHeight(12),
                                      color: ColorConstants.primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Obx(() {
                              final selectedCat =
                                  controller.selectedCategory.value;
                              final filteredItems =
                                  controller.filteredGroupedItems;
                              final items = filteredItems[selectedCat] ?? [];

                              if (items.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      MySize.getWidth(16),
                                    ),
                                    child: Text(
                                      TranslationKeys.noItemsFound.tr,
                                      style: TextStyle(
                                        fontSize: MySize.getHeight(14),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ..._buildItemsInRows(
                                      context,
                                      controller,
                                      items,
                                    ),
                                    SizedBox(height: MySize.getHeight(16)),
                                  ],
                                ),
                              );
                            });
                          }),
                        ),
                        Obx(() {
                          final cartCount = controller.cartItemsCount.value;
                          if (cartCount == 0) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(4),
                              vertical: MySize.getHeight(6),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: MySize.getHeight(4),
                                  offset: Offset(0, -MySize.getHeight(2)),
                                ),
                              ],
                            ),
                            child: SafeArea(
                              top: false,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _showClearCartDialog(
                                          context,
                                          _getCartController(),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: MySize.getHeight(12),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF60616E),
                                          borderRadius: BorderRadius.circular(
                                            MySize.getHeight(30),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          TranslationKeys.clearCart.tr
                                              .replaceAll('?', ''),
                                          style: TextStyle(
                                            fontSize: MySize.getHeight(14),
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MySize.getWidth(8)),
                                  Expanded(
                                    child: InkWell(
                                      onTap: controller.navigateToCart,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: MySize.getHeight(12),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF0B9F6E),
                                          borderRadius: BorderRadius.circular(
                                            MySize.getHeight(30),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Next ($cartCount)',
                                          style: TextStyle(
                                            fontSize: MySize.getHeight(14),
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Obx(() {
                  if (controller.showAccessDialog.value) {
                    return const AccessLimitedDialog();
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndCategoryBox(
    BuildContext context,
    TakeOrderController controller, {
    ScrollController? categoryController,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isLandscape = screenWidth > screenHeight;
          final isTablet = screenWidth >= 600;

          return Column(
            children: [
              if (!controller.hasTable)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    MySize.getWidth(8),
                    MySize.getHeight(12),
                    MySize.getWidth(8),
                    isTablet && isLandscape
                        ? MySize.getHeight(8)
                        : MySize.getHeight(2),
                  ),
                  child:
                      isTablet && isLandscape
                          ? Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Obx(() {
                                  final selectedType =
                                      controller.selectedOrderType.value;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        MySize.getHeight(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        MySize.getWidth(2),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: _buildOrderTypeButton(
                                              context: context,
                                              icon: ImageConstant.delivery,
                                              label:
                                                  TranslationKeys.delivery.tr,
                                              isSelected:
                                                  selectedType == 'Delivery',
                                              onTap:
                                                  () => controller
                                                      .updateOrderType(
                                                        'Delivery',
                                                      ),
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildOrderTypeButton(
                                              context: context,
                                              icon: ImageConstant.pickup,
                                              label: TranslationKeys.pickup.tr,
                                              isSelected:
                                                  selectedType == 'Pickup',
                                              onTap:
                                                  () => controller
                                                      .updateOrderType(
                                                        'Pickup',
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(width: MySize.getWidth(6)),
                              Obx(() {
                                final isSelected =
                                    controller.selectedPreOrderDate.value !=
                                    null;
                                String label =
                                    isSelected
                                        ? TranslationKeys.resetPreOrder.tr
                                        : TranslationKeys.preOrder.tr;

                                return _buildActionButton(
                                  icon:
                                      isSelected
                                          ? Icons.restart_alt
                                          : Icons.access_time,
                                  label: label,
                                  onTap: () {
                                    if (isSelected) {
                                      controller.updatePreOrderDateTime(
                                        null,
                                        null,
                                      );
                                    } else {
                                      Get.dialog(
                                        PreOrderDateTimePicker(
                                          initialDate:
                                              controller
                                                  .selectedPreOrderDate
                                                  .value,
                                          initialTime:
                                              controller
                                                  .selectedPreOrderTime
                                                  .value,
                                          onSave: (date, time) {
                                            controller.updatePreOrderDateTime(
                                              date,
                                              time,
                                            );
                                          },
                                          onReset: () {
                                            controller.updatePreOrderDateTime(
                                              null,
                                              null,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                );
                              }),
                              SizedBox(width: MySize.getWidth(6)),
                              Obx(
                                () => _buildActionButton(
                                  icon: Icons.person,
                                  label:
                                      controller.hasCustomer
                                          ? controller.customerName.value
                                          : TranslationKeys.customer.tr,
                                  onTap:
                                      () => TakeOrderView.openCustomerDialog(
                                        controller,
                                      ),
                                ),
                              ),
                              SizedBox(width: MySize.getWidth(8)),
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: MySize.getHeight(40),
                                  child: CupertinoTextField(
                                    controller: controller.searchController,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: MySize.getWidth(2),
                                      vertical: MySize.getHeight(2),
                                    ),
                                    placeholder:
                                        TranslationKeys.searchMenuItems.tr,
                                    placeholderStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: MySize.getHeight(12),
                                    ),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: MySize.getHeight(12),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        MySize.getHeight(8),
                                      ),
                                    ),
                                    prefix: Padding(
                                      padding: EdgeInsets.only(
                                        left: MySize.getWidth(4),
                                        right: MySize.getWidth(4),
                                        top: MySize.getHeight(11),
                                        bottom: MySize.getHeight(11),
                                      ),
                                      child: Icon(
                                        Icons.search,
                                        size: MySize.getHeight(18),
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    clearButtonMode:
                                        OverlayVisibilityMode.editing,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  final selectedType =
                                      controller.selectedOrderType.value;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        MySize.getHeight(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        MySize.getWidth(2),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: _buildOrderTypeButton(
                                              context: context,
                                              icon: ImageConstant.delivery,
                                              label:
                                                  TranslationKeys.delivery.tr,
                                              isSelected:
                                                  selectedType == 'Delivery',
                                              onTap:
                                                  () => controller
                                                      .updateOrderType(
                                                        'Delivery',
                                                      ),
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildOrderTypeButton(
                                              context: context,
                                              icon: ImageConstant.pickup,
                                              label: TranslationKeys.pickup.tr,
                                              isSelected:
                                                  selectedType == 'Pickup',
                                              onTap:
                                                  () => controller
                                                      .updateOrderType(
                                                        'Pickup',
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(width: MySize.getWidth(4)),
                              Obx(() {
                                final isSelected =
                                    controller.selectedPreOrderDate.value !=
                                    null;
                                String label =
                                    isSelected
                                        ? TranslationKeys.resetPreOrder.tr
                                        : TranslationKeys.preOrder.tr;

                                return _buildActionButton(
                                  icon:
                                      isSelected
                                          ? Icons.restart_alt
                                          : Icons.access_time,
                                  label: label,
                                  onTap: () {
                                    if (isSelected) {
                                      controller.updatePreOrderDateTime(
                                        null,
                                        null,
                                      );
                                    } else {
                                      Get.dialog(
                                        PreOrderDateTimePicker(
                                          initialDate:
                                              controller
                                                  .selectedPreOrderDate
                                                  .value,
                                          initialTime:
                                              controller
                                                  .selectedPreOrderTime
                                                  .value,
                                          onSave: (date, time) {
                                            controller.updatePreOrderDateTime(
                                              date,
                                              time,
                                            );
                                          },
                                          onReset: () {
                                            controller.updatePreOrderDateTime(
                                              null,
                                              null,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                );
                              }),
                              SizedBox(width: MySize.getWidth(6)),
                              Obx(
                                () => _buildActionButton(
                                  icon: Icons.person,
                                  label:
                                      controller.hasCustomer
                                          ? controller.customerName.value
                                          : TranslationKeys.customer.tr,
                                  onTap:
                                      () => TakeOrderView.openCustomerDialog(
                                        controller,
                                      ),
                                ),
                              ),
                            ],
                          ),
                ),
              if (isTablet && isLandscape)
                Container(
                  height: MySize.getHeight(38),
                  padding: EdgeInsets.only(bottom: MySize.getHeight(4)),
                  child: Obx(() {
                    final visibleCategories =
                        controller.categories
                            .where(
                              (cat) => controller.filteredGroupedItems
                                  .containsKey(cat),
                            )
                            .toList();
                    return ListView.builder(
                      controller:
                          categoryController ??
                          controller.categoryScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(
                        left: MySize.getWidth(8),
                        right: MySize.getWidth(4),
                      ),
                      itemCount: visibleCategories.length,
                      itemBuilder: (context, index) {
                        final category = visibleCategories[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedCategory.value == category;
                          return GestureDetector(
                            onTap: () => controller.updateCategory(category),
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: MySize.getWidth(2),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: MySize.getWidth(12),
                                vertical: MySize.getHeight(6),
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? ColorConstants.primaryColor
                                        : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(
                                  MySize.getHeight(20),
                                ),
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: ColorConstants.primaryColor
                                                .withValues(alpha: 0.3),
                                            spreadRadius: 0,
                                            blurRadius: MySize.getHeight(4),
                                            offset: Offset(
                                              0,
                                              MySize.getHeight(2),
                                            ),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: MySize.getHeight(14),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),
              if (!isTablet || !isLandscape)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    MySize.getWidth(8),
                    MySize.getHeight(4),
                    MySize.getWidth(8),
                    MySize.getHeight(8),
                  ),
                  child: Row(
                    children: [
                      if (controller.hasTable)
                        InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            final cartCtrl = _getCartController();
                            final dialogContext = Get.context;
                            if (cartCtrl == null ||
                                cartCtrl.cartItems.isEmpty) {
                              Get.back();
                            } else if (dialogContext != null) {
                              _showCancelOrderDialog(dialogContext, cartCtrl);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: MySize.getHeight(40),
                            width: MySize.getHeight(40),
                            margin: EdgeInsets.only(right: MySize.getWidth(8)),
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(8),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: ColorConstants.primaryColor,
                              size: MySize.getHeight(20),
                            ),
                          ),
                        ),
                      Expanded(
                        child: SizedBox(
                          height: MySize.getHeight(40),
                          child: CupertinoTextField(
                            controller: controller.searchController,
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(2),
                              vertical: MySize.getHeight(2),
                            ),
                            placeholder: TranslationKeys.searchMenuItems.tr,
                            placeholderStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: MySize.getHeight(12),
                            ),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: MySize.getHeight(12),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(8),
                              ),
                            ),
                            prefix: Padding(
                              padding: EdgeInsets.only(
                                left: MySize.getWidth(4),
                                right: MySize.getWidth(4),
                                top: MySize.getHeight(11),
                                bottom: MySize.getHeight(11),
                              ),
                              child: Icon(
                                Icons.search,
                                size: MySize.getHeight(18),
                                color: Colors.grey.shade600,
                              ),
                            ),
                            clearButtonMode: OverlayVisibilityMode.editing,
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isTablet || !isLandscape)
                Container(
                  height: MySize.getHeight(38),
                  padding: EdgeInsets.only(bottom: MySize.getHeight(4)),
                  child: Obx(() {
                    final visibleCategories =
                        controller.categories
                            .where(
                              (cat) => controller.filteredGroupedItems
                                  .containsKey(cat),
                            )
                            .toList();
                    return ListView.builder(
                      controller:
                          categoryController ??
                          controller.categoryScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(
                        left: MySize.getWidth(8),
                        right: MySize.getWidth(4),
                      ),
                      itemCount: visibleCategories.length,
                      itemBuilder: (context, index) {
                        final category = visibleCategories[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedCategory.value == category;
                          return GestureDetector(
                            onTap: () => controller.updateCategory(category),
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: MySize.getWidth(2),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: MySize.getWidth(12),
                                vertical: MySize.getHeight(6),
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? ColorConstants.primaryColor
                                        : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(
                                  MySize.getHeight(20),
                                ),
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: ColorConstants.primaryColor
                                                .withValues(alpha: 0.3),
                                            spreadRadius: 0,
                                            blurRadius: MySize.getHeight(4),
                                            offset: Offset(
                                              0,
                                              MySize.getHeight(2),
                                            ),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: MySize.getHeight(14),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildItemsInRows(
    BuildContext context,
    TakeOrderController controller,
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty) return [];

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isLandscape = screenWidth > MediaQuery.of(context).size.height;
    final itemsPerRow = isTablet ? (isLandscape ? 3 : 2) : 1;
    final padding = MySize.getWidth(8) * 2;
    final spacing = MySize.getWidth(4);
    final itemWidth =
        ((screenWidth - padding - (spacing * (itemsPerRow - 1))) /
            itemsPerRow) -
        0.1;

    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += itemsPerRow) {
      final rowItems = <Widget>[];
      for (int j = 0; j < itemsPerRow && i + j < items.length; j++) {
        if (j > 0) rowItems.add(SizedBox(width: spacing));
        rowItems.add(
          SizedBox(
            width: itemWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MySize.getWidth(2),
                vertical: MySize.getHeight(2),
              ),
              child: _buildItemCell(controller, items[i + j]),
            ),
          ),
        );
      }
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(8),
            vertical: MySize.getHeight(2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowItems,
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildItemCell(
    TakeOrderController controller,
    Map<String, dynamic> item,
  ) {
    final itemObject = item["item"] as Items?;

    return GestureDetector(
      onTap: () {
        if (itemObject != null) {
          controller.showItemVariationsBottomSheet(itemObject);
        }
      },
      child: Container(
        height: MySize.getHeight(77),
        padding: EdgeInsets.all(MySize.getHeight(8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MySize.getHeight(12)),
          boxShadow: ColorConstants.getShadow2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                if (itemObject?.itemNumber != null &&
                    itemObject!.itemNumber!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(6),
                      vertical: MySize.getHeight(2),
                    ),
                    margin: EdgeInsets.only(right: MySize.getWidth(6)),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(MySize.getHeight(4)),
                    ),
                    child: Text(
                      itemObject.itemNumber!,
                      style: TextStyle(
                        fontSize: MySize.getHeight(12),
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    item["product_name"],
                    maxLines: 2,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: MySize.getHeight(14),
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: MySize.getWidth(8)),
                Obx(() {
                  final orderType = controller.selectedOrderType.value;
                  String price = '0';
                  bool hasVariations = false;

                  if (itemObject != null) {
                    hasVariations = itemObject.variations?.isNotEmpty ?? false;

                    if (hasVariations &&
                        (orderType == 'Pickup' || orderType == 'Delivery')) {
                      price = controller.getMinimumVariationPrice(
                        itemObject,
                        orderType,
                      );
                    } else {
                      switch (orderType) {
                        case 'Pickup':
                          price = itemObject.pickupPrice ?? '0';
                          break;
                        case 'Delivery':
                          price = itemObject.deliveryPrice ?? '0';
                          break;
                        case 'Dine In':
                          price = itemObject.dineInPrice ?? '0';
                          break;
                        default:
                          price =
                              itemObject.pickupPrice ??
                              itemObject.deliveryPrice ??
                              '0';
                      }
                    }
                  } else {
                    price = item["amount"] ?? '0';
                  }

                  final formattedPrice = CurrencyFormatter.formatPrice(price);
                  final priceText =
                      hasVariations
                          ? '${TranslationKeys.from.tr} $formattedPrice'
                          : formattedPrice;

                  return Text(
                    priceText,
                    style: TextStyle(
                      fontSize: MySize.getHeight(16),
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
            Divider(
              color: Colors.grey.shade300,
              height: MySize.getHeight(15),
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeButton({
    required BuildContext context,
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MySize.getHeight(4)),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorConstants.primaryColor.withValues(alpha: 0.05)
                  : Colors.transparent,
          border: Border.all(
            color:
                isSelected ? ColorConstants.primaryColor : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: MySize.getHeight(20),
              width: MySize.getWidth(20),
              alignment: Alignment.center,
            ),
            if (isTablet)
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? ColorConstants.primaryColor
                          : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: MySize.getHeight(14),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MySize.getWidth(4),
          vertical: MySize.getHeight(8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: ColorConstants.primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(MySize.getHeight(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: MySize.getHeight(18),
              color: ColorConstants.primaryColor,
            ),
            SizedBox(width: MySize.getWidth(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: MySize.getHeight(12),
                fontWeight: FontWeight.w500,
                color: ColorConstants.primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String text,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: MySize.getHeight(12)),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(MySize.getHeight(8)),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: MySize.getHeight(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
    CartScreenController? controller, {
    bool shouldExit = false,
  }) {
    final cartCtrl = controller ?? _getCartController();
    final title =
        shouldExit
            ? TranslationKeys.cancelOrder.tr
            : TranslationKeys.clearCart.tr;
    final message =
        shouldExit
            ? TranslationKeys.areYouSureExit.tr
            : TranslationKeys.areYouSureClearCart.tr;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MySize.getHeight(12)),
            side: BorderSide(color: ColorConstants.bgColor),
          ),
          child: Padding(
            padding: EdgeInsets.all(MySize.getWidth(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: MySize.getHeight(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: MySize.getHeight(12)),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: MySize.getHeight(12)),
                ),
                SizedBox(height: MySize.getHeight(20)),
                Row(
                  children: [
                    _buildDialogButton(
                      text: TranslationKeys.close.tr,
                      onTap: () => Navigator.of(context).pop(),
                      backgroundColor: Colors.grey.shade200,
                      textColor: Colors.black,
                    ),
                    SizedBox(width: MySize.getWidth(12)),
                    _buildDialogButton(
                      text: TranslationKeys.clearCart.tr.replaceAll('?', ''),
                      onTap: () {
                        cartCtrl?.clearCart();
                        Navigator.of(context).pop();
                        if (shouldExit) Get.back();
                      },
                      backgroundColor: ColorConstants.primaryColor,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelOrderDialog(
    BuildContext context,
    CartScreenController controller,
  ) {
    _showClearCartDialog(context, controller, shouldExit: true);
  }
}
