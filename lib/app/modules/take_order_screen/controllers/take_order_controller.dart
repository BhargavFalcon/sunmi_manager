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
import '../../../constants/translation_keys.dart';
import '../../../data/NetworkClient.dart';
import '../../../model/menuItemsModel.dart';
import '../../../model/tableModel.dart';
import '../../../model/getorderModel.dart' as orderModel;
import '../../../model/MobileAppModulesModel.dart';
import '../../../utils/currency_formatter.dart';
import '../../cart_screen/controllers/cart_screen_controller.dart';

class TakeOrderController extends GetxController {
  final networkClient = NetworkClient();
  final isLoading = false.obs;
  final RxList<Items> menuItems = <Items>[].obs;

  RxString selectedOrderType = 'Delivery'.obs;
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
  final RxMap<int, bool> modifierErrors = <int, bool>{}.obs;

  RxInt cartItemsCount = 0.obs;
  final RxBool showAccessDialog = false.obs;
  bool _cartListenerSet = false;

  final Rx<Tables?> selectedTable = Rx<Tables?>(null);

  final Rx<orderModel.GetOrderModel?> currentOrder =
      Rx<orderModel.GetOrderModel?>(null);

  String? sourceScreen;

  bool get hasTable => selectedTable.value != null;

  int get categoryOffset => hasTable ? 1 : 2;

  @override
  void onInit() {
    super.onInit();
    _checkAndShowDialog();
    _fetchTableFromArguments();
    _fetchOrderFromArguments();
    _fetchSourceScreenFromArguments();
    loadMenuItemsFromStorage();
    _updateCartCount();

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    itemPositionsListener.itemPositions.addListener(_onScrollPositionChanged);
  }

  void _checkAndShowDialog() {
    try {
      final modulesData = box.read(ArgumentConstant.mobileAppModulesKey);
      if (modulesData != null && modulesData is Map<String, dynamic>) {
        final modulesModel = MobileAppModulesModel.fromJson(modulesData);
        final modules = modulesModel.data?.modules ?? [];
        if (!modules.contains('POS')) {
          Future.delayed(const Duration(milliseconds: 100), () {
            showAccessDialog.value = true;
          });
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _fetchTableFromArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      final table = arguments[ArgumentConstant.tableKey];
      if (table != null && table is Tables) {
        selectedTable.value = table;
        selectedOrderType.value = 'Dine In';
      }
    }
  }

  void _fetchOrderFromArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      final order = arguments[ArgumentConstant.orderKey];
      if (order != null && order is orderModel.GetOrderModel) {
        currentOrder.value = order;
      }
    }
  }

  void _fetchSourceScreenFromArguments() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      final sourceScreenValue = arguments[ArgumentConstant.sourceScreenKey];
      sourceScreen = sourceScreenValue is String ? sourceScreenValue : null;
    }
  }

  void _updateCartCount() {
    if (Get.isRegistered<CartScreenController>()) {
      final cartController = Get.find<CartScreenController>();
      cartItemsCount.value = cartController.cartItems.length;

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
    } catch (e) {}
  }

  void _processMenuItems() {
    final newGroupedItems = <String, List<Map<String, dynamic>>>{};
    categoryIndexMap.clear();

    for (Items item in menuItems) {
      final categoryName =
          item.category?.categoryName ?? TranslationKeys.uncategorized.tr;
      final amountString = item.pickupPrice ?? item.deliveryPrice ?? '0';
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
          } catch (e) {}
        }
      }
    } catch (e) {
      isLoading.value = false;
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
    } catch (e) {}
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
    } catch (e) {}
  }

  String _getItemPrice(Items item, Variations? selectedVariation) {
    final orderType = selectedOrderType.value;

    if (selectedVariation != null) {
      if (orderType == 'Pickup') {
        return selectedVariation.onlinePrice ?? selectedVariation.price ?? '0';
      } else if (orderType == 'Delivery') {
        return selectedVariation.takeAwayPrice ??
            selectedVariation.price ??
            '0';
      } else if (orderType == 'Dine In') {
        return selectedVariation.price ?? '0';
      } else {
        return selectedVariation.price ?? '0';
      }
    } else {
      if (orderType == 'Pickup') {
        return item.pickupPrice ?? '0';
      } else if (orderType == 'Delivery') {
        return item.deliveryPrice ?? '0';
      } else if (orderType == 'Dine In') {
        return item.dineInPrice ?? '0';
      } else {
        return item.pickupPrice ?? item.deliveryPrice ?? '0';
      }
    }
  }

  void addItemToCart(
    Items item, {
    Variations? selectedVariation,
    List<Options>? selectedExtras,
  }) {
    try {
      CartScreenController cartController;
      if (Get.isRegistered<CartScreenController>()) {
        cartController = Get.find<CartScreenController>();
      } else {
        Get.put(CartScreenController(), permanent: true);
        cartController = Get.find<CartScreenController>();
      }

      final basePrice = _getItemPrice(item, selectedVariation);

      double extrasPrice = 0.0;
      if (selectedExtras != null && selectedExtras.isNotEmpty) {
        for (var extra in selectedExtras) {
          if (extra.isSelected.value) {
            extrasPrice += double.tryParse(extra.price ?? '0') ?? 0.0;
          }
        }
      }

      final basePriceDouble = double.tryParse(basePrice) ?? 0.0;
      final totalPrice = basePriceDouble + extrasPrice;

      List<Options>? selectedExtrasList;
      if (selectedExtras != null && selectedExtras.isNotEmpty) {
        selectedExtrasList =
            selectedExtras.where((extra) => extra.isSelected.value).toList();
      }

      final cartItem = Items(
        id: item.id,
        itemName: item.itemName,
        itemNumber: item.itemNumber,
        description: item.description,
        imageUrl: item.imageUrl,
        type: item.type,
        inStock: item.inStock,
        dineInPrice: item.dineInPrice,
        pickupPrice: item.pickupPrice,
        deliveryPrice: item.deliveryPrice,
        category: item.category,
        variations: item.variations,
        modifierGroups: item.modifierGroups,
        variationsCount: item.variationsCount,
        modifierGroupsCount: item.modifierGroupsCount,
        taxes: item.taxes,
      );

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

      _updateCartCount();
    } catch (_) {}
  }

  void showItemVariationsBottomSheet(Items item) {
    if (item.variations == null || item.variations!.isEmpty) {
      if (item.modifierGroups != null && item.modifierGroups!.isNotEmpty) {
        showItemExtrasBottomSheet(item);
      } else {
        addItemToCart(item);
      }
      return;
    }

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
    modifierErrors.clear();

    if (item.modifierGroups != null) {
      for (int i = 0; i < item.modifierGroups!.length; i++) {
        expandedSections[i] = true;
        selectedOptions[i] = <int>{};
        modifierErrors[i] = false;

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
                    TranslationKeys.itemVariations.tr,
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
                                    item.itemName ?? TranslationKeys.item.tr,
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
                            TranslationKeys.itemName.tr.toUpperCase(),
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
                            TranslationKeys.priceHeader.tr,
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
                            TranslationKeys.action.tr,
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

                    final orderType = selectedOrderType.value;
                    if (orderType == 'Pickup') {
                      price = variation.onlinePrice ?? variation.price ?? '0';
                    } else if (orderType == 'Delivery') {
                      price = variation.takeAwayPrice ?? variation.price ?? '0';
                    } else if (orderType == 'Dine In') {
                      price = variation.price ?? '0';
                    } else {
                      price = variation.price ?? '0';
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
                              variation.variation ??
                                  TranslationKeys.variation.tr,
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
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    if (item.variations != null) {
                                      for (var v in item.variations!) {
                                        if (v.id != variation.id) {
                                          v.selected.value = false;
                                        }
                                      }
                                    }
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
                                  child: Container(
                                    width: MySize.getWidth(20),
                                    height: MySize.getHeight(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            variation.selected.value
                                                ? ColorConstants.primaryColor
                                                : Colors.grey.shade400,
                                        width: MySize.getWidth(2),
                                      ),
                                      color:
                                          variation.selected.value
                                              ? ColorConstants.primaryColor
                                              : Colors.transparent,
                                    ),
                                    child:
                                        variation.selected.value
                                            ? Icon(
                                              Icons.circle,
                                              color: Colors.white,
                                              size: MySize.getHeight(8),
                                            )
                                            : null,
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
                            TranslationKeys.close.tr,
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
                    TranslationKeys.itemExtras.tr,
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
                          item.itemName ?? TranslationKeys.item.tr,
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
                                            modifierGroup.name ??
                                                TranslationKeys.section.tr,
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
                                        TranslationKeys.optionName.tr,
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
                                        TranslationKeys.priceHeader.tr,
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
                                        TranslationKeys.select.tr.toUpperCase(),
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
                                          option.name ??
                                              TranslationKeys.option.tr,
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
                                          child: Builder(
                                            builder: (context) {
                                              final allowMultiple =
                                                  modifierGroup
                                                      .allowMultipleSelection ??
                                                  false;
                                              return Obx(
                                                () => GestureDetector(
                                                  onTap: () {
                                                    if (!allowMultiple) {
                                                      for (var opt in options) {
                                                        if (opt.id !=
                                                            option.id) {
                                                          opt.isSelected.value =
                                                              false;
                                                        }
                                                      }
                                                    }
                                                    option.isSelected.value =
                                                        !option
                                                            .isSelected
                                                            .value;

                                                    if (option
                                                            .isSelected
                                                            .value &&
                                                        modifierErrors[index] ==
                                                            true) {
                                                      modifierErrors[index] =
                                                          false;
                                                    }

                                                    if (allowMultiple) {
                                                      final currentSet =
                                                          selectedOptions[index] ??
                                                          <int>{};
                                                      if (option
                                                          .isSelected
                                                          .value) {
                                                        selectedOptions[index] =
                                                            {
                                                              ...currentSet,
                                                              option.id!,
                                                            };
                                                      } else {
                                                        currentSet.remove(
                                                          option.id,
                                                        );
                                                        selectedOptions[index] =
                                                            currentSet.isEmpty
                                                                ? <int>{}
                                                                : currentSet;
                                                      }
                                                    } else {
                                                      selectedOptions[index] =
                                                          option
                                                                  .isSelected
                                                                  .value
                                                              ? {option.id!}
                                                              : <int>{};
                                                    }
                                                  },
                                                  child: Container(
                                                    width: MySize.getWidth(20),
                                                    height: MySize.getHeight(
                                                      20,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      shape:
                                                          allowMultiple
                                                              ? BoxShape
                                                                  .rectangle
                                                              : BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            option
                                                                    .isSelected
                                                                    .value
                                                                ? ColorConstants
                                                                    .primaryColor
                                                                : Colors
                                                                    .grey
                                                                    .shade400,
                                                        width: MySize.getWidth(
                                                          2,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          allowMultiple
                                                              ? BorderRadius.circular(
                                                                MySize.getHeight(
                                                                  4,
                                                                ),
                                                              )
                                                              : null,
                                                      color:
                                                          option
                                                                  .isSelected
                                                                  .value
                                                              ? ColorConstants
                                                                  .primaryColor
                                                              : Colors
                                                                  .transparent,
                                                    ),
                                                    child:
                                                        option.isSelected.value
                                                            ? Icon(
                                                              allowMultiple
                                                                  ? Icons.check
                                                                  : Icons
                                                                      .circle,
                                                              color:
                                                                  Colors.white,
                                                              size:
                                                                  allowMultiple
                                                                      ? MySize.getHeight(
                                                                        14,
                                                                      )
                                                                      : MySize.getHeight(
                                                                        8,
                                                                      ),
                                                            )
                                                            : null,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                            if (modifierErrors[index] == true) ...[
                              SizedBox(height: MySize.getHeight(8)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: MySize.getWidth(12),
                                  vertical: MySize.getHeight(8),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(
                                    MySize.getHeight(4),
                                  ),
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: MySize.getHeight(16),
                                    ),
                                    SizedBox(width: MySize.getWidth(8)),
                                    Expanded(
                                      child: Text(
                                        TranslationKeys
                                            .pleaseChooseAtLeastOneOption
                                            .tr,
                                        style: TextStyle(
                                          fontSize: MySize.getHeight(12),
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                            TranslationKeys.close.tr,
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
                            if (selectedVariation != null) {
                              selectedVariation.selected.value = true;
                            }

                            final modifierGroups = item.modifierGroups;
                            if (modifierGroups == null ||
                                modifierGroups.isEmpty) {
                              Get.back();
                              addItemToCart(
                                item,
                                selectedVariation: selectedVariation,
                              );
                              return;
                            }

                            List<Options> selectedExtras = [];
                            modifierErrors.clear();
                            bool hasError = false;

                            for (int i = 0; i < modifierGroups.length; i++) {
                              final modifierGroup = modifierGroups[i];
                              final options = modifierGroup.options;

                              if (options == null || options.isEmpty) {
                                modifierErrors[i] = false;
                                continue;
                              }

                              final groupSelectedOptions =
                                  options
                                      .where((opt) => opt.isSelected.value)
                                      .toList();

                              selectedExtras.addAll(groupSelectedOptions);

                              if (modifierGroup.isRequired == true) {
                                modifierErrors[i] =
                                    groupSelectedOptions.isEmpty;
                                if (modifierErrors[i] == true) {
                                  hasError = true;
                                }
                              } else {
                                modifierErrors[i] = false;
                              }
                            }

                            if (hasError) {
                              return;
                            }

                            Get.back();
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
                            TranslationKeys.save.tr,
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
    final orderData = currentOrder.value?.data?.order;
    if (orderData?.items == null ||
        orderData!.items!.isEmpty ||
        menuItems.isEmpty) {
      return;
    }

    try {
      final cartController =
          Get.isRegistered<CartScreenController>()
              ? Get.find<CartScreenController>()
              : Get.put(CartScreenController(), permanent: true);

      final orderItems = orderData.items!;
      final orderType = orderData.orderType ?? 'Pickup';

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
          dineInPrice: menuItem.dineInPrice,
          pickupPrice: menuItem.pickupPrice,
          deliveryPrice: menuItem.deliveryPrice,
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
                    price:
                        orderModifier.price != null
                            ? orderModifier.price!.toString()
                            : option.price,
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

        final String basePrice =
            selectedVariation != null
                ? (orderType == 'Pickup'
                    ? (selectedVariation.onlinePrice ??
                        selectedVariation.price ??
                        '0')
                    : orderType == 'Delivery'
                    ? (selectedVariation.takeAwayPrice ??
                        selectedVariation.price ??
                        '0')
                    : selectedVariation.price ?? '0')
                : (orderType == 'Pickup'
                    ? (cartItem.pickupPrice ?? '0')
                    : orderType == 'Delivery'
                    ? (cartItem.deliveryPrice ?? '0')
                    : orderType == 'Dine In'
                    ? (cartItem.dineInPrice ?? '0')
                    : (cartItem.pickupPrice ?? cartItem.deliveryPrice ?? '0'));

        final double extrasPrice =
            selectedExtras?.isNotEmpty == true
                ? selectedExtras!
                    .map((e) => double.tryParse(e.price ?? '0') ?? 0.0)
                    .fold(0.0, (sum, price) => sum + price)
                : 0.0;

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
        cartItem.cartKotItemId = orderItem.kotItemId;

        Items? existingItem;
        if (cartItem.cartKotItemId != null) {
          for (var item in cartController.cartItems) {
            if (item.id != cartItem.id) continue;

            final existingVariationId = item.selectedVariation?.id;
            final newVariationId = cartItem.selectedVariation?.id;
            if (existingVariationId != newVariationId) continue;

            final existingExtras = item.selectedExtras;
            final newExtras = cartItem.selectedExtras;
            final bool extrasMatch =
                (existingExtras == null || existingExtras.isEmpty) &&
                        (newExtras == null || newExtras.isEmpty)
                    ? true
                    : existingExtras != null &&
                        newExtras != null &&
                        existingExtras.length == newExtras.length
                    ? (existingExtras.map((e) => e.id).toList()..sort())
                            .toString() ==
                        (newExtras.map((e) => e.id).toList()..sort()).toString()
                    : false;
            if (!extrasMatch) continue;

            if (item.cartKotItemId == cartItem.cartKotItemId) {
              existingItem = item;
              break;
            }
          }
        } else {
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
    } catch (_) {}
  }

  void _applyOrderDiscount(CartScreenController cartController) {
    try {
      final orderData = currentOrder.value?.data?.order;
      if (orderData == null) return;

      final discountType = orderData.discountType;
      final discountValue = orderData.discountValue;

      if (discountType != null &&
          discountType.isNotEmpty &&
          discountValue != null) {
        final discountValueNum = discountValue.toDouble();

        if (discountValueNum > 0) {
          final discountTypeStr = discountType.toLowerCase();
          final finalDiscountType =
              discountTypeStr == 'percent' || discountTypeStr == 'percentage'
                  ? 'Percent'
                  : 'Fixed';

          cartController.setDiscount(discountValueNum, finalDiscountType);
        }
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    searchController.dispose();
    categoryScrollController.dispose();
    stickyCategoryScrollController.dispose();
    super.onClose();
  }
}
