class AllOrdersModel {
  bool? success;
  Data? data;

  AllOrdersModel({this.success, this.data});

  AllOrdersModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Orders>? orders;
  Pagination? pagination;

  Data({this.orders, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(new Orders.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? new Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Orders {
  String? uuid;
  int? id;
  int? orderNumber;
  String? dateTime;
  String? status;
  String? orderStatus;
  String? orderType;
  int? branchId;
  Table? table;
  Customer? customer;
  Waiter? waiter;
  Currency? currency;
  int? currencyId;
  CurrencyConfig? currencyConfig;
  List<Items>? items;
  List<Charges>? charges;
  List<Payments>? payments;
  List<Kots>? kots;
  Totals? totals;
  int? numberOfPax;
  String? taxModeAtOrder;
  int? taxInclusiveAtOrder;
  String? deliveryFee;
  String? customerLat;
  String? customerLng;
  int? isWithinRadius;
  CancelReason? cancelReason;
  int? cancelReasonId;
  String? createdAt;
  String? updatedAt;

  Orders({
    this.uuid,
    this.id,
    this.orderNumber,
    this.dateTime,
    this.status,
    this.orderStatus,
    this.orderType,
    this.branchId,
    this.table,
    this.customer,
    this.waiter,
    this.currency,
    this.currencyId,
    this.currencyConfig,
    this.items,
    this.charges,
    this.payments,
    this.kots,
    this.totals,
    this.numberOfPax,
    this.taxModeAtOrder,
    this.taxInclusiveAtOrder,
    this.deliveryFee,
    this.customerLat,
    this.customerLng,
    this.isWithinRadius,
    this.cancelReason,
    this.cancelReasonId,
    this.createdAt,
    this.updatedAt,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    id = json['id'];
    orderNumber = json['order_number'];
    dateTime = json['date_time'];
    status = json['status'];
    orderStatus = json['order_status'];
    orderType = json['order_type'];
    branchId = json['branch_id'];
    table = json['table'] != null ? new Table.fromJson(json['table']) : null;
    customer =
        json['customer'] != null
            ? new Customer.fromJson(json['customer'])
            : null;
    waiter =
        json['waiter'] != null ? new Waiter.fromJson(json['waiter']) : null;
    currency =
        json['currency'] != null
            ? new Currency.fromJson(json['currency'])
            : null;
    currencyId = json['currency_id'];
    currencyConfig =
        json['currency_config'] != null
            ? new CurrencyConfig.fromJson(json['currency_config'])
            : null;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    if (json['charges'] != null) {
      charges = <Charges>[];
      json['charges'].forEach((v) {
        charges!.add(new Charges.fromJson(v));
      });
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(new Payments.fromJson(v));
      });
    }
    if (json['kots'] != null) {
      kots = <Kots>[];
      json['kots'].forEach((v) {
        kots!.add(new Kots.fromJson(v));
      });
    }
    totals =
        json['totals'] != null ? new Totals.fromJson(json['totals']) : null;
    numberOfPax = json['number_of_pax'];
    taxModeAtOrder = json['tax_mode_at_order'];
    taxInclusiveAtOrder = json['tax_inclusive_at_order'];
    deliveryFee = json['delivery_fee'];
    customerLat = json['customer_lat'];
    customerLng = json['customer_lng'];
    isWithinRadius = json['is_within_radius'];
    cancelReason =
        json['cancel_reason'] != null
            ? new CancelReason.fromJson(json['cancel_reason'])
            : null;
    cancelReasonId = json['cancel_reason_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['id'] = this.id;
    data['order_number'] = this.orderNumber;
    data['date_time'] = this.dateTime;
    data['status'] = this.status;
    data['order_status'] = this.orderStatus;
    data['order_type'] = this.orderType;
    data['branch_id'] = this.branchId;
    if (this.table != null) {
      data['table'] = this.table!.toJson();
    }
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    if (this.waiter != null) {
      data['waiter'] = this.waiter!.toJson();
    }
    if (this.currency != null) {
      data['currency'] = this.currency!.toJson();
    }
    data['currency_id'] = this.currencyId;
    if (this.currencyConfig != null) {
      data['currency_config'] = this.currencyConfig!.toJson();
    }
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.charges != null) {
      data['charges'] = this.charges!.map((v) => v.toJson()).toList();
    }
    if (this.payments != null) {
      data['payments'] = this.payments!.map((v) => v.toJson()).toList();
    }
    if (this.kots != null) {
      data['kots'] = this.kots!.map((v) => v.toJson()).toList();
    }
    if (this.totals != null) {
      data['totals'] = this.totals!.toJson();
    }
    data['number_of_pax'] = this.numberOfPax;
    data['tax_mode_at_order'] = this.taxModeAtOrder;
    data['tax_inclusive_at_order'] = this.taxInclusiveAtOrder;
    data['delivery_fee'] = this.deliveryFee;
    data['customer_lat'] = this.customerLat;
    data['customer_lng'] = this.customerLng;
    data['is_within_radius'] = this.isWithinRadius;
    if (this.cancelReason != null) {
      data['cancel_reason'] = this.cancelReason!.toJson();
    }
    data['cancel_reason_id'] = this.cancelReasonId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Table {
  int? id;
  String? tableCode;

  Table({this.id, this.tableCode});

  Table.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tableCode = json['table_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['table_code'] = this.tableCode;
    return data;
  }
}

class Customer {
  int? id;
  String? name;
  String? email;

  Customer({this.id, this.name, this.email});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}

class Waiter {
  int? id;
  String? name;
  String? email;

  Waiter({this.id, this.name, this.email});

  Waiter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}

class Currency {
  int? id;
  String? currencyCode;
  String? currencySymbol;
  String? currencyPosition;
  int? noOfDecimal;
  String? thousandSeparator;
  String? decimalSeparator;

  Currency({
    this.id,
    this.currencyCode,
    this.currencySymbol,
    this.currencyPosition,
    this.noOfDecimal,
    this.thousandSeparator,
    this.decimalSeparator,
  });

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    currencyPosition = json['currency_position'];
    noOfDecimal = json['no_of_decimal'];
    thousandSeparator = json['thousand_separator'];
    decimalSeparator = json['decimal_separator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['currency_code'] = this.currencyCode;
    data['currency_symbol'] = this.currencySymbol;
    data['currency_position'] = this.currencyPosition;
    data['no_of_decimal'] = this.noOfDecimal;
    data['thousand_separator'] = this.thousandSeparator;
    data['decimal_separator'] = this.decimalSeparator;
    return data;
  }
}

class CurrencyConfig {
  String? code;
  String? symbol;
  String? position;
  int? decimalPlaces;
  String? thousandSeparator;
  String? decimalSeparator;

  CurrencyConfig({
    this.code,
    this.symbol,
    this.position,
    this.decimalPlaces,
    this.thousandSeparator,
    this.decimalSeparator,
  });

  CurrencyConfig.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    symbol = json['symbol'];
    position = json['position'];
    decimalPlaces = json['decimal_places'];
    thousandSeparator = json['thousand_separator'];
    decimalSeparator = json['decimal_separator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['symbol'] = this.symbol;
    data['position'] = this.position;
    data['decimal_places'] = this.decimalPlaces;
    data['thousand_separator'] = this.thousandSeparator;
    data['decimal_separator'] = this.decimalSeparator;
    return data;
  }
}

class Items {
  int? id;
  String? itemName;
  String? itemNumber;
  String? variationName;
  List<Modifiers>? modifiers;
  int? quantity;
  String? price;
  String? amount;
  String? formattedAmount;
  String? note;
  String? taxAmount;
  String? taxPercentage;
  TaxBreakup? taxBreakup;
  bool? isDeleted;
  bool? isVariationDeleted;
  int? kotItemId;

  Items({
    this.id,
    this.itemName,
    this.itemNumber,
    this.variationName,
    this.modifiers,
    this.quantity,
    this.price,
    this.amount,
    this.formattedAmount,
    this.note,
    this.taxAmount,
    this.taxPercentage,
    this.taxBreakup,
    this.isDeleted,
    this.isVariationDeleted,
    this.kotItemId,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemName = json['item_name'];
    itemNumber = json['item_number'];
    variationName = json['variation_name'];
    if (json['modifiers'] != null) {
      modifiers = <Modifiers>[];
      json['modifiers'].forEach((v) {
        modifiers!.add(new Modifiers.fromJson(v));
      });
    }
    quantity = json['quantity'];
    price = json['price'];
    amount = json['amount'];
    formattedAmount = json['formatted_amount'];
    note = json['note'];
    taxAmount = json['tax_amount'];
    taxPercentage = json['tax_percentage'];
    taxBreakup =
        json['tax_breakup'] != null
            ? new TaxBreakup.fromJson(json['tax_breakup'])
            : null;
    isDeleted = json['is_deleted'];
    isVariationDeleted = json['is_variation_deleted'];
    kotItemId = json['kot_item_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['item_name'] = this.itemName;
    data['item_number'] = this.itemNumber;
    data['variation_name'] = this.variationName;
    if (this.modifiers != null) {
      data['modifiers'] = this.modifiers!.map((v) => v.toJson()).toList();
    }
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['amount'] = this.amount;
    data['formatted_amount'] = this.formattedAmount;
    data['note'] = this.note;
    data['tax_amount'] = this.taxAmount;
    data['tax_percentage'] = this.taxPercentage;
    if (this.taxBreakup != null) {
      data['tax_breakup'] = this.taxBreakup!.toJson();
    }
    data['is_deleted'] = this.isDeleted;
    data['is_variation_deleted'] = this.isVariationDeleted;
    data['kot_item_id'] = this.kotItemId;
    return data;
  }
}

class Modifiers {
  int? id;
  String? name;
  String? price;

  Modifiers({this.id, this.name, this.price});

  Modifiers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}

class TaxBreakup {
  VAT? vAT;
  VAT? vATAlcohol;
  VAT? vatNonAlcoholic;

  TaxBreakup({this.vAT, this.vATAlcohol, this.vatNonAlcoholic});

  TaxBreakup.fromJson(Map<String, dynamic> json) {
    vAT = json['VAT'] != null ? new VAT.fromJson(json['VAT']) : null;
    vATAlcohol =
        json['VAT Alcohol'] != null
            ? new VAT.fromJson(json['VAT Alcohol'])
            : null;
    vatNonAlcoholic =
        json['Vat Non-Alcoholic'] != null
            ? new VAT.fromJson(json['Vat Non-Alcoholic'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.vAT != null) {
      data['VAT'] = this.vAT!.toJson();
    }
    if (this.vATAlcohol != null) {
      data['VAT Alcohol'] = this.vATAlcohol!.toJson();
    }
    if (this.vatNonAlcoholic != null) {
      data['Vat Non-Alcoholic'] = this.vatNonAlcoholic!.toJson();
    }
    return data;
  }
}

class VAT {
  double? amount;
  String? percent;

  VAT({this.amount, this.percent});

  VAT.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    percent = json['percent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['percent'] = this.percent;
    return data;
  }
}

class Charges {
  int? id;
  String? chargeName;
  String? chargeType;
  String? amount;

  Charges({this.id, this.chargeName, this.chargeType, this.amount});

  Charges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chargeName = json['charge_name'];
    chargeType = json['charge_type'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['charge_name'] = this.chargeName;
    data['charge_type'] = this.chargeType;
    data['amount'] = this.amount;
    return data;
  }
}

class Payments {
  int? id;
  String? amount;
  String? paymentMethod;
  String? createdAt;

  Payments({this.id, this.amount, this.paymentMethod, this.createdAt});

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['amount'] = this.amount;
    data['payment_method'] = this.paymentMethod;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Kots {
  int? id;
  int? kotNumber;
  String? status;

  Kots({this.id, this.kotNumber, this.status});

  Kots.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kotNumber = json['kot_number'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['kot_number'] = this.kotNumber;
    data['status'] = this.status;
    return data;
  }
}

class Totals {
  String? subTotal;
  String? discountAmount;
  String? totalTaxAmount;
  String? tipAmount;
  String? deliveryFee;
  String? total;
  String? amountPaid;

  Totals({
    this.subTotal,
    this.discountAmount,
    this.totalTaxAmount,
    this.tipAmount,
    this.deliveryFee,
    this.total,
    this.amountPaid,
  });

  Totals.fromJson(Map<String, dynamic> json) {
    subTotal = json['sub_total']?.toString();
    discountAmount = json['discount_amount']?.toString();
    totalTaxAmount = json['total_tax_amount']?.toString();
    tipAmount = json['tip_amount']?.toString();
    deliveryFee = json['delivery_fee']?.toString();
    total = json['total']?.toString();
    amountPaid = json['amount_paid']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['sub_total'] = this.subTotal;
    data['discount_amount'] = this.discountAmount;
    data['total_tax_amount'] = this.totalTaxAmount;
    data['tip_amount'] = this.tipAmount;
    data['delivery_fee'] = this.deliveryFee;
    data['total'] = this.total;
    data['amount_paid'] = this.amountPaid;
    return data;
  }
}

class CancelReason {
  int? id;
  String? reason;
  int? cancelOrder;
  int? cancelKot;

  CancelReason({this.id, this.reason, this.cancelOrder, this.cancelKot});

  CancelReason.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reason = json['reason'];
    // Handle both boolean and int for cancel_order
    if (json['cancel_order'] is bool) {
      cancelOrder = (json['cancel_order'] as bool) ? 1 : 0;
    } else {
      cancelOrder = json['cancel_order'];
    }
    // Handle both boolean and int for cancel_kot
    if (json['cancel_kot'] is bool) {
      cancelKot = (json['cancel_kot'] as bool) ? 1 : 0;
    } else {
      cancelKot = json['cancel_kot'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reason'] = this.reason;
    data['cancel_order'] = this.cancelOrder;
    data['cancel_kot'] = this.cancelKot;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['per_page'] = this.perPage;
    data['total'] = this.total;
    return data;
  }
}
