import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../main.dart';
import '../../../constants/api_constants.dart';
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
      // If no data in storage, fetch from API
      fetchMenuItems();
    } catch (e) {
      // If error loading from storage, fetch from API
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
              // Save to local storage
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

    // Update selected category
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

    // Update sticky state
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

  @override
  void onClose() {
    searchController.dispose();
    categoryScrollController.dispose();
    stickyCategoryScrollController.dispose();
    super.onClose();
  }
}
