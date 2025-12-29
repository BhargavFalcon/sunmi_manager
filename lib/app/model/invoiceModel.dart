class InvoiceModel {
  Invoice? invoice;

  InvoiceModel({this.invoice});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    invoice =
        json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null;
  }

  Map<String, dynamic> toJson() => {'invoice': invoice?.toJson()};
}

class Invoice {
  Restaurant? restaurant;
  Branch? branch;
  Order? order;
  ReceiptSettings? receiptSettings;
  List<TaxDetails>? taxDetails;
  Payments? payment;
  String? taxMode;
  bool? taxInclusive;
  CurrencyConfig? currencyConfig;
  int? restaurantId;
  String? pdfUrl;
  String? imageUrl;
  String? invoiceUrl;

  Invoice.fromJson(Map<String, dynamic> json) {
    restaurant =
        json['restaurant'] != null
            ? Restaurant.fromJson(json['restaurant'])
            : null;
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    receiptSettings =
        json['receipt_settings'] != null
            ? ReceiptSettings.fromJson(json['receipt_settings'])
            : null;
    taxDetails =
        (json['tax_details'] as List?)
            ?.map((e) => TaxDetails.fromJson(e))
            .toList();
    payment =
        json['payment'] != null ? Payments.fromJson(json['payment']) : null;
    taxMode = json['tax_mode'];
    taxInclusive = json['tax_inclusive'];
    currencyConfig =
        json['currency_config'] != null
            ? CurrencyConfig.fromJson(json['currency_config'])
            : null;
    restaurantId = json['restaurant_id'];
    pdfUrl = json['pdf_url'];
    imageUrl = json['image_url'];
    invoiceUrl = json['invoice_url'];
  }

  Map<String, dynamic> toJson() => {
    'restaurant': restaurant?.toJson(),
    'branch': branch?.toJson(),
    'order': order?.toJson(),
    'receipt_settings': receiptSettings?.toJson(),
    'tax_details': taxDetails?.map((e) => e.toJson()).toList(),
    'payment': payment?.toJson(),
    'tax_mode': taxMode,
    'tax_inclusive': taxInclusive,
    'currency_config': currencyConfig?.toJson(),
    'restaurant_id': restaurantId,
    'pdf_url': pdfUrl,
    'image_url': imageUrl,
    'invoice_url': invoiceUrl,
  };
}

class Restaurant {
  int? id;
  String? name;
  String? logoUrl;
  String? phoneNumber;

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logoUrl = json['logo_url'];
    phoneNumber = json['phone_number']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo_url': logoUrl,
    'phone_number': phoneNumber,
  };
}

class Branch {
  int? id;
  String? address;

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() => {'id': id, 'address': address};
}

class Order {
  int? id;
  String? uuid;
  int? orderNumber;
  String? formattedOrderNumber;
  String? dateTime;
  String? status;
  String? orderStatus;
  String? orderType;
  int? numberOfPax;
  String? note;
  String? pickupDate;
  int? subTotal;
  double? discountAmount;
  String? discountType;
  String? discountValue;
  int? tipAmount;
  double? totalTaxAmount;
  double? total;
  String? formattedSubTotal;
  String? formattedDiscountAmount;
  String? formattedTipAmount;
  String? formattedTotalTaxAmount;
  String? formattedTotal;
  Customer? customer;
  List<Items>? items;
  List<Charges>? charges;
  List<Payments>? payments;

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    orderNumber = json['order_number'];
    formattedOrderNumber = json['formatted_order_number'];
    dateTime = json['date_time'];
    status = json['status'];
    orderStatus = json['order_status'];
    orderType = json['order_type'];
    numberOfPax = json['number_of_pax'];
    note = json['note'];
    pickupDate = json['pickup_date'];
    subTotal = json['sub_total'];
    discountAmount = json['discount_amount']?.toDouble();
    discountType = json['discount_type'];
    discountValue = json['discount_value'].toString();
    tipAmount = json['tip_amount'];
    totalTaxAmount = json['total_tax_amount']?.toDouble();
    total = json['total']?.toDouble();
    formattedSubTotal = json['formatted_sub_total'];
    formattedDiscountAmount = json['formatted_discount_amount'];
    formattedTipAmount = json['formatted_tip_amount'];
    formattedTotalTaxAmount = json['formatted_total_tax_amount'];
    formattedTotal = json['formatted_total'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    items = (json['items'] as List?)?.map((e) => Items.fromJson(e)).toList();
    charges =
        (json['charges'] as List?)?.map((e) => Charges.fromJson(e)).toList();
    payments =
        (json['payments'] as List?)?.map((e) => Payments.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'order_number': orderNumber,
    'formatted_order_number': formattedOrderNumber,
    'date_time': dateTime,
    'status': status,
    'order_status': orderStatus,
    'order_type': orderType,
    'number_of_pax': numberOfPax,
    'note': note,
    'pickup_date': pickupDate,
    'sub_total': subTotal,
    'discount_amount': discountAmount,
    'discount_type': discountType,
    'discount_value': discountValue,
    'tip_amount': tipAmount,
    'total_tax_amount': totalTaxAmount,
    'total': total,
    'formatted_sub_total': formattedSubTotal,
    'formatted_discount_amount': formattedDiscountAmount,
    'formatted_tip_amount': formattedTipAmount,
    'formatted_total_tax_amount': formattedTotalTaxAmount,
    'formatted_total': formattedTotal,
    'customer': customer?.toJson(),
    'items': items?.map((e) => e.toJson()).toList(),
    'charges': charges?.map((e) => e.toJson()).toList(),
    'payments': payments?.map((e) => e.toJson()).toList(),
  };
}

class Customer {
  int? id;
  String? name;
  String? phoneNumber;
  String? deliveryAddress;

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phoneNumber = json['phone_number']?.toString();
    deliveryAddress = json['delivery_address'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'delivery_address': deliveryAddress,
  };
}

class Items {
  int? id;
  int? quantity;
  double? price;
  double? amount;
  String? formattedPrice;
  String? formattedAmount;
  String? itemName;
  String? variationName;
  List<Modifiers>? modifiers;
  bool? isDeleted;
  bool? isVariationDeleted;
  double? taxAmount;
  TaxBreakup? taxBreakup;
  String? createdAt;

  Items.fromJson(Map<String, dynamic> json) {
    id =
        json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null);
    quantity =
        json['quantity'] is int
            ? json['quantity']
            : (json['quantity'] is String
                ? int.tryParse(json['quantity'])
                : null);
    price =
        json['price'] is num
            ? (json['price'] as num).toDouble()
            : (json['price'] is String ? double.tryParse(json['price']) : null);
    amount =
        json['amount'] is num
            ? (json['amount'] as num).toDouble()
            : (json['amount'] is String
                ? double.tryParse(json['amount'])
                : null);
    formattedPrice = json['formatted_price'];
    formattedAmount = json['formatted_amount'];
    itemName = json['item_name'];
    variationName = json['variation_name'];
    modifiers =
        (json['modifiers'] as List?)
            ?.map((e) => Modifiers.fromJson(e))
            .toList();
    isDeleted = json['is_deleted'];
    isVariationDeleted = json['is_variation_deleted'];
    taxAmount =
        json['tax_amount'] is num
            ? (json['tax_amount'] as num).toDouble()
            : (json['tax_amount'] is String
                ? double.tryParse(json['tax_amount'])
                : null);
    taxBreakup =
        json['tax_breakup'] != null
            ? TaxBreakup.fromJson(json['tax_breakup'])
            : null;
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'quantity': quantity,
    'price': price,
    'amount': amount,
    'formatted_price': formattedPrice,
    'formatted_amount': formattedAmount,
    'item_name': itemName,
    'variation_name': variationName,
    'modifiers': modifiers?.map((e) => e.toJson()).toList(),
    'is_deleted': isDeleted,
    'is_variation_deleted': isVariationDeleted,
    'tax_amount': taxAmount,
    'tax_breakup': taxBreakup?.toJson(),
    'created_at': createdAt,
  };
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

class TaxBreakup {
  Map<String, TaxValue>? taxes;

  TaxBreakup.fromJson(Map<String, dynamic> json) {
    taxes = {};
    json.forEach((key, value) {
      taxes![key] = TaxValue.fromJson(value);
    });
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    taxes?.forEach((key, value) {
      data[key] = value.toJson();
    });
    return data;
  }
}

class TaxValue {
  double? amount;
  String? percent;

  TaxValue.fromJson(Map<String, dynamic> json) {
    amount = json['amount']?.toDouble();
    percent = json['percent']?.toString();
  }

  Map<String, dynamic> toJson() => {'amount': amount, 'percent': percent};
}

class Charges {
  int? id;
  String? chargeName;
  String? chargeType;
  double? chargeValue;
  double? amount;
  String? formattedAmount;

  Charges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chargeName = json['charge_name'];
    chargeType = json['charge_type'];
    chargeValue = json['charge_value']?.toDouble();
    amount = json['amount']?.toDouble();
    formattedAmount = json['formatted_amount'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'charge_name': chargeName,
    'charge_type': chargeType,
    'charge_value': chargeValue,
    'amount': amount,
    'formatted_amount': formattedAmount,
  };
}

class Payments {
  int? id;
  double? amount;
  String? paymentMethod;
  int? balance;
  String? formattedAmount;
  String? formattedBalance;
  String? createdAt;

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount']?.toDouble();
    paymentMethod = json['payment_method'];
    balance = json['balance'];
    formattedAmount = json['formatted_amount'];
    formattedBalance = json['formatted_balance'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'payment_method': paymentMethod,
    'balance': balance,
    'formatted_amount': formattedAmount,
    'formatted_balance': formattedBalance,
    'created_at': createdAt,
  };
}

class ReceiptSettings {
  bool? showRestaurantLogo;
  bool? showCustomerName;
  bool? showCustomerAddress;
  bool? showTableNumber;
  bool? showWaiter;
  bool? showTotalGuest;
  bool? showTax;
  bool? showPaymentQrCode;
  bool? showPaymentDetails;
  bool? showOrderType;
  String? paymentQrCodeUrl;

  ReceiptSettings.fromJson(Map<String, dynamic> json) {
    showRestaurantLogo = json['show_restaurant_logo'];
    showCustomerName = json['show_customer_name'];
    showCustomerAddress = json['show_customer_address'];
    showTableNumber = json['show_table_number'];
    showWaiter = json['show_waiter'];
    showTotalGuest = json['show_total_guest'];
    showTax = json['show_tax'];
    showPaymentQrCode = json['show_payment_qr_code'];
    showPaymentDetails = json['show_payment_details'];
    showOrderType = json['show_order_type'];
    paymentQrCodeUrl = json['payment_qr_code_url'];
  }

  Map<String, dynamic> toJson() => {
    'show_restaurant_logo': showRestaurantLogo,
    'show_customer_name': showCustomerName,
    'show_customer_address': showCustomerAddress,
    'show_table_number': showTableNumber,
    'show_waiter': showWaiter,
    'show_total_guest': showTotalGuest,
    'show_tax': showTax,
    'show_payment_qr_code': showPaymentQrCode,
    'show_payment_details': showPaymentDetails,
    'show_order_type': showOrderType,
    'payment_qr_code_url': paymentQrCodeUrl,
  };
}

class TaxDetails {
  int? id;
  String? taxName;
  String? taxId;

  TaxDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxName = json['tax_name'];
    taxId = json['tax_id'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tax_name': taxName,
    'tax_id': taxId,
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
