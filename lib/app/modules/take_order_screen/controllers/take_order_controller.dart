import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/image_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/menuItemsModel.dart';

class TakeOrderController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final RxList<Items> menuItems = <Items>[].obs;

  RxString selectedOrderType = 'Pickup'.obs;
  TextEditingController searchController = TextEditingController();
  ScrollController categoryScrollController = ScrollController();
  ScrollController stickyCategoryScrollController = ScrollController();

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  RxString searchText = "".obs;
  RxString selectedCategory = "".obs;
  RxBool isCategorySticky = false.obs;
  RxBool isAutoScrolling = false.obs;

  final RxList<String> categories = <String>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> groupedItems =
      <String, List<Map<String, dynamic>>>{}.obs;
  Map<String, int> categoryIndexMap = {};

  final RxMap<int, bool> expandedSections = <int, bool>{}.obs;
  final RxMap<int, Set<int>> selectedOptions = <int, Set<int>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadMenuItemsFromStorage();

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    itemPositionsListener.itemPositions.addListener(_onScrollPositionChanged);
  }

  void loadMenuItemsFromStorage() {
    try {
      final storedData = box.read(ArgumentConstant.menuItemsKey);
      if (storedData != null && storedData is String) {
        final jsonData = json.decode(storedData);
        if (jsonData is List) {
          final List<Items> loadedItems =
              jsonData
                  .map((item) => Items.fromJson(item as Map<String, dynamic>))
                  .toList();
          if (loadedItems.isNotEmpty) {
            menuItems.assignAll(loadedItems);
            _processMenuItems();
            return;
          }
        }
      }
      fetchMenuItems();
    } catch (e) {
      fetchMenuItems();
    }
  }

  void saveMenuItemsToStorage(List<Items> items) {
    try {
      final List<Map<String, dynamic>> itemsJson =
          items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(itemsJson);
      box.write(ArgumentConstant.menuItemsKey, jsonString);
    } catch (e) {
      print('Error saving menu items to storage: $e');
    }
  }

  void _processMenuItems() {
    final newGroupedItems = <String, List<Map<String, dynamic>>>{};
    categoryIndexMap.clear();

    for (Items item in menuItems) {
      final categoryName = item.category?.categoryName ?? 'Uncategorized';
      final amountString = item.price?.toString() ?? '0';
      final itemData = {
        'product_name': item.itemName ?? '',
        'amount': amountString,
        'item': item,
      };
      newGroupedItems.putIfAbsent(categoryName, () => []).add(itemData);
    }

    final newCategories = newGroupedItems.keys.toList();
    int index = 0;
    for (String category in newCategories) {
      categoryIndexMap[category] = index;
      index++;
    }

    groupedItems.assignAll(newGroupedItems);
    categories.assignAll(newCategories);

    if (categories.isNotEmpty && selectedCategory.value.isEmpty) {
      selectedCategory.value = categories.first;
    }
  }

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;

      final response = await networkClient.get(
        ArgumentConstant.menuItemsEndpoint,
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          try {
            final itemMenu = ItemMenu.fromJson(
              response.data as Map<String, dynamic>,
            );

            if (itemMenu.data?.items != null &&
                itemMenu.data!.items!.isNotEmpty) {
              menuItems.assignAll(itemMenu.data!.items!);
              _processMenuItems();
              saveMenuItemsToStorage(itemMenu.data!.items!);
            }
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to parse menu items: ${e.toString()}',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      }
    } on ApiException catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onScrollPositionChanged() {
    if (isAutoScrolling.value) return;

    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final mostVisible =
        positions
            .where((p) => p.itemLeadingEdge < 0.5 && p.itemTrailingEdge > 0)
            .toList()
          ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));

    if (mostVisible.isEmpty) return;

    final filteredItems = filteredGroupedItems;
    final visibleCategories =
        categories.where((cat) => filteredItems.containsKey(cat)).toList();
    final categoryIndex = mostVisible.first.index - 2;

    if (categoryIndex >= 0 && categoryIndex < visibleCategories.length) {
      final newCategory = visibleCategories[categoryIndex];
      if (selectedCategory.value != newCategory) {
        selectedCategory.value = newCategory;
        Future.delayed(
          const Duration(milliseconds: 50),
          () => _scrollCategoryToCenter(newCategory),
        );
      }
    }

    isCategorySticky.value = mostVisible.first.index > 1;
  }

  void _scrollCategoryToCenter(String category) {
    final visibleCategories =
        categories
            .where((cat) => filteredGroupedItems.containsKey(cat))
            .toList();
    final index = visibleCategories.indexOf(category);
    if (index == -1) return;

    const itemWidth = 100.0;
    final scrollToCenter = (ScrollController controller) {
      if (!controller.hasClients) return;
      final screenWidth = controller.position.viewportDimension;
      final itemPosition = index * itemWidth;
      final targetOffset = (itemPosition - screenWidth / 2 + itemWidth / 2)
          .clamp(0.0, controller.position.maxScrollExtent);
      controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    };

    scrollToCenter(categoryScrollController);
    scrollToCenter(stickyCategoryScrollController);
  }

  Map<String, List<Map<String, dynamic>>> get filteredGroupedItems {
    if (groupedItems.isEmpty) {
      return {};
    }

    if (searchText.value.isEmpty) {
      return Map<String, List<Map<String, dynamic>>>.from(groupedItems);
    }

    Map<String, List<Map<String, dynamic>>> filtered = {};
    String searchQuery = searchText.value.toLowerCase();

    groupedItems.forEach((category, items) {
      List<Map<String, dynamic>> filteredItems =
          items
              .where(
                (item) =>
                    item["product_name"] != null &&
                    item["product_name"].toString().toLowerCase().contains(
                      searchQuery,
                    ),
              )
              .toList();

      if (filteredItems.isNotEmpty) {
        filtered[category] = filteredItems;
      }
    });

    return filtered;
  }

  void updateOrderType(String value) => selectedOrderType.value = value;

  void updateCategory(String category) async {
    selectedCategory.value = category;
    isCategorySticky.value = true;

    final visibleCategories =
        categories
            .where((cat) => filteredGroupedItems.containsKey(cat))
            .toList();
    final categoryIndex = visibleCategories.indexOf(category);
    if (categoryIndex == -1 || !itemScrollController.isAttached) return;

    Future.delayed(
      const Duration(milliseconds: 100),
      () => _scrollCategoryToCenter(category),
    );

    isAutoScrolling.value = true;
    try {
      await itemScrollController.scrollTo(
        index: categoryIndex + 2,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      print('Scroll error: $e');
    }
    Future.delayed(
      const Duration(milliseconds: 600),
      () => isAutoScrolling.value = false,
    );
  }

  void toggleCategorySticky() =>
      isCategorySticky.value = !isCategorySticky.value;

  void scrollToTop() async {
    if (!itemScrollController.isAttached) return;
    isCategorySticky.value = false;
    try {
      await itemScrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      print('Scroll to top error: $e');
    }
  }

  void showItemVariationsBottomSheet(Items item) {
    if (item.variations == null || item.variations!.isEmpty) {
      if (item.modifierGroups != null && item.modifierGroups!.isNotEmpty) {
        showItemExtrasBottomSheet(item);
      }
      return;
    }

    Get.bottomSheet(
      _buildItemVariationsBottomSheet(item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void showItemExtrasBottomSheet(Items item, {Variations? selectedVariation}) {
    expandedSections.clear();
    selectedOptions.clear();

    if (item.modifierGroups != null) {
      for (int i = 0; i < item.modifierGroups!.length; i++) {
        expandedSections[i] = true;
        selectedOptions[i] = <int>{};
      }
    }

    Get.bottomSheet(
      _buildItemExtrasBottomSheet(item, selectedVariation: selectedVariation),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildItemVariationsBottomSheet(Items item) {
    final variations = item.variations ?? [];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(Get.context!).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(MySize.getHeight(20)),
          topRight: Radius.circular(MySize.getHeight(20)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: MySize.getHeight(12)),
            width: MySize.getWidth(40),
            height: MySize.getHeight(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(MySize.getHeight(2)),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(MySize.getHeight(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Variations',
                    style: TextStyle(
                      fontSize: MySize.getHeight(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(16)),
                  Row(
                    children: [
                      if (item.imageUrl != null &&
                          item.imageUrl!.isNotEmpty) ...[
                        Container(
                          width: MySize.getWidth(50),
                          height: MySize.getHeight(50),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(8),
                            ),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: MySize.getWidth(1),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(8),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              width: MySize.getWidth(50),
                              height: MySize.getHeight(50),
                              placeholder:
                                  (context, url) => Container(
                                    width: MySize.getWidth(50),
                                    height: MySize.getHeight(50),
                                    color: Colors.grey.shade100,
                                    child: Center(
                                      child: CupertinoActivityIndicator(
                                        radius: 12,
                                        color: ColorConstants.primaryColor,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    width: MySize.getWidth(50),
                                    height: MySize.getHeight(50),
                                    color: Colors.grey.shade100,
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      color: Colors.grey.shade600,
                                      size: MySize.getHeight(28),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(12)),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            _getItemTypeImages(item.type)
                                .map(
                                  (imagePath) => Padding(
                                    padding: EdgeInsets.only(
                                      right: MySize.getWidth(4),
                                    ),
                                    child: Image.asset(
                                      imagePath,
                                      height: MySize.getHeight(16),
                                      width: MySize.getWidth(16),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(width: MySize.getWidth(8)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.itemName ?? 'Item',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: MySize.getHeight(12),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (item.description != null &&
                                item.description!.isNotEmpty) ...[
                              SizedBox(height: MySize.getHeight(4)),
                              Text(
                                item.description!,
                                style: TextStyle(
                                  fontSize: MySize.getHeight(12),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MySize.getHeight(24)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(12),
                      vertical: MySize.getHeight(10),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'ITEM NAME',
                            style: TextStyle(
                              fontSize: MySize.getHeight(10),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'PRICE',
                            style: TextStyle(
                              fontSize: MySize.getHeight(10),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ACTION',
                            style: TextStyle(
                              fontSize: MySize.getHeight(10),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(8)),
                  ...variations.map((variation) {
                    String price = '0';
                    if (selectedOrderType.value == 'Pickup') {
                      price = variation.onlinePrice ?? variation.price ?? '0';
                    } else {
                      price = variation.takeAwayPrice ?? variation.price ?? '0';
                    }

                    String formattedPrice = '€${price.replaceAll('.', ',')}';
                    if (!price.contains(',')) {
                      final parts = price.split('.');
                      if (parts.length == 2) {
                        formattedPrice = '€${parts[0]},${parts[1]}';
                      }
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: MySize.getHeight(8)),
                      padding: EdgeInsets.all(MySize.getHeight(12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          MySize.getHeight(12),
                        ),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: MySize.getWidth(1),
                        ),
                        boxShadow: ColorConstants.getShadow2,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              variation.variation ?? 'Variation',
                              style: TextStyle(
                                fontSize: MySize.getHeight(12),
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              formattedPrice,
                              style: TextStyle(
                                fontSize: MySize.getHeight(12),
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: MySize.getHeight(36),
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  if (item.modifierGroups != null &&
                                      item.modifierGroups!.isNotEmpty) {
                                    showItemExtrasBottomSheet(
                                      item,
                                      selectedVariation: variation,
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Success',
                                      '${item.itemName} - ${variation.variation} added to cart',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorConstants.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      MySize.getHeight(8),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: MySize.getWidth(12),
                                    vertical: MySize.getHeight(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Select',
                                  style: TextStyle(
                                    fontSize: MySize.getHeight(11),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: MySize.getHeight(16)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: MySize.getHeight(40),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(8),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: MySize.getWidth(24),
                            vertical: MySize.getHeight(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: MySize.getHeight(12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemExtrasBottomSheet(
    Items item, {
    Variations? selectedVariation,
  }) {
    final modifierGroups = item.modifierGroups ?? [];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(Get.context!).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(MySize.getHeight(20)),
          topRight: Radius.circular(MySize.getHeight(20)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: MySize.getHeight(12)),
            width: MySize.getWidth(40),
            height: MySize.getHeight(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(MySize.getHeight(2)),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(MySize.getHeight(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Extras',
                    style: TextStyle(
                      fontSize: MySize.getHeight(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: MySize.getHeight(12)),
                  Divider(
                    color: Colors.grey.shade300,
                    height: MySize.getHeight(1),
                    thickness: MySize.getHeight(1),
                  ),
                  SizedBox(height: MySize.getHeight(12)),
                  // Item Details
                  Row(
                    children: [
                      if (item.imageUrl != null &&
                          item.imageUrl!.isNotEmpty) ...[
                        Container(
                          width: MySize.getWidth(50),
                          height: MySize.getHeight(50),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(8),
                            ),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: MySize.getWidth(1),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              MySize.getHeight(8),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              width: MySize.getWidth(50),
                              height: MySize.getHeight(50),
                              placeholder:
                                  (context, url) => Container(
                                    width: MySize.getWidth(50),
                                    height: MySize.getHeight(50),
                                    color: Colors.grey.shade100,
                                    child: Center(
                                      child: CupertinoActivityIndicator(
                                        radius: 12,
                                        color: ColorConstants.primaryColor,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    width: MySize.getWidth(50),
                                    height: MySize.getHeight(50),
                                    color: Colors.grey.shade100,
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      color: Colors.grey.shade600,
                                      size: MySize.getHeight(28),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: MySize.getWidth(12)),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            _getItemTypeImages(item.type)
                                .map(
                                  (imagePath) => Padding(
                                    padding: EdgeInsets.only(
                                      right: MySize.getWidth(4),
                                    ),
                                    child: Image.asset(
                                      imagePath,
                                      height: MySize.getHeight(16),
                                      width: MySize.getWidth(16),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(width: MySize.getWidth(8)),
                      Expanded(
                        child: Text(
                          item.itemName ?? 'Item',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: MySize.getHeight(12),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MySize.getHeight(24)),
                  ...modifierGroups.asMap().entries.map((entry) {
                    final index = entry.key;
                    final modifierGroup = entry.value;
                    final options = modifierGroup.options ?? [];

                    return Obx(() {
                      final isExpanded = expandedSections[index] ?? true;
                      final selected = selectedOptions[index] ?? <int>{};

                      return Container(
                        margin: EdgeInsets.only(bottom: MySize.getHeight(12)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(
                            MySize.getHeight(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                expandedSections[index] = !isExpanded;
                              },
                              child: Padding(
                                padding: EdgeInsets.all(MySize.getHeight(12)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            modifierGroup.name ?? 'Section',
                                            style: TextStyle(
                                              fontSize: MySize.getHeight(14),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (modifierGroup.description !=
                                                  null &&
                                              modifierGroup
                                                  .description!
                                                  .isNotEmpty) ...[
                                            SizedBox(
                                              height: MySize.getHeight(4),
                                            ),
                                            Text(
                                              modifierGroup.description!,
                                              style: TextStyle(
                                                fontSize: MySize.getHeight(11),
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.black87,
                                      size: MySize.getHeight(24),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: MySize.getWidth(12),
                                  vertical: MySize.getHeight(8),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(
                                      MySize.getHeight(8),
                                    ),
                                    bottomRight: Radius.circular(
                                      MySize.getHeight(8),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'OPTION NAME',
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(10),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'PRICE',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(10),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'SELECT',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(10),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...options.map((option) {
                                final isSelected = selected.contains(option.id);
                                String price = option.price ?? '0';

                                String formattedPrice =
                                    '€${price.replaceAll('.', ',')}';
                                if (!price.contains(',')) {
                                  final parts = price.split('.');
                                  if (parts.length == 2) {
                                    formattedPrice = '€${parts[0]},${parts[1]}';
                                  } else {
                                    formattedPrice = '€$price,00';
                                  }
                                }

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: MySize.getWidth(12),
                                    vertical: MySize.getHeight(10),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: MySize.getWidth(1),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          option.name ?? 'Option',
                                          style: TextStyle(
                                            fontSize: MySize.getHeight(12),
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          formattedPrice,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: MySize.getHeight(12),
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (isSelected) {
                                                selectedOptions[index] =
                                                    <int>{};
                                              } else {
                                                selectedOptions[index] = {
                                                  option.id!,
                                                };
                                              }
                                            },
                                            child: Container(
                                              width: MySize.getWidth(20),
                                              height: MySize.getHeight(20),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? ColorConstants
                                                              .primaryColor
                                                          : Colors
                                                              .grey
                                                              .shade400,
                                                  width: MySize.getWidth(2),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      MySize.getHeight(4),
                                                    ),
                                                color:
                                                    isSelected
                                                        ? ColorConstants
                                                            .primaryColor
                                                        : Colors.transparent,
                                              ),
                                              child:
                                                  isSelected
                                                      ? Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: MySize.getHeight(
                                                          14,
                                                        ),
                                                      )
                                                      : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      );
                    });
                  }).toList(),
                  SizedBox(height: MySize.getHeight(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: MySize.getHeight(40),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(8),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(24),
                              vertical: MySize.getHeight(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: MySize.getHeight(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MySize.getWidth(12)),
                      SizedBox(
                        height: MySize.getHeight(40),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                MySize.getHeight(8),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: MySize.getWidth(24),
                              vertical: MySize.getHeight(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: MySize.getHeight(12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MySize.getHeight(16)),
                ],
              ),
            ),
          ),
        ],
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

  @override
  void onClose() {
    searchController.dispose();
    categoryScrollController.dispose();
    stickyCategoryScrollController.dispose();
    super.onClose();
  }
}
