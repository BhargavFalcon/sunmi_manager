class GetOrderModel {
  bool? success;
  Data? data;

  GetOrderModel({this.success, this.data});

  GetOrderModel.fromJson(Map<String, dynamic> json) {
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
  Invoice? invoice;
  OrderData? order;

  Data({this.invoice, this.order});

  Data.fromJson(Map<String, dynamic> json) {
    invoice =
        json['invoice'] != null ? new Invoice.fromJson(json['invoice']) : null;
    order =
        json['order'] != null ? new OrderData.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.invoice != null) {
      data['invoice'] = this.invoice!.toJson();
    }
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    return data;
  }
}

class Invoice {
  Restaurant? restaurant;
  Branch? branch;
  int? branchId;
  int? restaurantId;
  ReceiptSettings? receiptSettings;
  String? pdfUrl;
  String? imageUrl;
  String? invoiceUrl;
  OrderData? order;
  List<Taxes>? taxes;
  double? totalTax;
  bool? isInclusive;
  String? taxMode;
  bool? taxInclusive;
  CurrencyConfig? currencyConfig;

  Invoice({
    this.restaurant,
    this.branch,
    this.branchId,
    this.restaurantId,
    this.receiptSettings,
    this.pdfUrl,
    this.imageUrl,
    this.invoiceUrl,
    this.order,
    this.taxes,
    this.totalTax,
    this.isInclusive,
    this.taxMode,
    this.taxInclusive,
    this.currencyConfig,
  });

  Invoice.fromJson(Map<String, dynamic> json) {
    restaurant =
        json['restaurant'] != null
            ? new Restaurant.fromJson(json['restaurant'])
            : null;
    branch =
        json['branch'] != null ? new Branch.fromJson(json['branch']) : null;
    branchId = json['branch_id'];
    restaurantId = json['restaurant_id'];
    receiptSettings =
        json['receipt_settings'] != null
            ? new ReceiptSettings.fromJson(json['receipt_settings'])
            : null;
    pdfUrl = json['pdf_url'];
    imageUrl = json['image_url'];
    invoiceUrl = json['invoice_url'];
    order =
        json['order'] != null ? new OrderData.fromJson(json['order']) : null;
    if (json['taxes'] != null) {
      taxes = <Taxes>[];
      json['taxes'].forEach((v) {
        taxes!.add(new Taxes.fromJson(v));
      });
    }
    totalTax = json['total_tax']?.toDouble();
    isInclusive = json['is_inclusive'];
    taxMode = json['tax_mode'];
    taxInclusive = json['tax_inclusive'];
    currencyConfig =
        json['currency_config'] != null
            ? new CurrencyConfig.fromJson(json['currency_config'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.restaurant != null) {
      data['restaurant'] = this.restaurant!.toJson();
    }
    if (this.branch != null) {
      data['branch'] = this.branch!.toJson();
    }
    data['branch_id'] = this.branchId;
    data['restaurant_id'] = this.restaurantId;
    if (this.receiptSettings != null) {
      data['receipt_settings'] = this.receiptSettings!.toJson();
    }
    data['pdf_url'] = this.pdfUrl;
    data['image_url'] = this.imageUrl;
    data['invoice_url'] = this.invoiceUrl;
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
    }
    data['total_tax'] = this.totalTax;
    data['is_inclusive'] = this.isInclusive;
    data['tax_mode'] = this.taxMode;
    data['tax_inclusive'] = this.taxInclusive;
    if (this.currencyConfig != null) {
      data['currency_config'] = this.currencyConfig!.toJson();
    }
    return data;
  }
}

class Restaurant {
  int? id;
  String? name;
  String? hash;
  String? logoUrl;
  String? heroImageUrl;
  Map<String, dynamic>? currency;
  String? timezone;
  String? locale;
  String? taxMode;
  bool? taxInclusive;
  bool? allowCustomerDeliveryOrders;
  bool? allowCustomerPickupOrders;
  List<Branch>? branches;
  int? currentBranchId;

  Restaurant({
    this.id,
    this.name,
    this.hash,
    this.logoUrl,
    this.heroImageUrl,
    this.currency,
    this.timezone,
    this.locale,
    this.taxMode,
    this.taxInclusive,
    this.allowCustomerDeliveryOrders,
    this.allowCustomerPickupOrders,
    this.branches,
    this.currentBranchId,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    hash = json['hash'];
    logoUrl = json['logo_url'];
    heroImageUrl = json['hero_image_url'];
    currency = json['currency'];
    timezone = json['timezone'];
    locale = json['locale'];
    taxMode = json['tax_mode'];
    taxInclusive = json['tax_inclusive'];
    allowCustomerDeliveryOrders = json['allow_customer_delivery_orders'];
    allowCustomerPickupOrders = json['allow_customer_pickup_orders'];
    if (json['branches'] != null) {
      branches = <Branch>[];
      json['branches'].forEach((v) {
        branches!.add(new Branch.fromJson(v));
      });
    }
    currentBranchId = json['current_branch_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['hash'] = this.hash;
    data['logo_url'] = this.logoUrl;
    data['hero_image_url'] = this.heroImageUrl;
    data['currency'] = this.currency;
    data['timezone'] = this.timezone;
    data['locale'] = this.locale;
    data['tax_mode'] = this.taxMode;
    data['tax_inclusive'] = this.taxInclusive;
    data['allow_customer_delivery_orders'] = this.allowCustomerDeliveryOrders;
    data['allow_customer_pickup_orders'] = this.allowCustomerPickupOrders;
    if (this.branches != null) {
      data['branches'] = this.branches!.map((v) => v.toJson()).toList();
    }
    data['current_branch_id'] = this.currentBranchId;
    return data;
  }
}

class Branch {
  int? id;
  String? name;
  String? address;
  double? lat;
  double? lng;
  int? restaurantId;
  int? parentRestaurantId;
  String? createdAt;
  String? updatedAt;

  Branch({
    this.id,
    this.name,
    this.address,
    this.lat,
    this.lng,
    this.restaurantId,
    this.parentRestaurantId,
    this.createdAt,
    this.updatedAt,
  });

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    lat = json['lat']?.toDouble();
    lng = json['lng']?.toDouble();
    restaurantId = json['restaurant_id'];
    parentRestaurantId = json['parent_restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['restaurant_id'] = this.restaurantId;
    data['parent_restaurant_id'] = this.parentRestaurantId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
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

  ReceiptSettings({
    this.showRestaurantLogo,
    this.showCustomerName,
    this.showCustomerAddress,
    this.showTableNumber,
    this.showWaiter,
    this.showTotalGuest,
    this.showTax,
    this.showPaymentQrCode,
    this.showPaymentDetails,
    this.showOrderType,
    this.paymentQrCodeUrl,
  });

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['show_restaurant_logo'] = this.showRestaurantLogo;
    data['show_customer_name'] = this.showCustomerName;
    data['show_customer_address'] = this.showCustomerAddress;
    data['show_table_number'] = this.showTableNumber;
    data['show_waiter'] = this.showWaiter;
    data['show_total_guest'] = this.showTotalGuest;
    data['show_tax'] = this.showTax;
    data['show_payment_qr_code'] = this.showPaymentQrCode;
    data['show_payment_details'] = this.showPaymentDetails;
    data['show_order_type'] = this.showOrderType;
    data['payment_qr_code_url'] = this.paymentQrCodeUrl;
    return data;
  }
}

class OrderData {
  String? uuid;
  int? id;
  int? orderNumber;
  String? formattedOrderNumber;
  String? dateTime;
  String? status;
  String? orderStatus;
  String? orderType;
  int? branchId;
  dynamic table;
  Customer? customer;
  dynamic waiter;
  DeliveryExecutive? deliveryExecutive;
  int? deliveryExecutiveId;
  Currency? currency;
  int? currencyId;
  CurrencyConfig? currencyConfig;
  List<Items>? items;
  List<Taxes>? taxes;
  List<Charges>? charges;
  List<Payments>? payments;
  dynamic kots;
  Totals? totals;
  int? numberOfPax;
  String? discountType;
  dynamic discountValue;
  String? note;
  String? taxModeAtOrder;
  bool? taxInclusiveAtOrder;
  List<dynamic>? orderTaxBreakup;
  String? deliveryAddress;
  List<dynamic>? cancelReason;
  int? cancelReasonId;
  String? cancelReasonText;
  String? createdAt;
  String? updatedAt;

  OrderData({
    this.uuid,
    this.id,
    this.orderNumber,
    this.formattedOrderNumber,
    this.dateTime,
    this.status,
    this.orderStatus,
    this.orderType,
    this.branchId,
    this.table,
    this.customer,
    this.waiter,
    this.deliveryExecutive,
    this.deliveryExecutiveId,
    this.currency,
    this.currencyId,
    this.currencyConfig,
    this.items,
    this.taxes,
    this.charges,
    this.payments,
    this.kots,
    this.totals,
    this.numberOfPax,
    this.discountType,
    this.discountValue,
    this.note,
    this.taxModeAtOrder,
    this.taxInclusiveAtOrder,
    this.orderTaxBreakup,
    this.deliveryAddress,
    this.cancelReason,
    this.cancelReasonId,
    this.cancelReasonText,
    this.createdAt,
    this.updatedAt,
  });

  OrderData.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    id =
        json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null);
    orderNumber =
        json['order_number'] is int
            ? json['order_number']
            : (json['order_number'] is String
                ? int.tryParse(json['order_number'])
                : null);
    formattedOrderNumber = json['formatted_order_number'];
    dateTime = json['date_time'];
    status = json['status'];
    orderStatus = json['order_status'];
    orderType = json['order_type'];
    branchId =
        json['branch_id'] is int
            ? json['branch_id']
            : (json['branch_id'] is String
                ? int.tryParse(json['branch_id'])
                : null);

    if (json['table'] != null) {
      if (json['table'] is List) {
        table = json['table'];
      } else if (json['table'] is Map) {
        table = new Table.fromJson(json['table']);
      }
    }

    customer =
        json['customer'] != null
            ? new Customer.fromJson(json['customer'])
            : null;

    if (json['waiter'] != null) {
      if (json['waiter'] is List) {
        waiter = json['waiter'];
      } else if (json['waiter'] is Map) {
        waiter = new Waiter.fromJson(json['waiter']);
      }
    }

    if (json['delivery_executive'] != null &&
        json['delivery_executive'] is Map) {
      deliveryExecutive = new DeliveryExecutive.fromJson(
        json['delivery_executive'],
      );
    }
    deliveryExecutiveId =
        json['delivery_executive_id'] is int
            ? json['delivery_executive_id']
            : (json['delivery_executive_id'] is String
                ? int.tryParse(json['delivery_executive_id'])
                : null);

    currency =
        json['currency'] != null
            ? new Currency.fromJson(json['currency'])
            : null;
    currencyId =
        json['currency_id'] is int
            ? json['currency_id']
            : (json['currency_id'] is String
                ? int.tryParse(json['currency_id'])
                : null);
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
    if (json['taxes'] != null) {
      taxes = <Taxes>[];
      json['taxes'].forEach((v) {
        taxes!.add(new Taxes.fromJson(v));
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
    kots = json['kots'];
    totals =
        json['totals'] != null ? new Totals.fromJson(json['totals']) : null;
    numberOfPax =
        json['number_of_pax'] is int
            ? json['number_of_pax']
            : (json['number_of_pax'] is String
                ? int.tryParse(json['number_of_pax'])
                : null);
    discountType = json['discount_type'];
    discountValue = json['discount_value'];
    note = json['note'];
    taxModeAtOrder = json['tax_mode_at_order'];
    taxInclusiveAtOrder =
        json['tax_inclusive_at_order'] is bool
            ? json['tax_inclusive_at_order']
            : (json['tax_inclusive_at_order'] == 1 ||
                json['tax_inclusive_at_order'] == true);
    orderTaxBreakup = json['order_tax_breakup'];
    deliveryAddress = json['delivery_address'];
    cancelReason = json['cancel_reason'];
    cancelReasonId =
        json['cancel_reason_id'] is int
            ? json['cancel_reason_id']
            : (json['cancel_reason_id'] is String
                ? int.tryParse(json['cancel_reason_id'])
                : null);
    cancelReasonText = json['cancel_reason_text'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['id'] = this.id;
    data['order_number'] = this.orderNumber;
    data['formatted_order_number'] = this.formattedOrderNumber;
    data['date_time'] = this.dateTime;
    data['status'] = this.status;
    data['order_status'] = this.orderStatus;
    data['order_type'] = this.orderType;
    data['branch_id'] = this.branchId;
    data['table'] =
        this.table is Table ? (this.table as Table).toJson() : this.table;
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    data['waiter'] =
        this.waiter is Waiter ? (this.waiter as Waiter).toJson() : this.waiter;
    if (this.deliveryExecutive != null) {
      data['delivery_executive'] = this.deliveryExecutive!.toJson();
    }
    data['delivery_executive_id'] = this.deliveryExecutiveId;
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
    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
    }
    if (this.charges != null) {
      data['charges'] = this.charges!.map((v) => v.toJson()).toList();
    }
    if (this.payments != null) {
      data['payments'] = this.payments!.map((v) => v.toJson()).toList();
    }
    data['kots'] = this.kots;
    if (this.totals != null) {
      data['totals'] = this.totals!.toJson();
    }
    data['number_of_pax'] = this.numberOfPax;
    data['discount_type'] = this.discountType;
    data['discount_value'] = this.discountValue;
    data['note'] = this.note;
    data['tax_mode_at_order'] = this.taxModeAtOrder;
    data['tax_inclusive_at_order'] = this.taxInclusiveAtOrder;
    data['order_tax_breakup'] = this.orderTaxBreakup;
    data['delivery_address'] = this.deliveryAddress;
    data['cancel_reason'] = this.cancelReason;
    data['cancel_reason_id'] = this.cancelReasonId;
    data['cancel_reason_text'] = this.cancelReasonText;
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
  String? phoneNumber;
  String? phoneCode;
  Map<String, dynamic>? addresses;
  Map<String, dynamic>? orderCount;

  Customer({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.phoneCode,
    this.addresses,
    this.orderCount,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number']?.toString();
    phoneCode = json['phone_code']?.toString();
    addresses = json['addresses'];
    orderCount = json['order_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    data['phone_code'] = this.phoneCode;
    data['addresses'] = this.addresses;
    data['order_count'] = this.orderCount;
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

class DeliveryExecutive {
  Map<String, dynamic>? data;

  DeliveryExecutive({this.data});

  DeliveryExecutive.fromJson(Map<String, dynamic> json) {
    data = json;
  }

  Map<String, dynamic> toJson() {
    return data ?? {};
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
  dynamic price;
  dynamic amount;
  String? formattedPrice;
  String? formattedAmount;
  String? note;
  dynamic taxAmount;
  dynamic taxPercentage;
  bool? isDeleted;
  bool? isVariationDeleted;
  int? kotItemId;
  String? snapshotTableCode;
  String? snapshotWaiterName;
  String? snapshotCustomerName;
  String? snapshotDeliveryAddress;
  String? snapshotPreorderDatetime;
  String? createdAt;
  TaxBreakup? taxBreakup;

  Items({
    this.id,
    this.itemName,
    this.itemNumber,
    this.variationName,
    this.modifiers,
    this.quantity,
    this.price,
    this.amount,
    this.formattedPrice,
    this.formattedAmount,
    this.note,
    this.taxAmount,
    this.taxPercentage,
    this.isDeleted,
    this.isVariationDeleted,
    this.kotItemId,
    this.snapshotTableCode,
    this.snapshotWaiterName,
    this.snapshotCustomerName,
    this.snapshotDeliveryAddress,
    this.snapshotPreorderDatetime,
    this.createdAt,
    this.taxBreakup,
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
    formattedPrice = json['formatted_price'];
    formattedAmount = json['formatted_amount'];
    note = json['note'];
    taxAmount = json['tax_amount'];
    taxPercentage = json['tax_percentage'];
    isDeleted = json['is_deleted'];
    isVariationDeleted = json['is_variation_deleted'];
    kotItemId = json['kot_item_id'];
    snapshotTableCode = json['snapshot_table_code'];
    snapshotWaiterName = json['snapshot_waiter_name'];
    snapshotCustomerName = json['snapshot_customer_name'];
    snapshotDeliveryAddress = json['snapshot_delivery_address'];
    snapshotPreorderDatetime = json['snapshot_preorder_datetime'];
    createdAt = json['created_at'];
    taxBreakup =
        json['tax_breakup'] != null
            ? new TaxBreakup.fromJson(json['tax_breakup'])
            : null;
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
    data['formatted_price'] = this.formattedPrice;
    data['formatted_amount'] = this.formattedAmount;
    data['note'] = this.note;
    data['tax_amount'] = this.taxAmount;
    data['tax_percentage'] = this.taxPercentage;
    data['is_deleted'] = this.isDeleted;
    data['is_variation_deleted'] = this.isVariationDeleted;
    data['kot_item_id'] = this.kotItemId;
    data['snapshot_table_code'] = this.snapshotTableCode;
    data['snapshot_waiter_name'] = this.snapshotWaiterName;
    data['snapshot_customer_name'] = this.snapshotCustomerName;
    data['snapshot_delivery_address'] = this.snapshotDeliveryAddress;
    data['snapshot_preorder_datetime'] = this.snapshotPreorderDatetime;
    data['created_at'] = this.createdAt;
    if (this.taxBreakup != null) {
      data['tax_breakup'] = this.taxBreakup!.toJson();
    }
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
    price = json['price']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}

class Taxes {
  String? taxName;
  dynamic percent;
  dynamic amount;

  Taxes({this.taxName, this.percent, this.amount});

  Taxes.fromJson(Map<String, dynamic> json) {
    taxName = json['tax_name'];
    percent = json['percent'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tax_name'] = this.taxName;
    data['percent'] = this.percent;
    data['amount'] = this.amount;
    return data;
  }
}

class Charges {
  int? id;
  String? chargeName;
  String? chargeType;
  dynamic amount;

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
  dynamic amount;
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

class TaxBreakup {
  Map<String, TaxValue> taxes = {};

  TaxBreakup({Map<String, TaxValue>? taxes}) {
    if (taxes != null) {
      this.taxes = taxes;
    }
  }

  TaxBreakup.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      taxes[key] = TaxValue.fromJson(value);
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    taxes.forEach((key, value) {
      data[key] = value.toJson();
    });
    return data;
  }
}

class TaxValue {
  String? amount;
  String? percent;

  TaxValue({this.amount, this.percent});

  TaxValue.fromJson(Map<String, dynamic> json) {
    amount = _parseToString(json['amount']);
    percent = _parseToString(json['percent']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['percent'] = this.percent;
    return data;
  }

  static String? _parseToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
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
  dynamic subTotal;
  dynamic totalTaxAmount;
  dynamic tipAmount;
  dynamic deliveryFee;
  dynamic total;
  dynamic amountPaid;

  Totals({
    this.subTotal,
    this.totalTaxAmount,
    this.tipAmount,
    this.deliveryFee,
    this.total,
    this.amountPaid,
  });

  Totals.fromJson(Map<String, dynamic> json) {
    subTotal = json['sub_total'];
    totalTaxAmount = json['total_tax_amount'];
    tipAmount = json['tip_amount'];
    deliveryFee = json['delivery_fee'];
    total = json['total'];
    amountPaid = json['amount_paid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sub_total'] = this.subTotal;
    data['total_tax_amount'] = this.totalTaxAmount;
    data['tip_amount'] = this.tipAmount;
    data['delivery_fee'] = this.deliveryFee;
    data['total'] = this.total;
    data['amount_paid'] = this.amountPaid;
    return data;
  }
}
