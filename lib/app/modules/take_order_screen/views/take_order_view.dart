import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/image_constants.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/modules/take_order_screen/controllers/take_order_controller.dart';

class TakeOrderView extends GetWidget<TakeOrderController> {
  const TakeOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TakeOrderController>(
      init: TakeOrderController(),
      assignId: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.bgColor,
          body: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      12,
                    ).copyWith(top: MediaQuery.of(context).padding.top + 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: ColorConstants.getShadow2,
                    ),
                    child: Center(
                      child: Text(
                        "Take Order",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: MediaQuery.of(context).padding.top + 8,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.back();
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
                  Positioned(
                    right: 15,
                    top: MediaQuery.of(context).padding.top - 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "10",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 25,
                    top: MediaQuery.of(context).padding.top + 8,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {},
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
                          Icons.shopping_cart_outlined,
                          color: ColorConstants.primaryColor,
                          size: MySize.getHeight(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Sticky Search + Category
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Obx(() {
                  if (controller.isCategorySticky.value) {
                    return _buildSearchAndCategoryBox(controller);
                  }
                  return const SizedBox.shrink();
                }),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    double stickyThreshold = 200.0;

                    if (scrollInfo.metrics.pixels >= stickyThreshold) {
                      if (!controller.isCategorySticky.value) {
                        controller.isCategorySticky.value = true;
                      }
                    } else {
                      if (controller.isCategorySticky.value) {
                        controller.isCategorySticky.value = false;
                      }
                    }
                    return true;
                  },
                  child: SingleChildScrollView(
                    controller: controller.mainScrollController,
                    child: Column(
                      children: [
                        // Delivery/Pickup Button (Not Sticky)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: ColorConstants.getShadow2,
                            ),
                            child: Obx(() {
                              final selectedType =
                                  controller.selectedOrderType.value;
                              return Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: _buildOrderTypeButton(
                                            icon: ImageConstant.pickup,
                                            label: 'Pickup',
                                            isSelected:
                                            selectedType == 'Pickup',
                                            onTap:
                                                () => controller
                                                .updateOrderType(
                                              'Pickup',
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildOrderTypeButton(
                                            icon: ImageConstant.delivery,
                                            label: 'Delivery',
                                            isSelected:
                                            selectedType == 'Delivery',
                                            onTap:
                                                () => controller
                                                .updateOrderType(
                                              'Delivery',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // Search + Category Box (Will be Sticky)
                        _buildSearchAndCategoryBox(controller),

                        Obx(() {
                          final filteredItems = controller.filteredGroupedItems;
                          return Column(
                            children:
                            filteredItems.entries.map((entry) {
                              final category = entry.key;
                              final items = entry.value;

                              return Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Category Title
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      8,
                                    ),
                                    child: Text(
                                      category,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ..._buildItemsInRows(items),
                                ],
                              );
                            }).toList(),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndCategoryBox(TakeOrderController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: CupertinoTextField(
              controller: controller.searchController,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              placeholder: "Search your menu item here",
              prefix: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.search),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
              onChanged: (value) {},
            ),
          ),
          // Category List
          Container(
            height: MySize.getHeight(42),
            padding: const EdgeInsets.only(bottom: 4),
            child: Obx(() {
              final filteredItems = controller.filteredGroupedItems;
              final visibleCategories =
              controller.categories
                  .where((cat) => filteredItems.containsKey(cat))
                  .toList();

              return ListView.builder(
                controller: controller.categoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: visibleCategories.length,
                itemBuilder: (context, index) {
                  final category = visibleCategories[index];

                  return Obx(() {
                    final isSelected =
                        controller.selectedCategory.value == category;

                    return GestureDetector(
                      onTap: () {
                        controller.updateCategory(category);
                        controller.scrollToStickyPosition();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                          isSelected
                              ? ColorConstants.primaryColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow:
                          isSelected
                              ? [
                            BoxShadow(
                              color: ColorConstants.primaryColor
                                  .withValues(
                                alpha: 0.3,
                              ),
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
                              color:
                              isSelected ? Colors.white : Colors.black87,
                              fontWeight:

                                   FontWeight.w600,
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

  List<Widget> _buildItemsInRows(List<Map<String, dynamic>> items) {
    List<Widget> rows = [];

    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(child: _buildItemCell(items[i])),
              const SizedBox(width: 8),
              Expanded(
                child:
                i + 1 < items.length
                    ? _buildItemCell(items[i + 1])
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildItemCell(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ColorConstants.getShadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
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
          Divider(color: Colors.grey.shade300, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                ImageConstant.veg,
                height: MySize.getHeight(20),
                width: MySize.getHeight(20),
              ),
              Text(
                " ₹ ${item["amount"]}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
}