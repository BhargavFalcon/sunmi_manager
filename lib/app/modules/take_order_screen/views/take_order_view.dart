import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/api_constants.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/model/menuItemsModel.dart';
import 'package:managerapp/app/modules/take_order_screen/controllers/take_order_controller.dart';
import 'package:managerapp/app/modules/cart_screen/controllers/cart_screen_controller.dart';
import 'package:managerapp/app/routes/app_pages.dart';
import 'package:managerapp/app/utils/currency_formatter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TakeOrderView extends GetWidget<TakeOrderController> {
  const TakeOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TakeOrderController>(
      init: TakeOrderController(),
      assignId: true,
      builder: (controller) {
        CartScreenController? cartController;
        if (Get.isRegistered<CartScreenController>()) {
          cartController = Get.find<CartScreenController>();
        }

        return PopScope(
          canPop: cartController == null || cartController.cartItems.isEmpty,
          onPopInvoked: (didPop) {
            if (!didPop &&
                cartController != null &&
                cartController.cartItems.isNotEmpty) {
              _showCancelOrderDialog(context, cartController);
            }
          },
          child: Scaffold(
            backgroundColor: ColorConstants.bgColor,
            body: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.scrollToTop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12).copyWith(
                          top: MediaQuery.of(context).padding.top + 12,
                          bottom: MySize.getHeight(15),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: ColorConstants.getShadow2,
                        ),
                        child: Center(
                          child: Text(
                            TranslationKeys.takeOrder.tr,
                            style: TextStyle(
                              fontSize: MySize.getHeight(16),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (controller.hasTable)
                      Positioned(
                        left: 12,
                        top: MediaQuery.of(context).padding.top + 8,
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            CartScreenController? cartController;
                            if (Get.isRegistered<CartScreenController>()) {
                              cartController = Get.find<CartScreenController>();
                            }
                            if (cartController == null ||
                                cartController.cartItems.isEmpty) {
                              Get.back();
                            } else {
                              _showCancelOrderDialog(context, cartController);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: MySize.getHeight(30),
                            width: MySize.getHeight(30),
                            decoration: BoxDecoration(
                              color: ColorConstants.primaryColor.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: ColorConstants.primaryColor,
                              size: MySize.getHeight(20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: controller.isCategorySticky.value ? null : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: controller.isCategorySticky.value ? 1.0 : 0.0,
                      child:
                          controller.isCategorySticky.value
                              ? _buildSearchAndCategoryBox(
                                controller,
                                categoryController:
                                    controller.stickyCategoryScrollController,
                              )
                              : const SizedBox.shrink(),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: ColorConstants.getShadow2,
                          ),
                          child: Center(
                            child: CupertinoActivityIndicator(
                              radius: 12,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    final visibleCategories =
                        controller.categories
                            .where(
                              (cat) => controller.filteredGroupedItems
                                  .containsKey(cat),
                            )
                            .toList();

                    if (visibleCategories.isEmpty) {
                      return Center(
                        child: Text(TranslationKeys.noItemsFound.tr),
                      );
                    }

                    return Obx(() {
                      final itemCount =
                          controller.hasTable
                              ? visibleCategories.length + 1
                              : visibleCategories.length + 2;

                      return ScrollablePositionedList.builder(
                        itemScrollController: controller.itemScrollController,
                        itemPositionsListener: controller.itemPositionsListener,
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (!controller.hasTable && index == 0) {
                            return _buildPickupDeliverySelector(controller);
                          }
                          final searchIndex = controller.hasTable ? 0 : 1;
                          if (index == searchIndex) {
                            return _buildSearchAndCategoryBox(
                              controller,
                              categoryController:
                                  controller.categoryScrollController,
                            );
                          }

                          final categoryIndex =
                              controller.hasTable ? index - 1 : index - 2;
                          final category = visibleCategories[categoryIndex];
                          final items =
                              controller.filteredGroupedItems[category];
                          if (items == null || items.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return _buildCategorySection(
                            controller,
                            category,
                            items,
                          );
                        },
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
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _showClearCartDialog(context, cartController);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: MySize.getHeight(12),
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF60616E),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  TranslationKeys.clearCart.tr.replaceAll(
                                    '?',
                                    '',
                                  ),
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
                              onTap: () {
                                final Map<String, dynamic> arguments = {};

                                if (controller.hasTable) {
                                  arguments[ArgumentConstant.tableKey] =
                                      controller.selectedTable.value;
                                }

                                if (controller.currentOrder.value != null) {
                                  arguments[ArgumentConstant.orderKey] =
                                      controller.currentOrder.value;
                                }

                                if (controller.sourceScreen != null) {
                                  arguments[ArgumentConstant.sourceScreenKey] =
                                      controller.sourceScreen;
                                }

                                Get.toNamed(
                                  Routes.CART_SCREEN,
                                  arguments:
                                      arguments.isEmpty ? null : arguments,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: MySize.getHeight(12),
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF0B9F6E),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Next (${cartCount})',
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
        );
      },
    );
  }

  Widget _buildPickupDeliverySelector(TakeOrderController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ColorConstants.getShadow2,
        ),
        child: Obx(() {
          final selectedType = controller.selectedOrderType.value;
          return Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildOrderTypeButton(
                        icon: ImageConstant.pickup,
                        label: TranslationKeys.pickup.tr,
                        isSelected: selectedType == 'Pickup',
                        onTap: () => controller.updateOrderType('Pickup'),
                      ),
                    ),
                    Expanded(
                      child: _buildOrderTypeButton(
                        icon: ImageConstant.delivery,
                        label: TranslationKeys.delivery.tr,
                        isSelected: selectedType == 'Delivery',
                        onTap: () => controller.updateOrderType('Delivery'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategorySection(
    TakeOrderController controller,
    String category,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._buildItemsInRows(controller, items),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSearchAndCategoryBox(
    TakeOrderController controller, {
    ScrollController? categoryController,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: CupertinoTextField(
              controller: controller.searchController,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              placeholder: TranslationKeys.searchMenuItems.tr,
              prefix: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.search),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
              onChanged: (value) {},
            ),
          ),
          Container(
            height: MySize.getHeight(45),
            padding: const EdgeInsets.only(bottom: 5),
            child: Obx(() {
              final visibleCategories =
                  controller.categories
                      .where(
                        (cat) =>
                            controller.filteredGroupedItems.containsKey(cat),
                      )
                      .toList();
              return ListView.builder(
                controller:
                    categoryController ?? controller.categoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: visibleCategories.length,
                itemBuilder: (context, index) {
                  final category = visibleCategories[index];
                  return Obx(() {
                    final isSelected =
                        controller.selectedCategory.value == category;
                    return GestureDetector(
                      onTap: () => controller.updateCategory(category),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? ColorConstants.primaryColor
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: ColorConstants.primaryColor
                                          .withValues(alpha: 0.3),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
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
      ),
    );
  }

  List<Widget> _buildItemsInRows(
    TakeOrderController controller,
    List<Map<String, dynamic>> items,
  ) {
    List<Widget> rows = [];

    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(child: _buildItemCell(controller, items[i])),
              const SizedBox(width: 8),
              Expanded(
                child:
                    i + 1 < items.length
                        ? _buildItemCell(controller, items[i + 1])
                        : const SizedBox(),
              ),
            ],
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ColorConstants.getShadow2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (itemObject?.itemNumber != null &&
                    itemObject!.itemNumber!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: EdgeInsets.only(right: MySize.getWidth(6)),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      itemObject.itemNumber!,
                      style: TextStyle(
                        fontSize: MySize.getHeight(10),
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
                      fontSize: MySize.getHeight(12),
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        _getItemTypeImages(itemObject?.type)
                            .map(
                              (imagePath) => Padding(
                                padding: EdgeInsets.only(
                                  right: MySize.getWidth(4),
                                ),
                                child: Image.asset(
                                  imagePath,
                                  height: MySize.getHeight(14),
                                  width: MySize.getHeight(14),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                Obx(() {
                  String price = '0';
                  if (itemObject != null) {
                    final orderType = controller.selectedOrderType.value;
                    if (orderType == 'Pickup') {
                      price = itemObject.pickupPrice ?? '0';
                    } else if (orderType == 'Delivery') {
                      price = itemObject.deliveryPrice ?? '0';
                    } else if (orderType == 'Dine In') {
                      price = itemObject.dineInPrice ?? '0';
                    } else {
                      price =
                          itemObject.pickupPrice ??
                          itemObject.deliveryPrice ??
                          '0';
                    }
                  } else {
                    price = item["amount"] ?? '0';
                  }
                  return Text(
                    CurrencyFormatter.formatPrice(price),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeButton({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
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
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon, height: 20, width: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? ColorConstants.primaryColor
                        : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getItemTypeImages(String? type) {
    if (type == null || type.isEmpty) {
      return [ImageConstant.veg];
    }

    final types = type.toLowerCase().split(',').map((e) => e.trim()).toList();
    List<String> images = [];

    if (types.contains('halal')) {
      images.add(ImageConstant.halal);
    }
    if (types.contains('hot')) {
      images.add(ImageConstant.hot);
    }
    if (types.contains('non-veg')) {
      images.add(ImageConstant.nonVeg);
    }
    if (types.contains('drink')) {
      images.add(ImageConstant.drink);
    }
    if (types.contains('veg')) {
      images.add(ImageConstant.veg);
    }

    if (images.isEmpty) {
      return [ImageConstant.veg];
    }

    return images;
  }

  void _showClearCartDialog(
    BuildContext context,
    CartScreenController? controller, {
    bool shouldExit = false,
  }) {
    if (controller == null) return;

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
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ColorConstants.bgColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: MySize.getHeight(12)),
                ),
                SizedBox(height: MySize.getHeight(20)),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              TranslationKeys.close.tr,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MySize.getHeight(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          controller.clearCart();
                          Navigator.of(context).pop();
                          if (shouldExit) {
                            Get.back();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: ColorConstants.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              TranslationKeys.clearCart.tr.replaceAll('?', ''),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MySize.getHeight(12),
                              ),
                            ),
                          ),
                        ),
                      ),
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
