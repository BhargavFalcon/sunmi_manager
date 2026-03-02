double? _receiptToDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? _receiptToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class ReceiptOrderResponse {
  bool? success;
  ReceiptOrderData? data;

  ReceiptOrderResponse({this.success, this.data});

  ReceiptOrderResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    data =
        json['data'] != null
            ? ReceiptOrderData.fromJson(json['data'] as Map<String, dynamic>)
            : null;
  }

  Map<String, dynamic> toJson() => {'success': success, 'data': data?.toJson()};
}

class ReceiptOrderData {
  ReceiptRestaurant? restaurant;
  ReceiptBranch? branch;
  ReceiptSettings? receiptSettings;
  ReceiptOrder? order;
  ReceiptPayment? payment;
  bool? isSplitOrder;
  ReceiptSplitOrder? splitOrder;
  List<dynamic>? items;
  List<ReceiptItemEntry>? receiptItems;
  ReceiptSummary? summary;
  String? taxMode;
  bool? taxInclusive;
  int? currencyId;
  String? imageUrl;

  ReceiptOrderData({
    this.restaurant,
    this.branch,
    this.receiptSettings,
    this.order,
    this.payment,
    this.isSplitOrder,
    this.splitOrder,
    this.items,
    this.receiptItems,
    this.summary,
    this.taxMode,
    this.taxInclusive,
    this.currencyId,
    this.imageUrl,
  });

  ReceiptOrderData.fromJson(Map<String, dynamic> json) {
    restaurant =
        json['restaurant'] != null
            ? ReceiptRestaurant.fromJson(
              json['restaurant'] as Map<String, dynamic>,
            )
            : null;
    branch =
        json['branch'] != null
            ? ReceiptBranch.fromJson(json['branch'] as Map<String, dynamic>)
            : null;
    receiptSettings =
        json['receipt_settings'] != null
            ? ReceiptSettings.fromJson(
              json['receipt_settings'] as Map<String, dynamic>,
            )
            : null;
    order =
        json['order'] != null
            ? ReceiptOrder.fromJson(json['order'] as Map<String, dynamic>)
            : null;
    payment =
        json['payment'] != null
            ? ReceiptPayment.fromJson(json['payment'] as Map<String, dynamic>)
            : null;
    isSplitOrder = json['is_split_order'] as bool?;
    splitOrder =
        json['split_order'] != null
            ? ReceiptSplitOrder.fromJson(
              json['split_order'] as Map<String, dynamic>,
            )
            : null;
    items = json['items'] as List<dynamic>?;
    if (json['receipt_items'] != null) {
      receiptItems =
          (json['receipt_items'] as List)
              .map((e) => ReceiptItemEntry.fromJson(e as Map<String, dynamic>))
              .toList();
    }
    summary =
        json['summary'] != null
            ? ReceiptSummary.fromJson(json['summary'] as Map<String, dynamic>)
            : null;
    taxMode = json['tax_mode']?.toString();
    taxInclusive = json['tax_inclusive'] as bool?;
    currencyId = _receiptToInt(json['currency_id']);
    imageUrl = json['image_url']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'restaurant': restaurant?.toJson(),
    'branch': branch?.toJson(),
    'receipt_settings': receiptSettings?.toJson(),
    'order': order?.toJson(),
    'payment': payment?.toJson(),
    'is_split_order': isSplitOrder,
    'split_order': splitOrder?.toJson(),
    'items': items,
    'receipt_items': receiptItems?.map((e) => e.toJson()).toList(),
    'summary': summary?.toJson(),
    'tax_mode': taxMode,
    'tax_inclusive': taxInclusive,
    'currency_id': currencyId,
    'image_url': imageUrl,
  };
}

class ReceiptRestaurant {
  String? name;
  String? address;
  String? phoneNumber;
  ReceiptSettingRef? receiptSetting;
  String? timezone;
  String? logoUrl;

  ReceiptRestaurant({
    this.name,
    this.address,
    this.phoneNumber,
    this.receiptSetting,
    this.timezone,
    this.logoUrl,
  });

  ReceiptRestaurant.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    address = json['address']?.toString();
    phoneNumber = json['phone_number']?.toString();
    receiptSetting =
        json['receipt_setting'] != null
            ? ReceiptSettingRef.fromJson(
              json['receipt_setting'] as Map<String, dynamic>,
            )
            : null;
    timezone = json['timezone']?.toString();
    logoUrl = json['logo_url']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'phone_number': phoneNumber,
    'receipt_setting': receiptSetting?.toJson(),
    'timezone': timezone,
    'logo_url': logoUrl,
  };
}

class ReceiptSettingRef {
  int? id;

  ReceiptSettingRef({this.id});

  ReceiptSettingRef.fromJson(Map<String, dynamic> json) {
    id = _receiptToInt(json['id']);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class ReceiptBranch {
  int? id;
  String? name;
  String? address;

  ReceiptBranch({this.id, this.name, this.address});

  ReceiptBranch.fromJson(Map<String, dynamic> json) {
    id = _receiptToInt(json['id']);
    name = json['name']?.toString();
    address = json['address']?.toString();
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'address': address};
}

class ReceiptSettings {
  bool? showTax;
  bool? showTableNumber;
  bool? showWaiter;
  bool? showTotalGuest;
  bool? showOrderType;
  bool? showCustomerName;
  bool? showCustomerAddress;
  String? paymentQrCodeUrl;

  ReceiptSettings({
    this.showTax,
    this.showTableNumber,
    this.showWaiter,
    this.showTotalGuest,
    this.showOrderType,
    this.showCustomerName,
    this.showCustomerAddress,
    this.paymentQrCodeUrl,
  });

  ReceiptSettings.fromJson(Map<String, dynamic> json) {
    showTax = json['show_tax'] as bool?;
    showTableNumber = json['show_table_number'] as bool?;
    showWaiter = json['show_waiter'] as bool?;
    showTotalGuest = json['show_total_guest'] as bool?;
    showOrderType = json['show_order_type'] as bool?;
    showCustomerName = json['show_customer_name'] as bool?;
    showCustomerAddress = json['show_customer_address'] as bool?;
    paymentQrCodeUrl = json['payment_qr_code_url']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'show_tax': showTax,
    'show_table_number': showTableNumber,
    'show_waiter': showWaiter,
    'show_total_guest': showTotalGuest,
    'show_order_type': showOrderType,
    'show_customer_name': showCustomerName,
    'show_customer_address': showCustomerAddress,
    'payment_qr_code_url': paymentQrCodeUrl,
  };
}

class ReceiptOrder {
  int? id;
  String? orderNumber;
  String? formattedOrderNumber;
  String? dateTime;
  String? status;
  String? orderStatus;
  String? orderType;
  ReceiptOrderTable? table;
  dynamic customer;
  ReceiptWaiter? waiter;
  int? numberOfPax;
  String? deliveryAddress;

  ReceiptOrder({
    this.id,
    this.orderNumber,
    this.formattedOrderNumber,
    this.dateTime,
    this.status,
    this.orderStatus,
    this.orderType,
    this.table,
    this.customer,
    this.waiter,
    this.numberOfPax,
    this.deliveryAddress,
  });

  ReceiptOrder.fromJson(Map<String, dynamic> json) {
    id = _receiptToInt(json['id']);
    orderNumber = json['order_number']?.toString();
    formattedOrderNumber = json['formatted_order_number']?.toString();
    dateTime = json['date_time']?.toString();
    status = json['status']?.toString();
    orderStatus = json['order_status']?.toString();
    orderType = json['order_type']?.toString();
    table =
        json['table'] != null
            ? ReceiptOrderTable.fromJson(json['table'] as Map<String, dynamic>)
            : null;
    customer = json['customer'];
    waiter =
        json['waiter'] != null
            ? ReceiptWaiter.fromJson(json['waiter'] as Map<String, dynamic>)
            : null;
    numberOfPax = _receiptToInt(json['number_of_pax']);
    deliveryAddress = json['delivery_address']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'formatted_order_number': formattedOrderNumber,
    'date_time': dateTime,
    'status': status,
    'order_status': orderStatus,
    'order_type': orderType,
    'table': table?.toJson(),
    'customer': customer,
    'waiter': waiter?.toJson(),
    'number_of_pax': numberOfPax,
    'delivery_address': deliveryAddress,
  };
}

class ReceiptOrderTable {
  int? id;
  String? tableCode;

  ReceiptOrderTable({this.id, this.tableCode});

  ReceiptOrderTable.fromJson(Map<String, dynamic> json) {
    id = _receiptToInt(json['id']);
    tableCode = json['table_code']?.toString();
  }

  Map<String, dynamic> toJson() => {'id': id, 'table_code': tableCode};
}

class ReceiptWaiter {
  int? id;
  String? name;

  ReceiptWaiter({this.id, this.name});

  ReceiptWaiter.fromJson(Map<String, dynamic> json) {
    id = _receiptToInt(json['id']);
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ReceiptPayment {
  int? id;
  double? amount;
  String? paymentMethod;
  double? tipAmount;
  String? tipNote;
  String? discountType;
  double? discountValue;
  double? discountAmount;
  double? balance;
  String? createdAt;

  ReceiptPayment({
    this.id,
    this.amount,
    this.paymentMethod,
    this.tipAmount,
    this.tipNote,
    this.discountType,
    this.discountValue,
    this.discountAmount,
    this.balance,
    this.createdAt,
  });

  ReceiptPayment.fromJson(Map<String, dynamic> json) {
    id = _receiptToInt(json['id']);
    amount = _receiptToDouble(json['amount']);
    paymentMethod = json['payment_method']?.toString();
    tipAmount = _receiptToDouble(json['tip_amount']);
    tipNote = json['tip_note']?.toString();
    discountType = json['discount_type']?.toString();
    discountValue = _receiptToDouble(json['discount_value']);
    discountAmount = _receiptToDouble(json['discount_amount']);
    balance = _receiptToDouble(json['balance']);
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'payment_method': paymentMethod,
    'tip_amount': tipAmount,
    'tip_note': tipNote,
    'discount_type': discountType,
    'discount_value': discountValue,
    'discount_amount': discountAmount,
    'balance': balance,
    'created_at': createdAt,
  };
}

class ReceiptSplitOrder {
  int? id;
  double? subtotal;
  List<dynamic>? extraCharges;
  List<ReceiptTax>? taxes;
  double? amount;
  List<ReceiptItemEntry>? items;

  ReceiptSplitOrder({
    this.id,
    this.subtotal,
    this.extraCharges,
    this.taxes,
    this.amount,
    this.items,
  });

  ReceiptSplitOrder.fromJson(Map<String, dynamic> json) {
    id = _receiptToInt(json['id']);
    subtotal = _receiptToDouble(json['subtotal']);
    extraCharges = json['extra_charges'] as List<dynamic>?;
    if (json['taxes'] != null) {
      taxes =
          (json['taxes'] as List)
              .map((e) => ReceiptTax.fromJson(e as Map<String, dynamic>))
              .toList();
    }
    amount = _receiptToDouble(json['amount']);
    if (json['items'] != null) {
      items =
          (json['items'] as List)
              .map((e) => ReceiptItemEntry.fromJson(e as Map<String, dynamic>))
              .toList();
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subtotal': subtotal,
    'extra_charges': extraCharges,
    'taxes': taxes?.map((e) => e.toJson()).toList(),
    'amount': amount,
    'items': items?.map((e) => e.toJson()).toList(),
  };
}

class ReceiptTax {
  String? name;
  double? amount;
  String? percent;
  bool? isInclusive;

  ReceiptTax({this.name, this.amount, this.percent, this.isInclusive});

  ReceiptTax.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    amount = _receiptToDouble(json['amount']);
    percent = json['percent']?.toString();
    isInclusive = json['is_inclusive'] as bool?;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'percent': percent,
    'is_inclusive': isInclusive,
  };
}

class ReceiptItemEntry {
  int? quantity;
  ReceiptOrderItem? orderItem;

  ReceiptItemEntry({this.quantity, this.orderItem});

  ReceiptItemEntry.fromJson(Map<String, dynamic> json) {
    quantity = _receiptToInt(json['quantity']);
    orderItem =
        json['order_item'] != null
            ? ReceiptOrderItem.fromJson(
              json['order_item'] as Map<String, dynamic>,
            )
            : null;
  }

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'order_item': orderItem?.toJson(),
  };
}

class ReceiptOrderItem {
  String? displayItemName;
  String? displayVariationName;
  List<ReceiptDisplayModifier>? displayModifiers;
  double? amount;
  int? quantity;
  String? formattedPrice;
  String? formattedLineAmount;
  String? note;

  ReceiptOrderItem({
    this.displayItemName,
    this.displayVariationName,
    this.displayModifiers,
    this.amount,
    this.quantity,
    this.formattedPrice,
    this.formattedLineAmount,
    this.note,
  });

  ReceiptOrderItem.fromJson(Map<String, dynamic> json) {
    displayItemName = json['display_item_name']?.toString();
    displayVariationName = json['display_variation_name']?.toString();
    if (json['display_modifiers'] != null) {
      displayModifiers =
          (json['display_modifiers'] as List)
              .map(
                (e) =>
                    ReceiptDisplayModifier.fromJson(e as Map<String, dynamic>),
              )
              .toList();
    }
    amount = _receiptToDouble(json['amount']);
    quantity = _receiptToInt(json['quantity']);
    formattedPrice = json['formatted_price']?.toString();
    formattedLineAmount = json['formatted_line_amount']?.toString();
    note = json['note']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'display_item_name': displayItemName,
    'display_variation_name': displayVariationName,
    'display_modifiers': displayModifiers?.map((e) => e.toJson()).toList(),
    'amount': amount,
    'quantity': quantity,
    'formatted_price': formattedPrice,
    'formatted_line_amount': formattedLineAmount,
    'note': note,
  };
}

class ReceiptDisplayModifier {
  int? id;
  String? name;
  String? price;

  ReceiptDisplayModifier({this.id, this.name, this.price});

  ReceiptDisplayModifier.fromJson(Map<String, dynamic> json) {
    id = _receiptToInt(json['id']);
    name = json['name']?.toString();
    price = json['price']?.toString();
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}

class ReceiptSummary {
  double? subTotal;
  double? discount;
  String? discountType;
  double? discountValue;
  List<dynamic>? extraCharges;
  double? tip;
  List<ReceiptTax>? taxes;
  double? total;
  double? deliveryFee;

  ReceiptSummary({
    this.subTotal,
    this.discount,
    this.discountType,
    this.discountValue,
    this.extraCharges,
    this.tip,
    this.taxes,
    this.total,
    this.deliveryFee,
  });

  ReceiptSummary.fromJson(Map<String, dynamic> json) {
    subTotal = _receiptToDouble(json['sub_total']);
    discount = _receiptToDouble(json['discount']);
    discountType = json['discount_type']?.toString();
    discountValue = _receiptToDouble(json['discount_value']);
    extraCharges = json['extra_charges'] as List<dynamic>?;
    tip = _receiptToDouble(json['tip']);
    if (json['taxes'] != null) {
      taxes =
          (json['taxes'] as List)
              .map((e) => ReceiptTax.fromJson(e as Map<String, dynamic>))
              .toList();
    }
    total = _receiptToDouble(json['total']);
    deliveryFee = _receiptToDouble(json['delivery_fee']);
  }

  Map<String, dynamic> toJson() => {
    'sub_total': subTotal,
    'discount': discount,
    'discount_type': discountType,
    'discount_value': discountValue,
    'extra_charges': extraCharges,
    'tip': tip,
    'taxes': taxes?.map((e) => e.toJson()).toList(),
    'total': total,
    'delivery_fee': deliveryFee,
  };
}
