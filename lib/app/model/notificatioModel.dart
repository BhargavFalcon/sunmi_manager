class InvoiceModel {
  Order? order;

  InvoiceModel({this.order});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
  }
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
  CurrencyConfig? currencyConfig;
  List<Item>? items;
  List<Tax>? taxes;
  List<Charge>? charges;
  List<Payment>? payments;
  Totals? totals;
  String? discountType;
  String? discountValue;
  String? createdAt;
  String? updatedAt;
  String? invoiceUrl;
  InvoiceData? invoiceData;

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
    currencyConfig = json['currency_config'] != null
        ? CurrencyConfig.fromJson(json['currency_config'])
        : null;
    items = (json['items'] as List?)
        ?.map((e) => Item.fromJson(e))
        .toList();
    taxes =
        (json['taxes'] as List?)?.map((e) => Tax.fromJson(e)).toList();
    charges =
        (json['charges'] as List?)?.map((e) => Charge.fromJson(e)).toList();
    payments =
        (json['payments'] as List?)?.map((e) => Payment.fromJson(e)).toList();
    totals =
    json['totals'] != null ? Totals.fromJson(json['totals']) : null;
    discountType = json['discount_type'];
    discountValue = json['discount_value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    invoiceUrl = json['invoice_url'];
    invoiceData = json['invoice_data'] != null
        ? InvoiceData.fromJson(json['invoice_data'])
        : null;
  }
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
    phoneNumber = json['phone_number'];
  }
}

class Currency {
  int? id;
  String? currencyCode;
  String? currencySymbol;
  String? currencyPosition;
  int? noOfDecimal;

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    currencyPosition = json['currency_position'];
    noOfDecimal = json['no_of_decimal'];
  }
}

class CurrencyConfig {
  String? code;
  String? symbol;
  String? position;
  int? decimalPlaces;

  CurrencyConfig.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    symbol = json['symbol'];
    position = json['position'];
    decimalPlaces = json['decimal_places'];
  }
}

class Item {
  int? id;
  String? itemName;
  String? variationName;
  int? quantity;
  String? price;
  String? amount;
  String? formattedAmount;
  List<Modifier>? modifiers;
  String? taxAmount;
  String? taxPercentage;

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemName = json['item_name'];
    variationName = json['variation_name'];
    quantity = json['quantity'];
    price = json['price'];
    amount = json['amount'];
    formattedAmount = json['formatted_amount'];
    modifiers = (json['modifiers'] as List?)
        ?.map((e) => Modifier.fromJson(e))
        .toList();
    taxAmount = json['tax_amount'];
    taxPercentage = json['tax_percentage'];
  }
}

class Modifier {
  int? id;
  String? name;
  String? price;

  Modifier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
  }
}

class Tax {
  String? taxName;
  String? percent;
  double? amount;

  Tax.fromJson(Map<String, dynamic> json) {
    taxName = json['tax_name'];
    percent = json['percent'];
    amount = (json['amount'] as num?)?.toDouble();
  }
}

class Charge {
  int? id;
  String? chargeName;
  String? chargeType;
  String? amount;

  Charge.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chargeName = json['charge_name'];
    chargeType = json['charge_type'];
    amount = json['amount'];
  }
}

class Payment {
  int? id;
  String? amount;
  String? paymentMethod;
  String? createdAt;

  Payment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
  }
}

class Totals {
  String? subTotal;
  String? totalTaxAmount;
  String? discountAmount;
  String? total;
  String? amountPaid;

  Totals.fromJson(Map<String, dynamic> json) {
    subTotal = json['sub_total'];
    totalTaxAmount = json['total_tax_amount'];
    discountAmount = json['discount_amount'];
    total = json['total'];
    amountPaid = json['amount_paid'];
  }
}

class InvoiceData {
  Restaurant? restaurant;
  Branch? branch;
  ReceiptSettings? receiptSettings;

  InvoiceData.fromJson(Map<String, dynamic> json) {
    restaurant = json['restaurant'] != null
        ? Restaurant.fromJson(json['restaurant'])
        : null;
    branch =
    json['branch'] != null ? Branch.fromJson(json['branch']) : null;
    receiptSettings = json['receipt_settings'] != null
        ? ReceiptSettings.fromJson(json['receipt_settings'])
        : null;
  }
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
    phoneNumber = json['phone_number'];
  }
}

class Branch {
  int? id;
  String? address;

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
  }
}

class ReceiptSettings {
  bool? showRestaurantLogo;
  bool? showCustomerName;
  bool? showTax;
  bool? showPaymentDetails;

  ReceiptSettings.fromJson(Map<String, dynamic> json) {
    showRestaurantLogo = json['show_restaurant_logo'];
    showCustomerName = json['show_customer_name'];
    showTax = json['show_tax'];
    showPaymentDetails = json['show_payment_details'];
  }
}
