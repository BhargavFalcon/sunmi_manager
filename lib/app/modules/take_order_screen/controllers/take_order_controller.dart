import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TakeOrderController extends GetxController {
  RxString selectedOrderType = 'Pickup'.obs;
  TextEditingController searchController = TextEditingController();
  ScrollController categoryScrollController = ScrollController();
  ScrollController stickyCategoryScrollController = ScrollController();

  // For scrollable positioned list
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  RxString searchText = "".obs;
  RxString selectedCategory = "".obs;
  RxBool isCategorySticky = false.obs;
  RxBool isAutoScrolling =
      false.obs; // Track if we're programmatically scrolling

  List<String> categories = [];
  Map<String, List<Map<String, dynamic>>> groupedItems = {};
  Map<String, int> categoryIndexMap = {};

  List<Map<String, dynamic>> orderList = [
    {"Id": "1", "title": "Veg", "product_name": "Orange", "amount": "432"},
    {"Id": "1", "title": "Veg", "product_name": "Apple", "amount": "788"},
    {"Id": "1", "title": "Veg", "product_name": "Banana", "amount": "265"},
    {"Id": "1", "title": "Veg", "product_name": "Mango", "amount": "934"},
    {"Id": "1", "title": "Veg", "product_name": "Pineapple", "amount": "503"},
    {"Id": "2", "title": "Non-Veg", "product_name": "Chicken", "amount": "645"},
    {"Id": "2", "title": "Non-Veg", "product_name": "Mutton", "amount": "271"},
    {"Id": "2", "title": "Non-Veg", "product_name": "Fish", "amount": "842"},
    {"Id": "5", "title": "Halal", "product_name": "Dates", "amount": "599"},
    {
      "Id": "5",
      "title": "Halal",
      "product_name": "Pomegranate",
      "amount": "422",
    },
    {"Id": "5", "title": "Halal", "product_name": "Fig", "amount": "731"},
    {"Id": "5", "title": "Halal", "product_name": "Olive", "amount": "690"},
    {"Id": "5", "title": "Halal", "product_name": "Grapes", "amount": "377"},
    {"Id": "5", "title": "Halal", "product_name": "Plum", "amount": "812"},
    {"Id": "5", "title": "Halal", "product_name": "Apricot", "amount": "509"},
    {"Id": "5", "title": "Halal", "product_name": "Peach", "amount": "623"},
    {"Id": "5", "title": "Halal", "product_name": "Lychee", "amount": "458"},
    {"Id": "5", "title": "Halal", "product_name": "Papaya", "amount": "786"},
    {
      "Id": "5",
      "title": "Halal",
      "product_name": "Strawberry",
      "amount": "332",
    },
    {"Id": "5", "title": "Halal", "product_name": "Blueberry", "amount": "674"},
    {"Id": "5", "title": "Halal", "product_name": "Cherry", "amount": "298"},
    {"Id": "5", "title": "Halal", "product_name": "Guava", "amount": "901"},
    {"Id": "5", "title": "Halal", "product_name": "Kiwi", "amount": "544"},
    {
      "Id": "5",
      "title": "Halal",
      "product_name": "Dragonfruit",
      "amount": "467",
    },
    {"Id": "3", "title": "Egg", "product_name": "Ostrich Egg", "amount": "234"},
    {"Id": "3", "title": "Egg", "product_name": "Duck Egg", "amount": "853"},
    {"Id": "3", "title": "Egg", "product_name": "Quail Egg", "amount": "411"},
    {"Id": "3", "title": "Egg", "product_name": "Turkey Egg", "amount": "672"},
    {"Id": "3", "title": "Egg", "product_name": "Goose Egg", "amount": "509"},
    {"Id": "7", "title": "Bakery", "product_name": "Bread", "amount": "765"},
    {"Id": "7", "title": "Bakery", "product_name": "Cake", "amount": "390"},
    {"Id": "7", "title": "Bakery", "product_name": "Donut", "amount": "856"},
    {
      "Id": "7",
      "title": "Bakery",
      "product_name": "Croissant",
      "amount": "479",
    },
    {"Id": "7", "title": "Bakery", "product_name": "Bun", "amount": "267"},
    {"Id": "7", "title": "Bakery", "product_name": "Pastry", "amount": "698"},
    {"Id": "7", "title": "Bakery", "product_name": "Muffin", "amount": "531"},
    {"Id": "7", "title": "Bakery", "product_name": "Tart", "amount": "804"},
    {"Id": "7", "title": "Bakery", "product_name": "Bagel", "amount": "376"},
    {"Id": "7", "title": "Bakery", "product_name": "Toast", "amount": "642"},
    {"Id": "9", "title": "Beverages", "product_name": "Tea", "amount": "711"},
    {
      "Id": "9",
      "title": "Beverages",
      "product_name": "Coffee",
      "amount": "591",
    },
    {"Id": "9", "title": "Beverages", "product_name": "Juice", "amount": "473"},
    {
      "Id": "9",
      "title": "Beverages",
      "product_name": "Milkshake",
      "amount": "889",
    },
    {
      "Id": "9",
      "title": "Beverages",
      "product_name": "Smoothie",
      "amount": "328",
    },
    {"Id": "9", "title": "Beverages", "product_name": "Soda", "amount": "544"},
    {"Id": "9", "title": "Beverages", "product_name": "Water", "amount": "693"},
    {"Id": "9", "title": "Beverages", "product_name": "Lassi", "amount": "417"},
    {
      "Id": "9",
      "title": "Beverages",
      "product_name": "Mocktail",
      "amount": "865",
    },
    {
      "Id": "9",
      "title": "Beverages",
      "product_name": "Energy Drink",
      "amount": "509",
    },
    {
      "Id": "9",
      "title": "Beverages",
      "product_name": "Herbal Tea",
      "amount": "278",
    },
    {
      "Id": "9",
      "title": "Beverages",
      "product_name": "Green Tea",
      "amount": "624",
    },
    {"Id": "11", "title": "Snacks", "product_name": "Chips", "amount": "532"},
    {"Id": "11", "title": "Snacks", "product_name": "Nachos", "amount": "634"},
    {"Id": "11", "title": "Snacks", "product_name": "Popcorn", "amount": "712"},
    {"Id": "11", "title": "Snacks", "product_name": "Fries", "amount": "399"},
    {"Id": "11", "title": "Snacks", "product_name": "Samosa", "amount": "581"},
    {"Id": "11", "title": "Snacks", "product_name": "Pakora", "amount": "463"},
    {"Id": "11", "title": "Snacks", "product_name": "Kachori", "amount": "688"},
    {"Id": "11", "title": "Snacks", "product_name": "Roll", "amount": "749"},
    {"Id": "12", "title": "Dairy", "product_name": "Milk", "amount": "421"},
    {"Id": "12", "title": "Dairy", "product_name": "Curd", "amount": "674"},
    {"Id": "12", "title": "Dairy", "product_name": "Butter", "amount": "732"},
    {"Id": "12", "title": "Dairy", "product_name": "Cheese", "amount": "598"},
    {"Id": "12", "title": "Dairy", "product_name": "Paneer", "amount": "823"},
    {"Id": "13", "title": "Spices", "product_name": "Cumin", "amount": "351"},
    {
      "Id": "13",
      "title": "Spices",
      "product_name": "Coriander",
      "amount": "457",
    },
    {
      "Id": "13",
      "title": "Spices",
      "product_name": "Turmeric",
      "amount": "612",
    },
    {
      "Id": "13",
      "title": "Spices",
      "product_name": "Chili Powder",
      "amount": "733",
    },
    {
      "Id": "13",
      "title": "Spices",
      "product_name": "Garam Masala",
      "amount": "814",
    },
    {
      "Id": "14",
      "title": "Frozen",
      "product_name": "Frozen Peas",
      "amount": "463",
    },
    {
      "Id": "14",
      "title": "Frozen",
      "product_name": "Frozen Corn",
      "amount": "522",
    },
    {
      "Id": "14",
      "title": "Frozen",
      "product_name": "Frozen Pizza",
      "amount": "749",
    },
    {
      "Id": "14",
      "title": "Frozen",
      "product_name": "Frozen Fries",
      "amount": "631",
    },
    {
      "Id": "15",
      "title": "Dry Fruits",
      "product_name": "Almonds",
      "amount": "928",
    },
    {
      "Id": "15",
      "title": "Dry Fruits",
      "product_name": "Cashews",
      "amount": "742",
    },
    {
      "Id": "15",
      "title": "Dry Fruits",
      "product_name": "Walnuts",
      "amount": "663",
    },
    {
      "Id": "15",
      "title": "Dry Fruits",
      "product_name": "Pistachios",
      "amount": "512",
    },
    {
      "Id": "15",
      "title": "Dry Fruits",
      "product_name": "Raisins",
      "amount": "841",
    },
    {
      "Id": "16",
      "title": "Condiments",
      "product_name": "Ketchup",
      "amount": "329",
    },
    {
      "Id": "16",
      "title": "Condiments",
      "product_name": "Mayonnaise",
      "amount": "541",
    },
    {
      "Id": "16",
      "title": "Condiments",
      "product_name": "Mustard",
      "amount": "492",
    },
    {
      "Id": "16",
      "title": "Condiments",
      "product_name": "Chutney",
      "amount": "678",
    },
    {"Id": "17", "title": "Seafood", "product_name": "Prawns", "amount": "765"},
    {"Id": "17", "title": "Seafood", "product_name": "Crab", "amount": "681"},
    {
      "Id": "17",
      "title": "Seafood",
      "product_name": "Lobster",
      "amount": "899",
    },
    {"Id": "17", "title": "Seafood", "product_name": "Squid", "amount": "534"},
    {"Id": "18", "title": "Grains", "product_name": "Rice", "amount": "372"},
    {"Id": "18", "title": "Grains", "product_name": "Wheat", "amount": "541"},
    {"Id": "18", "title": "Grains", "product_name": "Barley", "amount": "612"},
    {"Id": "18", "title": "Grains", "product_name": "Oats", "amount": "452"},
    {
      "Id": "18",
      "title": "Grains",
      "product_name": "Cornmeal",
      "amount": "721",
    },
    {"Id": "19", "title": "Pulses", "product_name": "Lentils", "amount": "632"},
    {
      "Id": "19",
      "title": "Pulses",
      "product_name": "Chickpeas",
      "amount": "521",
    },
    {
      "Id": "19",
      "title": "Pulses",
      "product_name": "Kidney Beans",
      "amount": "788",
    },
    {
      "Id": "19",
      "title": "Pulses",
      "product_name": "Black Beans",
      "amount": "412",
    },
    {
      "Id": "20",
      "title": "Sauces",
      "product_name": "Soy Sauce",
      "amount": "598",
    },
    {"Id": "20", "title": "Sauces", "product_name": "Vinegar", "amount": "423"},
    {
      "Id": "20",
      "title": "Sauces",
      "product_name": "BBQ Sauce",
      "amount": "739",
    },
    {
      "Id": "20",
      "title": "Sauces",
      "product_name": "Hot Sauce",
      "amount": "681",
    },
    {"Id": "21", "title": "Oils", "product_name": "Olive Oil", "amount": "864"},
    {
      "Id": "21",
      "title": "Oils",
      "product_name": "Sunflower Oil",
      "amount": "745",
    },
    {
      "Id": "21",
      "title": "Oils",
      "product_name": "Mustard Oil",
      "amount": "698",
    },
    {
      "Id": "21",
      "title": "Oils",
      "product_name": "Coconut Oil",
      "amount": "599",
    },
    {
      "Id": "21",
      "title": "Oils",
      "product_name": "Groundnut Oil",
      "amount": "783",
    },
  ];

  @override
  void onInit() {
    for (Map<String, dynamic> item in orderList) {
      groupedItems.putIfAbsent(item["title"], () => []).add(item);
    }
    categories = groupedItems.keys.toList();
    int index = 0;
    for (String category in categories) {
      categoryIndexMap[category] = index;
      index++;
    }

    if (categories.isNotEmpty) {
      selectedCategory.value = categories.first;
    }

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    // Listen to scroll position changes to update selected category
    itemPositionsListener.itemPositions.addListener(_onScrollPositionChanged);

    super.onInit();
  }

  void _onScrollPositionChanged() {
    if (isAutoScrolling.value)
      return; // Don't update if programmatically scrolling

    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Get the first visible item that is most visible
    final visiblePositions =
        positions
            .where(
              (position) =>
                  position.itemLeadingEdge < 0.5 &&
                  position.itemTrailingEdge > 0,
            )
            .toList();

    if (visiblePositions.isEmpty) return;

    // Sort by most visible (closest to top)
    visiblePositions.sort(
      (a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge),
    );
    final mostVisible = visiblePositions.first;

    final filteredItems = filteredGroupedItems;
    final visibleCategories =
        categories.where((cat) => filteredItems.containsKey(cat)).toList();

    // Account for the 2 sticky items at the top (pickup/delivery + search/category)
    final categoryIndex = mostVisible.index - 2;
    if (categoryIndex >= 0 && categoryIndex < visibleCategories.length) {
      final newCategory = visibleCategories[categoryIndex];
      if (selectedCategory.value != newCategory) {
        selectedCategory.value = newCategory;
        _scrollCategoryToCenter(newCategory);
      }
    }
    
    // Update sticky state based on scroll position
    // If we're past the first two items (pickup/delivery + search/category), show sticky
    if (mostVisible.index >= 2) {
      if (!isCategorySticky.value) {
        isCategorySticky.value = true;
      }
    } else {
      if (isCategorySticky.value) {
        isCategorySticky.value = false;
      }
    }
  }

  void _scrollCategoryToCenter(String category) {
    final filteredItems = filteredGroupedItems;
    final visibleCategories =
        categories.where((cat) => filteredItems.containsKey(cat)).toList();
    final index = visibleCategories.indexOf(category);

    if (index == -1) return;

    // Calculate approximate position to center the category
    const itemWidth = 100.0;
    
    // Scroll the main category list
    if (categoryScrollController.hasClients) {
      final screenWidth = categoryScrollController.position.viewportDimension;
      final targetOffset =
          (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      final clampedOffset = targetOffset.clamp(
        0.0,
        categoryScrollController.position.maxScrollExtent,
      );

      if ((categoryScrollController.offset - clampedOffset).abs() > 10) {
        categoryScrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
    
    // Scroll the sticky category list
    if (stickyCategoryScrollController.hasClients) {
      final screenWidth = stickyCategoryScrollController.position.viewportDimension;
      final targetOffset =
          (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      final clampedOffset = targetOffset.clamp(
        0.0,
        stickyCategoryScrollController.position.maxScrollExtent,
      );

      if ((stickyCategoryScrollController.offset - clampedOffset).abs() > 10) {
        stickyCategoryScrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Map<String, List<Map<String, dynamic>>> get filteredGroupedItems {
    if (searchText.value.isEmpty) {
      return groupedItems;
    }

    Map<String, List<Map<String, dynamic>>> filtered = {};
    String searchQuery = searchText.value.toLowerCase();

    groupedItems.forEach((category, items) {
      List<Map<String, dynamic>> filteredItems =
          items
              .where(
                (item) => item["product_name"]
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery),
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

    final filteredItems = filteredGroupedItems;
    final visibleCategories =
        categories.where((cat) => filteredItems.containsKey(cat)).toList();
    final categoryIndex = visibleCategories.indexOf(category);

    if (categoryIndex == -1 || !itemScrollController.isAttached) return;

    // Add 2 to account for the sticky items at the top
    final scrollIndex = categoryIndex + 2;

    // Set flag to prevent auto-update during programmatic scroll
    isAutoScrolling.value = true;

    try {
      await itemScrollController.scrollTo(
        index: scrollIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    } catch (e) {
      print('Scroll error: $e');
    }

    // Re-enable auto-update after scroll completes
    Future.delayed(const Duration(milliseconds: 600), () {
      isAutoScrolling.value = false;
    });
  }

  void toggleCategorySticky() =>
      isCategorySticky.value = !isCategorySticky.value;


  void scrollToTop() async {
    if (!itemScrollController.isAttached) return;
    
    try {
      await itemScrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
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
