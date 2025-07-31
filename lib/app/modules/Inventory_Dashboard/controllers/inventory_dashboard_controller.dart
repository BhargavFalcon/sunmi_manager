import 'package:get/get.dart';

import '../../dashboard_screen/controllers/dashboard_screen_controller.dart';

class InventoryDashboardController extends GetxController {
  RxString selectedCategory = 'All Categories'.obs;
  RxString selectedTime = 'Today'.obs;

  final List<String> categoryList = [
    'All Categories',
    'Meat & Poultry',
    'Seafood',
    'Dairy & Eggs',
    'Fresh Produce',
    'Herbs & Spices',
    'Dry Goods',
    'Canned Goods',
    'Beverages',
    'Condiments & Sauces',
    'Baking Supplies',
    'Oils & Vinegars',
    'Frozen Foods',
    'Cleaning Supplies',
    'Kitchen Equipment',
    'Disposables',
  ];

  final List<String> timeList = ['Today', 'This Week', 'This Month'];

  RxList<LowStockItem> lowStockItems =
      <LowStockItem>[
        LowStockItem(
          name: 'Lettuce',
          category: 'Fresh Produce',
          current: 1,
          threshold: 20,
        ),
        LowStockItem(
          name: 'Tomato',
          category: 'Fresh Produce',
          current: 5,
          threshold: 15,
        ),
      ].obs;

  final List<Map<String, String>> inventoryItems = [
    {
      'name': 'Tomatoes',
      'category': 'Fresh Produce',
      'usage': '30 kg used',
      'stock': '20 kg left',
    },
    {
      'name': 'Chicken Breast',
      'category': 'Meat & Poultry',
      'usage': '10 kg used',
      'stock': '15 kg left',
    },
    {
      'name': 'Olive Oil',
      'category': 'Oils & Vinegars',
      'usage': '2 L used',
      'stock': '3 L left',
    },
    {
      'name': 'Basmati Rice',
      'category': 'Dry Goods',
      'usage': '50 kg used',
      'stock': '10 kg left',
    },
  ];

  final List<Map<String, String>> usageStockItems = [
    {
      'name': 'Heavy Cream',
      'category': 'Dairy & Eggs',
      'status': 'In Stock',
      'currentStock': '12.5 L',
      'usage': '0 dz',
      'stockAdded': '31.00 L',
    },
    {
      'name': 'Eggs',
      'category': 'Dairy & Eggs',
      'status': 'In Stock',
      'currentStock': '24 dz',
      'usage': '0 dz',
      'stockAdded': '222.00 dz',
    },
    {
      'name': 'Pancer',
      'category': 'Dairy & Eggs',
      'status': 'In Stock',
      'currentStock': '20 kg',
      'usage': '0 kg',
      'stockAdded': '20.00 kg',
    },
    {
      'name': 'Lettuce',
      'category': 'Fresh Produce',
      'status': 'In Stock',
      'currentStock': '~23 pc',
      'usage': '0 pc',
      'stockAdded': '45.00 pc',
    },
    {
      'name': 'Ground Black Pepper',
      'category': 'Herbs & Spices',
      'status': 'In Stock',
      'currentStock': '1553 g',
      'usage': '0 g',
      'stockAdded': '2060.00 g',
    },
    {
      'name': 'Basmati Rice',
      'category': 'Dry Goods',
      'status': 'In Stock',
      'currentStock': '61.5 kg',
      'usage': '0 kg',
      'stockAdded': '70.00 kg',
    },
    {
      'name': 'Ata',
      'category': 'Fresh Produce',
      'status': 'In Stock',
      'currentStock': '38 kg',
      'usage': '0 kg',
      'stockAdded': '40.00 kg',
    },
  ];
}
