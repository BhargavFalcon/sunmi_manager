import 'package:get/get.dart';

class CartScreenController extends GetxController {
  // Sample cart items - 50 unique products
  RxList<Map<String, dynamic>> cartItems =
      <Map<String, dynamic>>[
        {
          'id': '1',
          'name': 'Biscuit Breakfast',
          'price': 150.0,
          'quantity': 1,
          'tableNumber': 'B1',
          'variantName': 'Butter',
          'variantPrice': 20.0,
        },
        {
          'id': '2',
          'name': 'Coffee',
          'price': 80.0,
          'quantity': 2,
          'tableNumber': 'B1',
          'variantName': 'Vanilla Shot',
          'variantPrice': 30.0,
        },
        {
          'id': '3',
          'name': 'Chicken Biryani',
          'price': 320.0,
          'quantity': 1,
          'tableNumber': 'A2',
        },
        {
          'id': '4',
          'name': 'Mutton Curry',
          'price': 450.0,
          'quantity': 1,
          'tableNumber': 'A2',
        },
        {
          'id': '5',
          'name': 'Paneer Butter Masala',
          'price': 280.0,
          'quantity': 2,
          'tableNumber': 'B3',
          'variantName': 'Extra Paneer',
          'variantPrice': 40.0,
        },
        {
          'id': '6',
          'name': 'Dal Makhani',
          'price': 180.0,
          'quantity': 1,
          'tableNumber': 'B3',
        },
        {
          'id': '7',
          'name': 'Naan Bread',
          'price': 25.0,
          'quantity': 4,
          'tableNumber': 'C1',
        },
        {
          'id': '8',
          'name': 'Roti',
          'price': 15.0,
          'quantity': 6,
          'tableNumber': 'C1',
        },
        {
          'id': '9',
          'name': 'Rice',
          'price': 120.0,
          'quantity': 2,
          'tableNumber': 'C2',
        },
        {
          'id': '10',
          'name': 'Chicken Tikka',
          'price': 350.0,
          'quantity': 1,
          'tableNumber': 'C2',
          'variantName': 'Leg Piece',
          'variantPrice': 60.0,
        },
        {
          'id': '11',
          'name': 'Fish Curry',
          'price': 380.0,
          'quantity': 1,
          'tableNumber': 'D1',
        },
        {
          'id': '12',
          'name': 'Prawn Masala',
          'price': 420.0,
          'quantity': 1,
          'tableNumber': 'D1',
        },
        {
          'id': '13',
          'name': 'Vegetable Soup',
          'price': 90.0,
          'quantity': 2,
          'tableNumber': 'D2',
        },
        {
          'id': '14',
          'name': 'Chicken Soup',
          'price': 120.0,
          'quantity': 1,
          'tableNumber': 'D2',
        },
        {
          'id': '15',
          'name': 'Samosa',
          'price': 20.0,
          'quantity': 8,
          'tableNumber': 'E1',
        },
        {
          'id': '16',
          'name': 'Pakora',
          'price': 30.0,
          'quantity': 6,
          'tableNumber': 'E1',
        },
        {
          'id': '17',
          'name': 'Chicken Wings',
          'price': 250.0,
          'quantity': 2,
          'tableNumber': 'E2',
        },
        {
          'id': '18',
          'name': 'French Fries',
          'price': 80.0,
          'quantity': 3,
          'tableNumber': 'E2',
        },
        {
          'id': '19',
          'name': 'Onion Rings',
          'price': 70.0,
          'quantity': 2,
          'tableNumber': 'F1',
        },
        {
          'id': '20',
          'name': 'Chicken Burger',
          'price': 180.0,
          'quantity': 1,
          'tableNumber': 'F1',
        },
        {
          'id': '21',
          'name': 'Veg Burger',
          'price': 150.0,
          'quantity': 2,
          'tableNumber': 'F2',
          'variantName': 'Cheese Slice',
          'variantPrice': 25.0,
        },
        {
          'id': '22',
          'name': 'Pizza Margherita',
          'price': 300.0,
          'quantity': 1,
          'tableNumber': 'F2',
        },
        {
          'id': '23',
          'name': 'Pizza Pepperoni',
          'price': 350.0,
          'quantity': 1,
          'tableNumber': 'G1',
        },
        {
          'id': '24',
          'name': 'Pasta Alfredo',
          'price': 280.0,
          'quantity': 1,
          'tableNumber': 'G1',
          'variantName': 'Mushrooms',
          'variantPrice': 35.0,
        },
        {
          'id': '25',
          'name': 'Pasta Arrabbiata',
          'price': 260.0,
          'quantity': 1,
          'tableNumber': 'G2',
        },
        {
          'id': '26',
          'name': 'Caesar Salad',
          'price': 200.0,
          'quantity': 1,
          'tableNumber': 'G2',
        },
        {
          'id': '27',
          'name': 'Greek Salad',
          'price': 180.0,
          'quantity': 1,
          'tableNumber': 'H1',
          'details': '5" (480 grams)',
        },
        {
          'id': '28',
          'name': 'Chicken Salad',
          'price': 220.0,
          'quantity': 1,
          'tableNumber': 'H1',
        },
        {
          'id': '29',
          'name': 'Fruit Salad',
          'price': 120.0,
          'quantity': 2,
          'tableNumber': 'H2',
        },
        {
          'id': '30',
          'name': 'Ice Cream Vanilla',
          'price': 60.0,
          'quantity': 3,
          'tableNumber': 'H2',
          'variantName': 'Choco Chips',
          'variantPrice': 15.0,
        },
        {
          'id': '31',
          'name': 'Ice Cream Chocolate',
          'price': 70.0,
          'quantity': 2,
          'tableNumber': 'I1',
        },
        {
          'id': '32',
          'name': 'Ice Cream Strawberry',
          'price': 65.0,
          'quantity': 1,
          'tableNumber': 'I1',
        },
        {
          'id': '33',
          'name': 'Cake Chocolate',
          'price': 150.0,
          'quantity': 1,
          'tableNumber': 'I2',
          // Example variant to showcase chip between title and note
          'variantName': 'Vanilla',
          'variantPrice': 50.0,
        },
        {
          'id': '34',
          'name': 'Cake Vanilla',
          'price': 140.0,
          'quantity': 1,
          'tableNumber': 'I2',
        },
        {
          'id': '35',
          'name': 'Cake Red Velvet',
          'price': 180.0,
          'quantity': 1,
          'tableNumber': 'J1',
        },
        {
          'id': '36',
          'name': 'Tiramisu',
          'price': 200.0,
          'quantity': 1,
          'tableNumber': 'J1',
        },
        {
          'id': '37',
          'name': 'Cheesecake',
          'price': 160.0,
          'quantity': 1,
          'tableNumber': 'J2',
        },
        {
          'id': '38',
          'name': 'Brownie',
          'price': 80.0,
          'quantity': 2,
          'tableNumber': 'J2',
        },
        {
          'id': '39',
          'name': 'Muffin Blueberry',
          'price': 50.0,
          'quantity': 4,
          'tableNumber': 'K1',
        },
        {
          'id': '40',
          'name': 'Muffin Chocolate',
          'price': 55.0,
          'quantity': 3,
          'tableNumber': 'K1',
        },
        {
          'id': '41',
          'name': 'Donut Glazed',
          'price': 40.0,
          'quantity': 5,
          'tableNumber': 'K2',
        },
        {
          'id': '42',
          'name': 'Donut Chocolate',
          'price': 45.0,
          'quantity': 4,
          'tableNumber': 'K2',
        },
        {
          'id': '43',
          'name': 'Croissant',
          'price': 35.0,
          'quantity': 6,
          'tableNumber': 'L1',
        },
        {
          'id': '44',
          'name': 'Sandwich Club',
          'price': 200.0,
          'quantity': 1,
          'tableNumber': 'L1',
        },
        {
          'id': '45',
          'name': 'Sandwich Veg',
          'price': 150.0,
          'quantity': 2,
          'tableNumber': 'L2',
        },
        {
          'id': '46',
          'name': 'Sandwich Chicken',
          'price': 180.0,
          'quantity': 1,
          'tableNumber': 'L2',
        },
        {
          'id': '47',
          'name': 'Wrap Veg',
          'price': 160.0,
          'quantity': 1,
          'tableNumber': 'M1',
        },
        {
          'id': '48',
          'name': 'Wrap Chicken',
          'price': 190.0,
          'quantity': 1,
          'tableNumber': 'M1',
        },
        {
          'id': '49',
          'name': 'Quesadilla',
          'price': 220.0,
          'quantity': 1,
          'tableNumber': 'M2',
        },
        {
          'id': '50',
          'name': 'Nachos',
          'price': 120.0,
          'quantity': 2,
          'tableNumber': 'M2',
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Update quantity for a specific item
  void updateItemQuantity(String itemId, int newQuantity) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['id'] == itemId) {
        cartItems[i]['quantity'] = newQuantity;
        cartItems.refresh();
        break;
      }
    }
  }

  // Remove item from cart
  void removeItem(String itemId) {
    cartItems.removeWhere((item) => item['id'] == itemId);
  }

  // Get total price
  double get totalPrice {
    double total = 0.0;
    for (var item in cartItems) {
      double price = (item['price'] as num).toDouble();
      int quantity = (item['quantity'] as num).toInt();
      total += (price * quantity);
    }
    return total;
  }

  // Get total items count
  int get totalItems {
    int total = 0;
    for (var item in cartItems) {
      total += (item['quantity'] as num).toInt();
    }
    return total;
  }

  // --- Notes handling per item ---
  void _ensureNoteFields(Map<String, dynamic> item) {
    item.putIfAbsent('note', () => '');
    item.putIfAbsent('noteDraft', () => '');
    item.putIfAbsent('editingNote', () => false);
  }

  void startEditingNote(String itemId) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['id'] == itemId) {
        final item = cartItems[i];
        _ensureNoteFields(item);
        item['noteDraft'] = (item['note'] as String?) ?? '';
        item['editingNote'] = true;
        cartItems.refresh();
        break;
      }
    }
  }

  void updateNoteDraft(String itemId, String value) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['id'] == itemId) {
        final item = cartItems[i];
        _ensureNoteFields(item);
        item['noteDraft'] = value;
        cartItems.refresh();
        break;
      }
    }
  }

  void saveNote(String itemId) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['id'] == itemId) {
        final item = cartItems[i];
        _ensureNoteFields(item);
        item['note'] = (item['noteDraft'] as String?) ?? '';
        item['editingNote'] = false;
        cartItems.refresh();
        break;
      }
    }
  }

  void cancelEditingNote(String itemId) {
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['id'] == itemId) {
        final item = cartItems[i];
        _ensureNoteFields(item);
        item['noteDraft'] = item['note'];
        item['editingNote'] = false;
        cartItems.refresh();
        break;
      }
    }
  }
}
