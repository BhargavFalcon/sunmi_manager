import 'package:get/get.dart';

class KitchenTicketItemModifier {
  final String name;

  KitchenTicketItemModifier({required this.name});
}

class KitchenTicketItem {
  final String no;
  final String itemName;
  final List<KitchenTicketItemModifier> modifiers;

  KitchenTicketItem({
    required this.no,
    required this.itemName,
    this.modifiers = const [],
  });
}

class KitchenTicketDummy {
  final String orderId;
  final String time;
  final String orderType; // 'dine_in', 'delivery', 'pickup'
  final String? tableCode; // for dine-in
  final List<KitchenTicketItem> items;
  final bool isFoodReady;

  KitchenTicketDummy({
    required this.orderId,
    required this.time,
    required this.orderType,
    this.tableCode,
    required this.items,
    this.isFoodReady = false,
  });
}

class KitchenTicketsScreenController extends GetxController {
  final tickets = <KitchenTicketDummy>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    tickets.assignAll([
      KitchenTicketDummy(
        orderId: '631',
        time: '09:14 AM',
        orderType: 'dine_in',
        tableCode: 'T5',
        items: [
          KitchenTicketItem(
            no: 'N31',
            itemName: 'The Legend',
            modifiers: [
              KitchenTicketItemModifier(name: 'Fries & Red Bull'),
            ],
          ),
          KitchenTicketItem(
            no: 'N32',
            itemName: 'Caesar Salad',
          ),
        ],
        isFoodReady: true,
      ),
      KitchenTicketDummy(
        orderId: '632',
        time: '09:22 AM',
        orderType: 'delivery',
        tableCode: null,
        items: [
          KitchenTicketItem(no: 'N41', itemName: 'Burger'),
          KitchenTicketItem(no: 'N42', itemName: 'Fries'),
        ],
        isFoodReady: false,
      ),
      KitchenTicketDummy(
        orderId: '633',
        time: '09:30 AM',
        orderType: 'pickup',
        tableCode: null,
        items: [
          KitchenTicketItem(no: 'N51', itemName: 'Chicken Wrap'),
        ],
        isFoodReady: false,
      ),
      KitchenTicketDummy(
        orderId: '634',
        time: '09:45 AM',
        orderType: 'dine_in',
        tableCode: 'T12',
        items: [
          KitchenTicketItem(no: 'N61', itemName: 'Pasta'),
          KitchenTicketItem(no: 'N62', itemName: 'Soup'),
        ],
        isFoodReady: true,
      ),
    ]);
  }

  void onPrint(KitchenTicketDummy ticket) {
    // TODO: implement print
  }

  void onFoodReady(KitchenTicketDummy ticket) {
    final idx = tickets.indexOf(ticket);
    if (idx >= 0) {
      tickets[idx] = KitchenTicketDummy(
        orderId: ticket.orderId,
        time: ticket.time,
        orderType: ticket.orderType,
        tableCode: ticket.tableCode,
        items: ticket.items,
        isFoodReady: !ticket.isFoodReady,
      );
      tickets.refresh();
    }
  }
}
