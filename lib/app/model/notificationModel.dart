String? _parseToString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

class NotificationModel {
  Order? order;

  NotificationModel({this.order});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() => {'order': order?.toJson()};
}

class Order {
  String? uuid;
  int? id;
  int? orderNumber;
  String? formattedOrderNumber;
  String? dateTime;
  String? status;
  String? orderStatus;
  String? orderType;
  int? branchId;
  Customer? customer;
  Currency? currency;
  int? currencyId;
  CurrencyConfig? currencyConfig;
  List<Items>? items;
  List<Taxes>? taxes;
  List<Charges>? charges;
  List<Payments>? payments;
  Totals? totals;
  int? numberOfPax;
  String? discountType;
  String? discountValue;
  String? note;
  String? taxModeAtOrder;
  bool? taxInclusiveAtOrder;
  String? deliveryAddress;
  String? createdAt;
  String? updatedAt;
  int? restaurantId;
  String? pdfUrl;
  String? imageUrl;
  String? invoiceUrl;

  Order.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    id = json['id'];
    orderNumber = json['order_number'];
    formattedOrderNumber = json['formatted_order_number'];
    dateTime = json['date_time'];
    status = json['status'];
    orderStatus = json['order_status'];
    orderType = json['order_type'];
    branchId = json['branch_id'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    currency =
        json['currency'] != null ? Currency.fromJson(json['currency']) : null;
    currencyId = json['currency_id'];
    currencyConfig =
        json['currency_config'] != null
            ? CurrencyConfig.fromJson(json['currency_config'])
            : null;
    items = (json['items'] as List?)?.map((e) => Items.fromJson(e)).toList();
    taxes = (json['taxes'] as List?)?.map((e) => Taxes.fromJson(e)).toList();
    charges =
        (json['charges'] as List?)?.map((e) => Charges.fromJson(e)).toList();
    payments =
        (json['payments'] as List?)?.map((e) => Payments.fromJson(e)).toList();
    totals = json['totals'] != null ? Totals.fromJson(json['totals']) : null;
    numberOfPax = json['number_of_pax'];
    discountType = json['discount_type'];
    discountValue = json['discount_value'];
    note = json['note'];
    taxModeAtOrder = json['tax_mode_at_order'];
    taxInclusiveAtOrder = json['tax_inclusive_at_order'] == 1;
    deliveryAddress = json['delivery_address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    restaurantId = json['restaurant_id'];
    pdfUrl = json['pdf_url'];
    imageUrl = json['image_url'];
    invoiceUrl = json['invoice_url'];
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'id': id,
    'order_number': orderNumber,
    'formatted_order_number': formattedOrderNumber,
    'date_time': dateTime,
    'status': status,
    'order_status': orderStatus,
    'order_type': orderType,
    'branch_id': branchId,
    'customer': customer?.toJson(),
    'currency': currency?.toJson(),
    'currency_id': currencyId,
    'currency_config': currencyConfig?.toJson(),
    'items': items?.map((e) => e.toJson()).toList(),
    'taxes': taxes?.map((e) => e.toJson()).toList(),
    'charges': charges?.map((e) => e.toJson()).toList(),
    'payments': payments?.map((e) => e.toJson()).toList(),
    'totals': totals?.toJson(),
    'number_of_pax': numberOfPax,
    'discount_type': discountType,
    'discount_value': discountValue,
    'note': note,
    'tax_mode_at_order': taxModeAtOrder,
    'tax_inclusive_at_order': taxInclusiveAtOrder == true ? 1 : 0,
    'delivery_address': deliveryAddress,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'restaurant_id': restaurantId,
    'pdf_url': pdfUrl,
    'image_url': imageUrl,
    'invoice_url': invoiceUrl,
  };
}

class Customer {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone_number': phoneNumber,
  };
}

class Items {
  int? id;
  String? itemName;
  String? itemNumber;
  String? variationName;
  int? quantity;
  String? price;
  String? amount;
  String? formattedAmount;
  String? note;
  String? taxAmount;
  String? taxPercentage;
  bool? isDeleted;
  bool? isVariationDeleted;
  int? kotItemId;
  List<Modifiers>? modifiers;
  TaxBreakup? taxBreakup;

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemName = json['item_name'];
    itemNumber = json['item_number'];
    variationName = json['variation_name'];
    quantity = json['quantity'];
    price = _parseToString(json['price']);
    amount = _parseToString(json['amount']);
    formattedAmount = json['formatted_amount'];
    note = json['note'];
    taxAmount = _parseToString(json['tax_amount']);
    taxPercentage = json['tax_percentage'];
    isDeleted = json['is_deleted'];
    isVariationDeleted = json['is_variation_deleted'];
    kotItemId = json['kot_item_id'];
    modifiers =
        (json['modifiers'] as List?)
            ?.map((e) => Modifiers.fromJson(e))
            .toList();
    taxBreakup =
        json['tax_breakup'] != null
            ? TaxBreakup.fromJson(json['tax_breakup'])
            : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'item_name': itemName,
    'item_number': itemNumber,
    'variation_name': variationName,
    'quantity': quantity,
    'price': price,
    'amount': amount,
    'formatted_amount': formattedAmount,
    'note': note,
    'tax_amount': taxAmount,
    'tax_percentage': taxPercentage,
    'is_deleted': isDeleted,
    'is_variation_deleted': isVariationDeleted,
    'kot_item_id': kotItemId,
    'modifiers': modifiers?.map((e) => e.toJson()).toList(),
    'tax_breakup': taxBreakup?.toJson(),
  };
}

class TaxBreakup {
  Map<String, TaxValue> taxes = {};

  TaxBreakup.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      taxes[key] = TaxValue.fromJson(value);
    });
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    taxes.forEach((key, value) {
      data[key] = value.toJson();
    });
    return data;
  }
}

class TaxValue {
  String? amount;
  String? percent;

  TaxValue.fromJson(Map<String, dynamic> json) {
    amount = _parseToString(json['amount']);
    percent = _parseToString(json['percent']);
  }

  Map<String, dynamic> toJson() => {'amount': amount, 'percent': percent};
}

class Modifiers {
  int? id;
  String? name;
  String? price;

  Modifiers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}

class Taxes {
  String? taxName;
  String? percent;
  String? amount;

  Taxes.fromJson(Map<String, dynamic> json) {
    taxName = json['tax_name'];
    percent = _parseToString(json['percent']);
    amount = _parseToString(json['amount']);
  }

  Map<String, dynamic> toJson() => {
    'tax_name': taxName,
    'percent': percent,
    'amount': amount,
  };
}

class Charges {
  int? id;
  String? chargeName;
  String? chargeType;
  String? amount;

  Charges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chargeName = json['charge_name'];
    chargeType = json['charge_type'];
    amount = _parseToString(json['amount']);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'charge_name': chargeName,
    'charge_type': chargeType,
    'amount': amount,
  };
}

class Payments {
  int? id;
  String? amount;
  String? paymentMethod;
  String? createdAt;

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = _parseToString(json['amount']);
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'payment_method': paymentMethod,
    'created_at': createdAt,
  };
}

class Totals {
  String? subTotal;
  String? totalTaxAmount;
  String? tipAmount;
  String? deliveryFee;
  String? total;
  String? amountPaid;
  String? discountAmount;

  Totals.fromJson(Map<String, dynamic> json) {
    subTotal = _parseToString(json['sub_total']);
    totalTaxAmount = _parseToString(json['total_tax_amount']);
    tipAmount = _parseToString(json['tip_amount']);
    deliveryFee = _parseToString(json['delivery_fee']);
    total = _parseToString(json['total']);
    amountPaid = _parseToString(json['amount_paid']);
    discountAmount = _parseToString(json['discount_amount']);
  }

  Map<String, dynamic> toJson() => {
    'sub_total': subTotal,
    'total_tax_amount': totalTaxAmount,
    'tip_amount': tipAmount,
    'delivery_fee': deliveryFee,
    'total': total,
    'amount_paid': amountPaid,
    'discount_amount': discountAmount,
  };
}

class Currency {
  int? id;
  String? currencyCode;
  String? currencySymbol;
  String? currencyPosition;
  int? noOfDecimal;
  String? thousandSeparator;
  String? decimalSeparator;

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    currencyPosition = json['currency_position'];
    noOfDecimal = json['no_of_decimal'];
    thousandSeparator = json['thousand_separator'];
    decimalSeparator = json['decimal_separator'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'currency_code': currencyCode,
    'currency_symbol': currencySymbol,
    'currency_position': currencyPosition,
    'no_of_decimal': noOfDecimal,
    'thousand_separator': thousandSeparator,
    'decimal_separator': decimalSeparator,
  };
}

class CurrencyConfig {
  String? code;
  String? symbol;
  String? position;
  int? decimalPlaces;
  String? thousandSeparator;
  String? decimalSeparator;

  CurrencyConfig.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    symbol = json['symbol'];
    position = json['position'];
    decimalPlaces = json['decimal_places'];
    thousandSeparator = json['thousand_separator'];
    decimalSeparator = json['decimal_separator'];
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'symbol': symbol,
    'position': position,
    'decimal_places': decimalPlaces,
    'thousand_separator': thousandSeparator,
    'decimal_separator': decimalSeparator,
  };
}
