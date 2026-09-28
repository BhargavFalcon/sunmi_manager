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
    if (order == null && (json['order_id'] != null || json['order_uuid'] != null)) {
      order = KitchenTicketOrder(
        id: json['order_id'] is int
            ? json['order_id']
            : int.tryParse(json['order_id']?.toString() ?? ''),
        uuid: json['order_uuid']?.toString(),
      );
    } else if (order != null) {
      if (order!.uuid == null && json['order_uuid'] != null) {
        order!.uuid = json['order_uuid']?.toString();
      }
      if (order!.id == null && json['order_id'] != null) {
        order!.id = json['order_id'] is int
            ? json['order_id']
            : int.tryParse(json['order_id']?.toString() ?? '');
      }
    }
  }

  void syncOrderDetails(dynamic orderData) {
    if (orderData == null) return;
    dynamic ord;
    try {
      ord = orderData.order;
    } catch (_) {}
    if (ord == null) return;
    order ??= KitchenTicketOrder();
    order!.uuid ??= ord.uuid?.toString();
    order!.orderNumber ??=
        ord.orderNumber?.toString() ?? ord.formattedOrderNumber?.toString();
    order!.formattedOrderNumber ??= ord.formattedOrderNumber?.toString();
    if (order!.createdAt == null || order!.createdAt!.trim().isEmpty) {
      order!.createdAt = ord.createdAt?.toString();
    }
    if (order!.dateTime == null || order!.dateTime!.trim().isEmpty) {
      order!.dateTime = ord.dateTime?.toString();
    }
    if (order!.orderType == null || order!.orderType!.trim().isEmpty) {
      order!.orderType = ord.orderType?.toString();
    }
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
  String? uuid;
  String? orderNumber;
  String? formattedOrderNumber;
  String? orderType;
  String? placedVia;
  dynamic table;
  String? note;
  String? dateTime;
  String? createdAt;

  KitchenTicketOrder({
    this.id,
    this.uuid,
    this.orderNumber,
    this.formattedOrderNumber,
    this.orderType,
    this.placedVia,
    this.table,
    this.note,
    this.dateTime,
    this.createdAt,
  });

  KitchenTicketOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid']?.toString();
    orderNumber = json['order_number']?.toString();
    formattedOrderNumber = json['formatted_order_number']?.toString();
    orderType = json['order_type'];
    placedVia = json['placed_via']?.toString();
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
