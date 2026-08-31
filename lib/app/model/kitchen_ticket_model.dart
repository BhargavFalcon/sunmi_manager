class KitchenTicketResponse {
  bool? success;
  List<KitchenTicket>? data;

  KitchenTicketResponse({this.success, this.data});

  KitchenTicketResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <KitchenTicket>[];
      json['data'].forEach((v) {
        data!.add(KitchenTicket.fromJson(v));
      });
    }
  }
}

class KitchenTicket {
  int? id;
  String? kotNumber;
  String? status;
  String? note;
  String? createdAt;
  List<KitchenTicketItem>? items;
  KitchenTicketOrder? order;

  KitchenTicket({
    this.id,
    this.kotNumber,
    this.status,
    this.note,
    this.createdAt,
    this.items,
    this.order,
  });

  KitchenTicket.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kotNumber = json['kot_number']?.toString();
    status = json['status'];
    note = json['note'];
    createdAt = json['created_at'];
    if (json['items'] != null) {
      items = <KitchenTicketItem>[];
      json['items'].forEach((v) {
        items!.add(KitchenTicketItem.fromJson(v));
      });
    }
    order =
        json['order'] != null
            ? KitchenTicketOrder.fromJson(json['order'])
            : null;
  }
}

class KitchenTicketItem {
  int? id;
  String? itemName;
  String? variationName;
  int? quantity;
  String? note;
  List<KitchenTicketModifier>? modifiers;

  KitchenTicketItem({
    this.id,
    this.itemName,
    this.variationName,
    this.quantity,
    this.note,
    this.modifiers,
  });

  KitchenTicketItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemName = json['item_name'] ?? json['name'];
    variationName = json['variation_name'];
    quantity = (json['quantity'] as num?)?.toInt() ?? 1;
    note = json['note'];
    if (json['modifiers'] != null) {
      modifiers = <KitchenTicketModifier>[];
      json['modifiers'].forEach((v) {
        modifiers!.add(KitchenTicketModifier.fromJson(v));
      });
    }
  }
}

class KitchenTicketModifier {
  int? id;
  String? name;

  KitchenTicketModifier({this.id, this.name});

  KitchenTicketModifier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class KitchenTicketOrder {
  int? id;
  String? orderNumber;
  String? formattedOrderNumber;
  String? orderType;
  dynamic table;
  String? note;
  String? dateTime;
  String? createdAt;

  KitchenTicketOrder({
    this.id,
    this.orderNumber,
    this.formattedOrderNumber,
    this.orderType,
    this.table,
    this.note,
    this.dateTime,
    this.createdAt,
  });

  KitchenTicketOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['order_number']?.toString();
    formattedOrderNumber = json['formatted_order_number']?.toString();
    orderType = json['order_type'];
    table = json['table'];
    note = json['note'];
    dateTime = json['date_time']?.toString();
    createdAt = json['created_at']?.toString();
  }

  String get tableLabel {
    if (table is Map) {
      return (table['table_code'] ?? table['name'] ?? '').toString();
    }
    return table?.toString() ?? '';
  }
}
