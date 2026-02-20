double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

class SplitPaymentRemainingModel {
  bool? success;
  SplitPaymentData? data;

  SplitPaymentRemainingModel({this.success, this.data});

  SplitPaymentRemainingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    data =
        json['data'] != null
            ? SplitPaymentData.fromJson(json['data'] as Map<String, dynamic>)
            : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class SplitPaymentData {
  SplitPaymentOrder? order;
  List<RemainingItem>? remainingItems;
  double? totalRemainingAmount;

  SplitPaymentData({
    this.order,
    this.remainingItems,
    this.totalRemainingAmount,
  });

  SplitPaymentData.fromJson(Map<String, dynamic> json) {
    order =
        json['order'] != null
            ? SplitPaymentOrder.fromJson(json['order'] as Map<String, dynamic>)
            : null;

    if (json['remaining_items'] != null) {
      remainingItems =
          (json['remaining_items'] as List)
              .map((e) => RemainingItem.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    final total = json['total_remaining_amount'];
    totalRemainingAmount =
        total is num
            ? total.toDouble()
            : double.tryParse(total?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (order != null) map['order'] = order!.toJson();
    if (remainingItems != null) {
      map['remaining_items'] = remainingItems!.map((e) => e.toJson()).toList();
    }
    map['total_remaining_amount'] = totalRemainingAmount;
    return map;
  }
}

class SplitPaymentOrder {
  int? id;
  String? uuid;
  String? formattedOrderNumber;
  String? status;

  SplitPaymentOrder({
    this.id,
    this.uuid,
    this.formattedOrderNumber,
    this.status,
  });

  SplitPaymentOrder.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    if (rawId is int) {
      id = rawId;
    } else {
      id = int.tryParse(rawId?.toString() ?? '');
    }
    uuid = json['uuid']?.toString();
    formattedOrderNumber = json['formatted_order_number']?.toString();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['uuid'] = uuid;
    map['formatted_order_number'] = formattedOrderNumber;
    map['status'] = status;
    return map;
  }
}

class RemainingItem {
  int? orderItemId;
  int? remainingQuantity;
  String? displayItemName;
  String? displayVariationName;
  List<DisplayModifier>? displayModifiers;
  double? unitPrice;
  double? remainingAmount;
  String? formattedPrice;
  String? formattedRemainingAmount;

  RemainingItem({
    this.orderItemId,
    this.remainingQuantity,
    this.displayItemName,
    this.displayVariationName,
    this.displayModifiers,
    this.unitPrice,
    this.remainingAmount,
    this.formattedPrice,
    this.formattedRemainingAmount,
  });

  RemainingItem.fromJson(Map<String, dynamic> json) {
    final rawOrderItemId = json['order_item_id'];
    if (rawOrderItemId is int) {
      orderItemId = rawOrderItemId;
    } else {
      orderItemId = int.tryParse(rawOrderItemId?.toString() ?? '');
    }

    final rawQty = json['remaining_quantity'];
    if (rawQty is int) {
      remainingQuantity = rawQty;
    } else {
      remainingQuantity = int.tryParse(rawQty?.toString() ?? '');
    }

    displayItemName = json['display_item_name']?.toString();
    displayVariationName = json['display_variation_name']?.toString();

    if (json['display_modifiers'] != null) {
      displayModifiers =
          (json['display_modifiers'] as List)
              .map((e) => DisplayModifier.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    unitPrice = _toDouble(json['unit_price']);
    remainingAmount = _toDouble(json['remaining_amount']);
    formattedPrice = json['formatted_price']?.toString();
    formattedRemainingAmount = json['formatted_remaining_amount']?.toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['order_item_id'] = orderItemId;
    map['remaining_quantity'] = remainingQuantity;
    map['display_item_name'] = displayItemName;
    map['display_variation_name'] = displayVariationName;
    if (displayModifiers != null) {
      map['display_modifiers'] =
          displayModifiers!.map((e) => e.toJson()).toList();
    }
    map['unit_price'] = unitPrice;
    map['remaining_amount'] = remainingAmount;
    map['formatted_price'] = formattedPrice;
    map['formatted_remaining_amount'] = formattedRemainingAmount;
    return map;
  }
}

class DisplayModifier {
  int? id;
  String? name;
  double? price;

  DisplayModifier({this.id, this.name, this.price});

  DisplayModifier.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    if (rawId is int) {
      id = rawId;
    } else {
      id = int.tryParse(rawId?.toString() ?? '');
    }
    name = json['name']?.toString();
    price = _toDouble(json['price']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['price'] = price;
    return map;
  }
}
