import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../main.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/image_constants.dart';
import '../../../constants/sizeConstant.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/menuItemsModel.dart';
import '../../../model/tableModel.dart';
import '../../../model/getorderModel.dart' as orderModel;
import '../../../utils/currency_formatter.dart';
import '../../cart_screen/controllers/cart_screen_controller.dart';

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

  // Cart items count
  RxInt cartItemsCount = 0.obs;
  bool _cartListenerSet = false;

  // Table from arguments
  final Rx<Tables?> selectedTable = Rx<Tables?>(null);

  // Order from arguments
  final Rx<orderModel.GetOrderModel?> currentOrder =
      Rx<orderModel.GetOrderModel?>(null);

  // Getter to check if table exists
  bool get hasTable => selectedTable.value != null;

  // Get offset for category index calculation (number of items before categories)
  int get categoryOffset => hasTable ? 1 : 2;

  @override
  void onInit() {
    super.onInit();
    _fetchTableFromArguments();
    _fetchOrderFromArguments();
    loadMenuItemsFromStorage();
    _updateCartCount();

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    itemPositionsListener.itemPositions.addListener(_onScrollPositionChanged);
  }

  void _fetchTableFromArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      final table = arguments[ArgumentConstant.tableKey];
      if (table != null && table is Tables) {
        selectedTable.value = table;
      }
    }
  }

  void _fetchOrderFromArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      final order = arguments[ArgumentConstant.orderKey];
      if (order != null && order is orderModel.GetOrderModel) {
        currentOrder.value = order;
        // Order items will be added to cart in _processMenuItems after menu items are loaded
      }
    }
  }

  // Update cart count
  void _updateCartCount() {
    if (Get.isRegistered<CartScreenController>()) {
      final cartController = Get.find<CartScreenController>();
      cartItemsCount.value = cartController.cartItems.length;

      // Listen to cart changes (only set once)
      if (!_cartListenerSet) {
        ever(cartController.cartItems, (_) {
          cartItemsCount.value = cartController.cartItems.length;
        });
        _cartListenerSet = true;
      }
    } else {
      cartItemsCount.value = 0;
    }
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

    // Add order items to cart after menu items are processed
    if (currentOrder.value != null) {
      _addOrderItemsToCart();
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
          } catch (_) {
            // Error parsing menu items - silently fail
          }
        }
      }
    } on ApiException catch (_) {
      isLoading.value = false;
      // Error loading menu items - silently fail
    } catch (_) {
      isLoading.value = false;
      // Error loading menu items - silently fail
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
    final categoryIndex = mostVisible.first.index - categoryOffset;

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

    isCategorySticky.value = mostVisible.first.index > (categoryOffset - 1);
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
        index: categoryIndex + categoryOffset,
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

  // Add item to cart
  void addItemToCart(
    Items item, {
    Variations? selectedVariation,
    List<Options>? selectedExtras,
  }) {
    try {
      // Get or create cart controller
      CartScreenController cartController;
      if (Get.isRegistered<CartScreenController>()) {
        cartController = Get.find<CartScreenController>();
      } else {
        // Initialize cart controller if not already registered
        Get.put(CartScreenController(), permanent: true);
        cartController = Get.find<CartScreenController>();
      }

      // Get base price
      String basePrice = '0';

      if (selectedVariation != null) {
        if (hasTable) {
          // If table is selected, use only base price
          basePrice = selectedVariation.price ?? '0';
        } else {
          // If no table, use price based on order type
          if (selectedOrderType.value == 'Pickup') {
            basePrice =
                selectedVariation.onlinePrice ?? selectedVariation.price ?? '0';
          } else {
            basePrice =
                selectedVariation.takeAwayPrice ??
                selectedVariation.price ??
                '0';
          }
        }
      } else {
        if (hasTable) {
          // If table is selected, use only base price
          basePrice = item.price ?? '0';
        } else {
          // If no table, use price based on order type
          if (selectedOrderType.value == 'Pickup') {
            basePrice = item.onlinePrice ?? item.price ?? '0';
          } else {
            basePrice = item.takeAwayPrice ?? item.price ?? '0';
          }
        }
      }

      // Calculate extras price
      double extrasPrice = 0.0;
      List<Map<String, dynamic>> extrasList = [];
      if (selectedExtras != null && selectedExtras.isNotEmpty) {
        for (var extra in selectedExtras) {
          if (extra.isSelected.value) {
            final extraPrice = double.tryParse(extra.price ?? '0') ?? 0.0;
            extrasPrice += extraPrice;
            extrasList.add({
              'id': extra.id,
              'name': extra.name,
              'price': extra.price,
            });
          }
        }
      }

      // Calculate total price
      final basePriceDouble = double.tryParse(basePrice) ?? 0.0;
      final totalPrice = basePriceDouble + extrasPrice;

      // Get selected extras as Options list
      List<Options>? selectedExtrasList;
      if (selectedExtras != null && selectedExtras.isNotEmpty) {
        selectedExtrasList =
            selectedExtras.where((extra) => extra.isSelected.value).toList();
      }

      // Create a copy of the item for cart with cart-specific data
      final cartItem = Items(
        id: item.id,
        itemName: item.itemName,
        itemNumber: item.itemNumber,
        description: item.description,
        imageUrl: item.imageUrl,
        type: item.type,
        inStock: item.inStock,
        price: item.price,
        onlinePrice: item.onlinePrice,
        takeAwayPrice: item.takeAwayPrice,
        category: item.category,
        variations: item.variations,
        modifierGroups: item.modifierGroups,
        variationsCount: item.variationsCount,
        modifierGroupsCount: item.modifierGroupsCount,
        taxes: item.taxes,
      );

      // Set cart-specific fields
      cartItem.cartItemId =
          '${item.id}_${selectedVariation?.id ?? 'no_var'}_${DateTime.now().millisecondsSinceEpoch}';
      cartItem.selectedVariation = selectedVariation;
      cartItem.selectedExtras =
          selectedExtrasList?.isNotEmpty == true ? selectedExtrasList : null;
      cartItem.quantity.value = 1;
      cartItem.cartTotalPrice = totalPrice;
      cartItem.cartOrderType = selectedOrderType.value;
      cartItem.cartNote = '';
      cartItem.cartNoteDraft = '';
      cartItem.cartEditingNote = false;

      cartController.addToCart(cartItem);

      // Update cart count
      _updateCartCount();
    } catch (_) {
      // Error adding item to cart - silently fail
    }
  }

  void showItemVariationsBottomSheet(Items item) {
    if (item.variations == null || item.variations!.isEmpty) {
      if (item.modifierGroups != null && item.modifierGroups!.isNotEmpty) {
        showItemExtrasBottomSheet(item);
      } else {
        // No variations and no extras - add directly to cart
        addItemToCart(item);
      }
      return;
    }

    // Reset all variations' selected to false
    if (item.variations != null) {
      for (var variation in item.variations!) {
        variation.selected.value = false;
      }
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

        // Reset all options' isSelected to false
        if (item.modifierGroups![i].options != null) {
          for (var option in item.modifierGroups![i].options!) {
            option.isSelected.value = false;
          }
        }
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

                    if (hasTable) {
                      // If table is selected, show only base price
                      price = variation.price ?? '0';
                    } else {
                      // If no table, show price based on order type
                      if (selectedOrderType.value == 'Pickup') {
                        price = variation.onlinePrice ?? variation.price ?? '0';
                      } else {
                        price =
                            variation.takeAwayPrice ?? variation.price ?? '0';
                      }
                    }

                    String formattedPrice = CurrencyFormatter.formatPrice(
                      price,
                    );

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
                                  // Unselect all other variations in this item
                                  if (item.variations != null) {
                                    for (var v in item.variations!) {
                                      if (v.id != variation.id) {
                                        v.selected.value = false;
                                      }
                                    }
                                  }
                                  // Select current variation
                                  variation.selected.value = true;

                                  Get.back();
                                  if (item.modifierGroups != null &&
                                      item.modifierGroups!.isNotEmpty) {
                                    showItemExtrasBottomSheet(
                                      item,
                                      selectedVariation: variation,
                                    );
                                  } else {
                                    addItemToCart(
                                      item,
                                      selectedVariation: variation,
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
                              fontSize: MySize.getHeight(12),
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
                            // Get selected variation if any
                            Variations? selectedVariation;
                            if (item.variations != null) {
                              for (var v in item.variations!) {
                                if (v.selected.value) {
                                  selectedVariation = v;
                                  break;
                                }
                              }
                            }

                            Get.back();

                            // If item has extras, show extras sheet
                            if (item.modifierGroups != null &&
                                item.modifierGroups!.isNotEmpty) {
                              showItemExtrasBottomSheet(
                                item,
                                selectedVariation: selectedVariation,
                              );
                            } else {
                              // No extras, add directly to cart
                              addItemToCart(
                                item,
                                selectedVariation: selectedVariation,
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
                                String price = option.price ?? '0';

                                String formattedPrice =
                                    CurrencyFormatter.formatPrice(price);

                                return Obx(
                                  () => Container(
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
                                                // Unselect all other options in this group first
                                                for (var opt in options) {
                                                  if (opt.id != option.id) {
                                                    opt.isSelected.value =
                                                        false;
                                                  }
                                                }
                                                // Toggle current option
                                                option.isSelected.value =
                                                    !option.isSelected.value;

                                                // Sync with selectedOptions map
                                                if (option.isSelected.value) {
                                                  selectedOptions[index] = {
                                                    option.id!,
                                                  };
                                                } else {
                                                  selectedOptions[index] =
                                                      <int>{};
                                                }
                                              },
                                              child: Container(
                                                width: MySize.getWidth(20),
                                                height: MySize.getHeight(20),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        option.isSelected.value
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
                                                      option.isSelected.value
                                                          ? ColorConstants
                                                              .primaryColor
                                                          : Colors.transparent,
                                                ),
                                                child:
                                                    option.isSelected.value
                                                        ? Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size:
                                                              MySize.getHeight(
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
                            // Ensure selectedVariation's selected is true if it exists
                            if (selectedVariation != null) {
                              selectedVariation.selected.value = true;
                            }

                            // Collect all selected extras
                            List<Options> selectedExtras = [];
                            if (item.modifierGroups != null) {
                              for (var modifierGroup in item.modifierGroups!) {
                                if (modifierGroup.options != null) {
                                  for (var option in modifierGroup.options!) {
                                    if (option.isSelected.value) {
                                      selectedExtras.add(option);
                                    }
                                  }
                                }
                              }
                            }

                            Get.back();

                            // Add item to cart with variation and extras
                            addItemToCart(
                              item,
                              selectedVariation: selectedVariation,
                              selectedExtras:
                                  selectedExtras.isNotEmpty
                                      ? selectedExtras
                                      : null,
                            );
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

  void _addOrderItemsToCart() {
    if (currentOrder.value?.data?.items == null ||
        currentOrder.value!.data!.items!.isEmpty ||
        menuItems.isEmpty) {
      return;
    }

    try {
      final cartController =
          Get.isRegistered<CartScreenController>()
              ? Get.find<CartScreenController>()
              : Get.put(CartScreenController(), permanent: true);

      final orderItems = currentOrder.value!.data!.items!;
      final orderType = currentOrder.value!.data!.orderType ?? 'Pickup';

      for (var orderItem in orderItems) {
        if (orderItem.isDeleted == true ||
            orderItem.isVariationDeleted == true) {
          continue;
        }

        Items? menuItem;
        try {
          menuItem = menuItems.firstWhere(
            (item) => item.itemName == orderItem.itemName,
          );
        } catch (e) {
          continue;
        }

        final cartItem = Items(
          id: menuItem.id,
          itemName: menuItem.itemName,
          itemNumber: menuItem.itemNumber,
          description: menuItem.description,
          imageUrl: menuItem.imageUrl,
          type: menuItem.type,
          inStock: menuItem.inStock,
          price: menuItem.price,
          onlinePrice: menuItem.onlinePrice,
          takeAwayPrice: menuItem.takeAwayPrice,
          category: menuItem.category,
          variations: menuItem.variations,
          modifierGroups: menuItem.modifierGroups,
          variationsCount: menuItem.variationsCount,
          modifierGroupsCount: menuItem.modifierGroupsCount,
          taxes: menuItem.taxes,
        );

        Variations? selectedVariation;
        if (orderItem.variationName != null &&
            orderItem.variationName!.isNotEmpty &&
            cartItem.variations != null) {
          try {
            selectedVariation = cartItem.variations!.firstWhere(
              (v) =>
                  v.variation?.toLowerCase() ==
                  orderItem.variationName!.toLowerCase(),
            );
          } catch (e) {
            selectedVariation = null;
          }
        }

        List<Options>? selectedExtras;
        if (orderItem.modifiers != null &&
            orderItem.modifiers!.isNotEmpty &&
            cartItem.modifierGroups != null) {
          selectedExtras = [];
          for (var orderModifier in orderItem.modifiers!) {
            for (var modifierGroup in cartItem.modifierGroups!) {
              if (modifierGroup.options != null) {
                try {
                  final option = modifierGroup.options!.firstWhere(
                    (opt) =>
                        opt.id == orderModifier.id ||
                        opt.name?.toLowerCase() ==
                            orderModifier.name?.toLowerCase(),
                  );
                  final selectedOption = Options(
                    id: option.id,
                    name: option.name,
                    price: orderModifier.price ?? option.price,
                    isAvailable: option.isAvailable,
                  );
                  selectedOption.isSelected.value = true;
                  selectedExtras.add(selectedOption);
                  break;
                } catch (e) {}
              }
            }
          }
        }

        String basePrice = '0';
        if (selectedVariation != null) {
          basePrice =
              hasTable
                  ? (selectedVariation.price ?? '0')
                  : (orderType == 'Pickup'
                      ? (selectedVariation.onlinePrice ??
                          selectedVariation.price ??
                          '0')
                      : (selectedVariation.takeAwayPrice ??
                          selectedVariation.price ??
                          '0'));
        } else {
          basePrice =
              hasTable
                  ? (cartItem.price ?? '0')
                  : (orderType == 'Pickup'
                      ? (cartItem.onlinePrice ?? cartItem.price ?? '0')
                      : (cartItem.takeAwayPrice ?? cartItem.price ?? '0'));
        }

        double extrasPrice = 0.0;
        if (selectedExtras != null && selectedExtras.isNotEmpty) {
          for (var extra in selectedExtras) {
            extrasPrice += double.tryParse(extra.price ?? '0') ?? 0.0;
          }
        }

        final totalPrice = (double.tryParse(basePrice) ?? 0.0) + extrasPrice;

        cartItem.cartItemId =
            '${cartItem.id}_${selectedVariation?.id ?? 'no_var'}_${DateTime.now().millisecondsSinceEpoch}';
        cartItem.selectedVariation = selectedVariation;
        cartItem.selectedExtras =
            selectedExtras?.isNotEmpty == true ? selectedExtras : null;
        cartItem.quantity.value = orderItem.quantity ?? 1;
        cartItem.cartTotalPrice = totalPrice;
        cartItem.cartOrderType = orderType;
        cartItem.cartNote = '';
        cartItem.cartNoteDraft = '';
        cartItem.cartEditingNote = false;
        // Store kot_item_id for items loaded from existing order
        cartItem.cartKotItemId = orderItem.kotItemId;

        // For existing order items, also check cartKotItemId when finding duplicates
        // Items with same menu item but different kot_item_id should not be merged
        Items? existingItem;
        if (cartItem.cartKotItemId != null) {
          // Find item with same menu item, variation, extras AND same kot_item_id
          for (var item in cartController.cartItems) {
            if (item.id != cartItem.id) continue;

            // Check variation
            final existingVariationId = item.selectedVariation?.id;
            final newVariationId = cartItem.selectedVariation?.id;
            if (existingVariationId != newVariationId) continue;

            // Check extras
            final existingExtras = item.selectedExtras;
            final newExtras = cartItem.selectedExtras;
            bool extrasMatch = false;
            if ((existingExtras == null || existingExtras.isEmpty) &&
                (newExtras == null || newExtras.isEmpty)) {
              extrasMatch = true;
            } else if (existingExtras != null &&
                newExtras != null &&
                existingExtras.length == newExtras.length) {
              final existingExtrasIds =
                  existingExtras.map((e) => e.id).toList()..sort();
              final newExtrasIds = newExtras.map((e) => e.id).toList()..sort();
              extrasMatch = true;
              for (int i = 0; i < existingExtrasIds.length; i++) {
                if (existingExtrasIds[i] != newExtrasIds[i]) {
                  extrasMatch = false;
                  break;
                }
              }
            }
            if (!extrasMatch) continue;

            // Check kot_item_id - must match for items from existing order
            if (item.cartKotItemId == cartItem.cartKotItemId) {
              existingItem = item;
              break;
            }
          }
        } else {
          // If no kot_item_id, use regular findExistingCartItem
          existingItem = cartController.findExistingCartItem(cartItem);
        }

        if (existingItem != null) {
          existingItem.quantity.value =
              existingItem.quantity.value + cartItem.quantity.value;
          cartController.cartItems.refresh();
        } else {
          cartController.addToCart(cartItem);
        }
      }

      _updateCartCount();
      _applyOrderDiscount(cartController);
    } catch (_) {
      // Error loading order items - silently fail
    }
  }

  void _applyOrderDiscount(CartScreenController cartController) {
    try {
      final orderTotals = currentOrder.value?.data?.totals;
      if (orderTotals == null) return;

      final discountAmountString = orderTotals.discountAmount ?? '0';
      final discountAmount =
          double.tryParse(discountAmountString.replaceAll(',', '.')) ?? 0.0;
      if (discountAmount <= 0) return;

      final subTotal = double.tryParse(orderTotals.subTotal ?? '0') ?? 0.0;
      final total = subTotal > 0 ? subTotal : cartController.totalPrice;

      if (total <= 0) {
        cartController.setDiscount(discountAmount, 'Fixed');
        return;
      }

      final discountPercent = (discountAmount / total) * 100;
      final roundedPercent = discountPercent.round();
      final isPercentDiscount = (discountPercent - roundedPercent).abs() < 0.1;

      if (isPercentDiscount && roundedPercent > 0 && roundedPercent <= 100) {
        cartController.setDiscount(roundedPercent.toDouble(), 'Percent');
      } else {
        cartController.setDiscount(discountAmount, 'Fixed');
      }
    } catch (e) {
      print('Error applying discount: $e');
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
