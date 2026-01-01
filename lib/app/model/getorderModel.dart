// Helper functions for safe type conversion
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

T? _fromJson<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) return fromJson(json);
  return null;
}

List<T>? _listFromJson<T>(
  dynamic json,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (json == null || json is! List) return null;
  return json.whereType<Map<String, dynamic>>().map(fromJson).toList();
}

Map<String, dynamic>? _mapFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) return Map<String, dynamic>.from(json);
  return null;
}

List<dynamic>? _toDynamicList(dynamic value) {
  if (value == null) return null;
  if (value is List) return value;
  // If it's a Map (empty object {}), return empty list
  if (value is Map) return <dynamic>[];
  return null;
}

class GetOrderModel {
  bool? success;
  Data? data;
  String? message;

  GetOrderModel({this.success, this.data, this.message});

  GetOrderModel.fromJson(Map<String, dynamic> json)
    : success = json['success'],
      data = _fromJson(json['data'], Data.fromJson),
      message = json['message'];

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
    'message': message,
  };
}

class Data {
  Restaurant? restaurant;
  Branch? branch;
  int? branchId;
  int? restaurantId;
  ReceiptSettings? receiptSettings;
  String? pdfUrl;
  String? imageUrl;
  String? invoiceUrl;
  Order? order;
  List<Taxes>? taxes;
  double? totalTax;
  bool? isInclusive;
  String? taxMode;
  bool? taxInclusive;

  Data({
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
  });

  Data.fromJson(Map<String, dynamic> json)
    : restaurant = _fromJson(json['restaurant'], Restaurant.fromJson),
      branch = _fromJson(json['branch'], Branch.fromJson),
      branchId = _toInt(json['branch_id']),
      restaurantId = _toInt(json['restaurant_id']),
      receiptSettings = _fromJson(
        json['receipt_settings'],
        ReceiptSettings.fromJson,
      ),
      pdfUrl = json['pdf_url'],
      imageUrl = json['image_url'],
      invoiceUrl = json['invoice_url'],
      order = _fromJson(json['order'], Order.fromJson),
      taxes = _listFromJson(json['taxes'], Taxes.fromJson),
      totalTax = _toDouble(json['total_tax']),
      isInclusive = json['is_inclusive'],
      taxMode = json['tax_mode'],
      taxInclusive = json['tax_inclusive'];

  Map<String, dynamic> toJson() => {
    'restaurant': restaurant?.toJson(),
    'branch': branch?.toJson(),
    'branch_id': branchId,
    'restaurant_id': restaurantId,
    'receipt_settings': receiptSettings?.toJson(),
    'pdf_url': pdfUrl,
    'image_url': imageUrl,
    'invoice_url': invoiceUrl,
    'order': order?.toJson(),
    'taxes': taxes?.map((v) => v.toJson()).toList(),
    'total_tax': totalTax,
    'is_inclusive': isInclusive,
    'tax_mode': taxMode,
    'tax_inclusive': taxInclusive,
  };
}

class Restaurant {
  int? id;
  String? name;
  String? hash;
  Map<String, dynamic>? currency;
  String? timezone;
  String? locale;
  String? taxMode;
  bool? taxInclusive;
  bool? allowCustomerDeliveryOrders;
  bool? allowCustomerPickupOrders;
  int? currentBranchId;

  Restaurant({
    this.id,
    this.name,
    this.hash,
    this.currency,
    this.timezone,
    this.locale,
    this.taxMode,
    this.taxInclusive,
    this.allowCustomerDeliveryOrders,
    this.allowCustomerPickupOrders,
    this.currentBranchId,
  });

  Restaurant.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      name = json['name'],
      hash = json['hash'],
      currency = _mapFromJson(json['currency']),
      timezone = json['timezone'],
      locale = json['locale'],
      taxMode = json['tax_mode'],
      taxInclusive = json['tax_inclusive'],
      allowCustomerDeliveryOrders = json['allow_customer_delivery_orders'],
      allowCustomerPickupOrders = json['allow_customer_pickup_orders'],
      currentBranchId = json['current_branch_id'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hash': hash,
    'currency': currency,
    'timezone': timezone,
    'locale': locale,
    'tax_mode': taxMode,
    'tax_inclusive': taxInclusive,
    'allow_customer_delivery_orders': allowCustomerDeliveryOrders,
    'allow_customer_pickup_orders': allowCustomerPickupOrders,
    'current_branch_id': currentBranchId,
  };
}

class Branch {
  int? id;
  String? name;
  String? address;
  int? restaurantId;
  int? parentRestaurantId;
  String? createdAt;
  String? updatedAt;

  Branch({
    this.id,
    this.name,
    this.address,
    this.restaurantId,
    this.parentRestaurantId,
    this.createdAt,
    this.updatedAt,
  });

  Branch.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      name = json['name'],
      address = json['address'],
      restaurantId = _toInt(json['restaurant_id']),
      parentRestaurantId = _toInt(json['parent_restaurant_id']),
      createdAt = json['created_at'],
      updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'restaurant_id': restaurantId,
    'parent_restaurant_id': parentRestaurantId,
    'created_at': createdAt,
    'updated_at': updatedAt,
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

  ReceiptSettings.fromJson(Map<String, dynamic> json)
    : showRestaurantLogo = json['show_restaurant_logo'],
      showCustomerName = json['show_customer_name'],
      showCustomerAddress = json['show_customer_address'],
      showTableNumber = json['show_table_number'],
      showWaiter = json['show_waiter'],
      showTotalGuest = json['show_total_guest'],
      showTax = json['show_tax'],
      showPaymentQrCode = json['show_payment_qr_code'],
      showPaymentDetails = json['show_payment_details'],
      showOrderType = json['show_order_type'],
      paymentQrCodeUrl = json['payment_qr_code_url'];

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

class Order {
  String? uuid;
  int? id;
  String? orderNumber;
  String? formattedOrderNumber;
  String? dateTime;
  String? status;
  String? orderStatus;
  String? orderType;
  int? branchId;
  Table? table;
  Customer? customer;
  Waiter? waiter;
  Map<String, dynamic>? deliveryExecutive;
  int? deliveryExecutiveId;
  Currency? currency;
  int? currencyId;
  List<Items>? items;
  List<Charges>? charges;
  List<Payments>? payments;
  Map<String, dynamic>? kots;
  Totals? totals;
  int? numberOfPax;
  String? discountType;
  int? discountValue;
  String? note;
  String? taxModeAtOrder;
  bool? taxInclusiveAtOrder;
  String? deliveryAddress;
  List<dynamic>? cancelReason;
  int? cancelReasonId;
  String? cancelReasonText;
  String? createdAt;
  String? updatedAt;

  Order({
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
    this.items,
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
    this.deliveryAddress,
    this.cancelReason,
    this.cancelReasonId,
    this.cancelReasonText,
    this.createdAt,
    this.updatedAt,
  });

  Order.fromJson(Map<String, dynamic> json)
    : uuid = json['uuid'],
      id = _toInt(json['id']),
      orderNumber = json['order_number'],
      formattedOrderNumber = json['formatted_order_number'],
      dateTime = json['date_time'],
      status = json['status'],
      orderStatus = json['order_status'],
      orderType = json['order_type'],
      branchId = _toInt(json['branch_id']),
      table = _fromJson(json['table'], Table.fromJson),
      customer = _fromJson(json['customer'], Customer.fromJson),
      waiter = _fromJson(json['waiter'], Waiter.fromJson),
      deliveryExecutive = _mapFromJson(json['delivery_executive']),
      deliveryExecutiveId = _toInt(json['delivery_executive_id']),
      currency = _fromJson(json['currency'], Currency.fromJson),
      currencyId = _toInt(json['currency_id']),
      items = _listFromJson(json['items'], Items.fromJson),
      charges = _listFromJson(json['charges'], Charges.fromJson),
      payments = _listFromJson(json['payments'], Payments.fromJson),
      kots = _mapFromJson(json['kots']),
      totals = _fromJson(json['totals'], Totals.fromJson),
      numberOfPax = _toInt(json['number_of_pax']),
      discountType = json['discount_type'],
      discountValue = _toInt(json['discount_value']),
      note = json['note'],
      taxModeAtOrder = json['tax_mode_at_order'],
      taxInclusiveAtOrder = json['tax_inclusive_at_order'],
      deliveryAddress = json['delivery_address'],
      cancelReason = _toDynamicList(json['cancel_reason']),
      cancelReasonId = _toInt(json['cancel_reason_id']),
      cancelReasonText = json['cancel_reason_text'],
      createdAt = json['created_at'],
      updatedAt = json['updated_at'];

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
    'table': table?.toJson(),
    'customer': customer?.toJson(),
    'waiter': waiter?.toJson(),
    'delivery_executive': deliveryExecutive,
    'delivery_executive_id': deliveryExecutiveId,
    'currency': currency?.toJson(),
    'currency_id': currencyId,
    'items': items?.map((v) => v.toJson()).toList(),
    'charges': charges?.map((v) => v.toJson()).toList(),
    'payments': payments?.map((v) => v.toJson()).toList(),
    'kots': kots,
    'totals': totals?.toJson(),
    'number_of_pax': numberOfPax,
    'discount_type': discountType,
    'discount_value': discountValue,
    'note': note,
    'tax_mode_at_order': taxModeAtOrder,
    'tax_inclusive_at_order': taxInclusiveAtOrder,
    'delivery_address': deliveryAddress,
    'cancel_reason': cancelReason,
    'cancel_reason_id': cancelReasonId,
    'cancel_reason_text': cancelReasonText,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
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

  Customer.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      name = json['name'],
      email = json['email'],
      phoneNumber = json['phone_number'],
      phoneCode = json['phone_code'],
      addresses = _mapFromJson(json['addresses']),
      orderCount = _mapFromJson(json['order_count']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone_number': phoneNumber,
    'phone_code': phoneCode,
    'addresses': addresses,
    'order_count': orderCount,
  };
}

class Waiter {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? phoneCode;
  int? branchId;
  int? restaurantId;

  Waiter({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.phoneCode,
    this.branchId,
    this.restaurantId,
  });

  Waiter.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      name = json['name'],
      email = json['email'],
      phoneNumber = json['phone_number'],
      phoneCode = json['phone_code'],
      branchId = _toInt(json['branch_id']),
      restaurantId = _toInt(json['restaurant_id']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone_number': phoneNumber,
    'phone_code': phoneCode,
    'branch_id': branchId,
    'restaurant_id': restaurantId,
  };
}

class Table {
  int? id;
  String? tableCode;
  int? branchId;
  int? areaId;
  String? hash;
  int? width;
  int? height;
  int? left;
  int? top;
  String? shape;
  int? seatingCapacity;
  String? status;
  String? availableStatus;
  Map<String, dynamic>? area;
  String? qrCodeUrl;
  Map<String, dynamic>? activeOrder;

  Table({
    this.id,
    this.tableCode,
    this.branchId,
    this.areaId,
    this.hash,
    this.width,
    this.height,
    this.left,
    this.top,
    this.shape,
    this.seatingCapacity,
    this.status,
    this.availableStatus,
    this.area,
    this.qrCodeUrl,
    this.activeOrder,
  });

  Table.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      tableCode = json['table_code'],
      branchId = _toInt(json['branch_id']),
      areaId = _toInt(json['area_id']),
      hash = json['hash'],
      width = _toInt(json['width']),
      height = _toInt(json['height']),
      left = _toInt(json['left']),
      top = _toInt(json['top']),
      shape = json['shape'],
      seatingCapacity = _toInt(json['seating_capacity']),
      status = json['status'],
      availableStatus = json['available_status'],
      area = _mapFromJson(json['area']),
      qrCodeUrl = json['qr_code_url'],
      activeOrder = _mapFromJson(json['active_order']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'table_code': tableCode,
    'branch_id': branchId,
    'area_id': areaId,
    'hash': hash,
    'width': width,
    'height': height,
    'left': left,
    'top': top,
    'shape': shape,
    'seating_capacity': seatingCapacity,
    'status': status,
    'available_status': availableStatus,
    'area': area,
    'qr_code_url': qrCodeUrl,
    'active_order': activeOrder,
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

  Currency({
    this.id,
    this.currencyCode,
    this.currencySymbol,
    this.currencyPosition,
    this.noOfDecimal,
    this.thousandSeparator,
    this.decimalSeparator,
  });

  Currency.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      currencyCode = json['currency_code'],
      currencySymbol = json['currency_symbol'],
      currencyPosition = json['currency_position'],
      noOfDecimal = _toInt(json['no_of_decimal']),
      thousandSeparator = json['thousand_separator'],
      decimalSeparator = json['decimal_separator'];

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

class Items {
  int? id;
  String? itemName;
  String? itemNumber;
  String? variationName;
  List<Modifiers>? modifiers;
  int? quantity;
  double? price;
  double? amount;
  String? note;
  double? taxAmount;
  int? taxPercentage;
  bool? isDeleted;
  bool? isVariationDeleted;
  int? kotItemId;
  String? createdAt;

  Items({
    this.id,
    this.itemName,
    this.itemNumber,
    this.variationName,
    this.modifiers,
    this.quantity,
    this.price,
    this.amount,
    this.note,
    this.taxAmount,
    this.taxPercentage,
    this.isDeleted,
    this.isVariationDeleted,
    this.kotItemId,
    this.createdAt,
  });

  Items.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      itemName = json['item_name'],
      itemNumber = json['item_number'],
      variationName = json['variation_name'],
      modifiers = _listFromJson(json['modifiers'], Modifiers.fromJson),
      quantity = _toInt(json['quantity']),
      price = _toDouble(json['price']),
      amount = _toDouble(json['amount']),
      note = json['note'],
      taxAmount = _toDouble(json['tax_amount']),
      taxPercentage = _toInt(json['tax_percentage']),
      isDeleted = json['is_deleted'],
      isVariationDeleted = json['is_variation_deleted'],
      kotItemId = _toInt(json['kot_item_id']),
      createdAt = json['created_at'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'item_name': itemName,
    'item_number': itemNumber,
    'variation_name': variationName,
    'modifiers': modifiers?.map((v) => v.toJson()).toList(),
    'quantity': quantity,
    'price': price,
    'amount': amount,
    'note': note,
    'tax_amount': taxAmount,
    'tax_percentage': taxPercentage,
    'is_deleted': isDeleted,
    'is_variation_deleted': isVariationDeleted,
    'kot_item_id': kotItemId,
    'created_at': createdAt,
  };
}

class Modifiers {
  int? id;
  String? name;
  double? price;

  Modifiers({this.id, this.name, this.price});

  Modifiers.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      name = json['name'],
      price = _toDouble(json['price']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}

class Charges {
  int? id;
  String? chargeName;
  String? chargeType;
  double? amount;

  Charges({this.id, this.chargeName, this.chargeType, this.amount});

  Charges.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      chargeName = json['charge_name'],
      chargeType = json['charge_type'],
      amount = _toDouble(json['amount']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'charge_name': chargeName,
    'charge_type': chargeType,
    'amount': amount,
  };
}

class Payments {
  int? id;
  double? amount;
  String? paymentMethod;
  String? createdAt;

  Payments({this.id, this.amount, this.paymentMethod, this.createdAt});

  Payments.fromJson(Map<String, dynamic> json)
    : id = _toInt(json['id']),
      amount = _toDouble(json['amount']),
      paymentMethod = json['payment_method'],
      createdAt = json['created_at'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'payment_method': paymentMethod,
    'created_at': createdAt,
  };
}

class Totals {
  int? subTotal;
  double? totalTaxAmount;
  double? tipAmount;
  int? deliveryFee;
  double? total;
  int? amountPaid;
  double? discountAmount;

  Totals({
    this.subTotal,
    this.totalTaxAmount,
    this.tipAmount,
    this.deliveryFee,
    this.total,
    this.amountPaid,
    this.discountAmount,
  });

  Totals.fromJson(Map<String, dynamic> json)
    : subTotal = _toInt(json['sub_total']),
      totalTaxAmount = _toDouble(json['total_tax_amount']),
      tipAmount = _toDouble(json['tip_amount']),
      deliveryFee = _toInt(json['delivery_fee']),
      total = _toDouble(json['total']),
      amountPaid = _toInt(json['amount_paid']),
      discountAmount = _toDouble(json['discount_amount']);

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

class Taxes {
  String? taxName;
  int? percent;
  double? amount;

  Taxes({this.taxName, this.percent, this.amount});

  Taxes.fromJson(Map<String, dynamic> json)
    : taxName = json['tax_name'],
      percent = _toInt(json['percent']),
      amount = _toDouble(json['amount']);

  Map<String, dynamic> toJson() => {
    'tax_name': taxName,
    'percent': percent,
    'amount': amount,
  };
}
