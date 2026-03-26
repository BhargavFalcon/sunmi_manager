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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class KitchenTicket {
  int? id;
  String? kotNumber;
  String? status;
  String? note;
  int? cancelReasonId;
  String? cancelReasonText;
  String? createdAt;
  List<KitchenTicketItem>? items;
  KitchenTicketOrder? order;
  dynamic cancelReason;

  KitchenTicket({
    this.id,
    this.kotNumber,
    this.status,
    this.note,
    this.cancelReasonId,
    this.cancelReasonText,
    this.createdAt,
    this.items,
    this.order,
    this.cancelReason,
  });

  KitchenTicket.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kotNumber = json['kot_number']?.toString();
    status = json['status'];
    note = json['note'];
    cancelReasonId = json['cancel_reason_id'];
    cancelReasonText = json['cancel_reason_text'];
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
    cancelReason = json['cancel_reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['kot_number'] = kotNumber;
    data['status'] = status;
    data['note'] = note;
    data['cancel_reason_id'] = cancelReasonId;
    data['cancel_reason_text'] = cancelReasonText;
    data['created_at'] = createdAt;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (order != null) {
      data['order'] = order!.toJson();
    }
    data['cancel_reason'] = cancelReason;
    return data;
  }
}

class KitchenTicketItem {
  int? id;
  String? itemName;
  String? itemNumber;
  String? variationName;
  List<KitchenTicketModifier>? modifiers;
  int? quantity;
  num? price;
  num? amount;
  String? note;
  String? status;
  String? foodReady;
  num? taxAmount;
  num? taxPercentage;
  Map<String, dynamic>? taxBreakup;

  KitchenTicketItem({
    this.id,
    this.itemName,
    this.itemNumber,
    this.variationName,
    this.modifiers,
    this.quantity,
    this.price,
    this.amount,
    this.note,
    this.status,
    this.foodReady,
    this.taxAmount,
    this.taxPercentage,
    this.taxBreakup,
  });

  KitchenTicketItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemName = json['item_name'];
    itemNumber = json['item_number']?.toString();
    variationName = json['variation_name'];
    if (json['modifiers'] != null) {
      modifiers = <KitchenTicketModifier>[];
      json['modifiers'].forEach((v) {
        modifiers!.add(KitchenTicketModifier.fromJson(v));
      });
    }
    quantity = json['quantity'];
    price = json['price'];
    amount = json['amount'];
    note = json['note'];
    status = json['status'];
    foodReady = json['food_ready']?.toString();
    taxAmount = json['tax_amount'];
    taxPercentage = json['tax_percentage'];
    taxBreakup = json['tax_breakup'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_name'] = itemName;
    data['item_number'] = itemNumber;
    data['variation_name'] = variationName;
    if (modifiers != null) {
      data['modifiers'] = modifiers!.map((v) => v.toJson()).toList();
    }
    data['quantity'] = quantity;
    data['price'] = price;
    data['amount'] = amount;
    data['note'] = note;
    data['status'] = status;
    data['food_ready'] = foodReady;
    data['tax_amount'] = taxAmount;
    data['tax_percentage'] = taxPercentage;
    data['tax_breakup'] = taxBreakup;
    return data;
  }
}

class KitchenTicketModifier {
  int? id;
  String? name;
  String? price;

  KitchenTicketModifier({this.id, this.name, this.price});

  KitchenTicketModifier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}

class KitchenTicketOrder {
  int? id;
  String? uuid;
  String? orderNumber;
  String? formattedOrderNumber;
  String? status;
  String? orderType;
  int? numberOfPax;
  String? note;
  dynamic table;
  KitchenTicketWaiter? waiter;

  KitchenTicketOrder({
    this.id,
    this.uuid,
    this.orderNumber,
    this.formattedOrderNumber,
    this.status,
    this.orderType,
    this.numberOfPax,
    this.note,
    this.table,
    this.waiter,
  });

  KitchenTicketOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    orderNumber = json['order_number']?.toString();
    formattedOrderNumber = json['formatted_order_number'];
    status = json['status'];
    orderType = json['order_type'];
    numberOfPax = json['number_of_pax'];
    note = json['note'];
    table = json['table'];
    waiter =
        json['waiter'] != null
            ? KitchenTicketWaiter.fromJson(json['waiter'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['order_number'] = orderNumber;
    data['formatted_order_number'] = formattedOrderNumber;
    data['status'] = status;
    data['order_type'] = orderType;
    data['number_of_pax'] = numberOfPax;
    data['note'] = note;
    data['table'] = table;
    if (waiter != null) {
      data['waiter'] = waiter!.toJson();
    }
    return data;
  }
}

class KitchenTicketWaiter {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? phoneCode;
  int? branchId;
  int? restaurantId;

  KitchenTicketWaiter({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.phoneCode,
    this.branchId,
    this.restaurantId,
  });

  KitchenTicketWaiter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number']?.toString();
    phoneCode = json['phone_code']?.toString();
    branchId = json['branch_id'];
    restaurantId = json['restaurant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['phone_code'] = phoneCode;
    data['branch_id'] = branchId;
    data['restaurant_id'] = restaurantId;
    return data;
  }
}
