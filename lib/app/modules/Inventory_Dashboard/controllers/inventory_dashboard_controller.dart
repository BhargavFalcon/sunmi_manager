import 'package:get/get.dart';

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
}
