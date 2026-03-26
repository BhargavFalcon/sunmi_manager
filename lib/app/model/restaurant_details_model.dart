class RestaurantModel {
  bool? success;
  Data? data;

  RestaurantModel({this.success, this.data});

  RestaurantModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) data['data'] = this.data!.toJson();
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? hash;
  List<Branches>? branches;

  Data({this.id, this.name, this.hash, this.branches});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    hash = json['hash'];
    if (json['branches'] != null) {
      branches = <Branches>[];
      json['branches'].forEach((v) => branches!.add(Branches.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['hash'] = hash;
    if (branches != null) {
      data['branches'] = branches!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Branches {
  int? id;
  int? restaurantId;
  int? taxTypeId; // NEW
  String? name;
  String? logo;
  String? menuPlaceholderImage;
  String? themeHex;
  String? themeRgb;
  String? currencyPosition;
  String? thousandSeparator;
  String? decimalSeparator;
  int? noOfDecimal;
  bool? taxesIncluded;
  String? defaultLanguage;
  Language? language;
  Currency? currency;
  List<AdditionalCharges>? additionalCharges;
  PaymentGateways? paymentGateways;
  List<DeliverySettings>? deliverySettings; // NEW

  Branches({
    this.id,
    this.restaurantId,
    this.taxTypeId,
    this.name,
    this.logo,
    this.menuPlaceholderImage,
    this.themeHex,
    this.themeRgb,
    this.currencyPosition,
    this.thousandSeparator,
    this.decimalSeparator,
    this.noOfDecimal,
    this.taxesIncluded,
    this.defaultLanguage,
    this.language,
    this.currency,
    this.additionalCharges,
    this.paymentGateways,
    this.deliverySettings,
  });

  Branches.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    taxTypeId = json['tax_type_id'];
    name = json['name'];
    logo = json['logo'];
    menuPlaceholderImage = json['menu_placeholder_image'];
    themeHex = json['theme_hex'];
    themeRgb = json['theme_rgb'];
    currencyPosition = json['currency_position'];
    thousandSeparator = json['thousand_separator'];
    decimalSeparator = json['decimal_separator'];
    noOfDecimal = json['no_of_decimal'];
    taxesIncluded = json['taxes_included'];
    defaultLanguage = json['default_language'];
    language =
        json['language'] != null ? Language.fromJson(json['language']) : null;
    currency =
        json['currency'] != null ? Currency.fromJson(json['currency']) : null;
    if (json['additional_charges'] != null) {
      additionalCharges = <AdditionalCharges>[];
      json['additional_charges'].forEach(
        (v) => additionalCharges!.add(AdditionalCharges.fromJson(v)),
      );
    }
    paymentGateways =
        json['payment_gateways'] != null
            ? PaymentGateways.fromJson(json['payment_gateways'])
            : null;
    if (json['delivery_settings'] != null) {
      deliverySettings = <DeliverySettings>[];
      json['delivery_settings'].forEach(
        (v) => deliverySettings!.add(DeliverySettings.fromJson(v)),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['tax_type_id'] = taxTypeId;
    data['name'] = name;
    data['logo'] = logo;
    data['menu_placeholder_image'] = menuPlaceholderImage;
    data['theme_hex'] = themeHex;
    data['theme_rgb'] = themeRgb;
    data['currency_position'] = currencyPosition;
    data['thousand_separator'] = thousandSeparator;
    data['decimal_separator'] = decimalSeparator;
    data['no_of_decimal'] = noOfDecimal;
    data['taxes_included'] = taxesIncluded;
    data['default_language'] = defaultLanguage;
    if (language != null) data['language'] = language!.toJson();
    if (currency != null) data['currency'] = currency!.toJson();
    if (additionalCharges != null) {
      data['additional_charges'] =
          additionalCharges!.map((v) => v.toJson()).toList();
    }
    if (paymentGateways != null) {
      data['payment_gateways'] = paymentGateways!.toJson();
    }
    if (deliverySettings != null) {
      data['delivery_settings'] =
          deliverySettings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Language {
  int? id;
  String? languageCode;
  String? languageName;
  int? active;
  String? flagUrl;

  Language({
    this.id,
    this.languageCode,
    this.languageName,
    this.active,
    this.flagUrl,
  });

  Language.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    languageCode = json['language_code'];
    languageName = json['language_name'];
    active = json['active'];
    flagUrl = json['flag_url'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'language_code': languageCode,
    'language_name': languageName,
    'active': active,
    'flag_url': flagUrl,
  };
}

class Currency {
  int? id;
  String? name;
  String? currency;
  String? code;
  String? isoCode;

  Currency({this.id, this.name, this.currency, this.code, this.isoCode});

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    currency = json['currency'];
    code = json['code'];
    isoCode = json['iso_code'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'currency': currency,
    'code': code,
    'iso_code': isoCode,
  };
}

class AdditionalCharges {
  int? id;
  String? name;
  String? type;
  String? rate;
  int? isEnabled;
  List<String>? orderTypes;

  AdditionalCharges({
    this.id,
    this.name,
    this.type,
    this.rate,
    this.isEnabled,
    this.orderTypes,
  });

  AdditionalCharges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    rate = json['rate'];
    isEnabled = json['is_enabled'];
    orderTypes =
        json['order_types'] != null
            ? List<String>.from(json['order_types'])
            : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'rate': rate,
    'is_enabled': isEnabled,
    'order_types': orderTypes,
  };
}

class PaymentGateways {
  int? id;
  int? restaurantId;
  dynamic isDeliveryPaymentEnabled;
  dynamic isPickupPaymentEnabled;
  dynamic razorpayStatus;
  dynamic stripeStatus;
  dynamic isCashPaymentEnabled;
  dynamic isQrPaymentEnabled;
  dynamic isOfflinePaymentEnabled;
  String? offlinePaymentDetail;
  String? qrCodeImage;
  String? posDefaultGateway; // NEW
  dynamic isPosOtherCardsEnabled; // NEW
  dynamic isPosVoucherEnabled; // NEW
  dynamic isPosInvoiceEnabled; // NEW
  String? posInvoiceBankDetails; // NEW
  List<String>? enabledPaymentMethods; // NEW

  PaymentGateways({
    this.id,
    this.restaurantId,
    this.isDeliveryPaymentEnabled,
    this.isPickupPaymentEnabled,
    this.razorpayStatus,
    this.stripeStatus,
    this.isCashPaymentEnabled,
    this.isQrPaymentEnabled,
    this.isOfflinePaymentEnabled,
    this.offlinePaymentDetail,
    this.qrCodeImage,
    this.posDefaultGateway,
    this.isPosOtherCardsEnabled,
    this.isPosVoucherEnabled,
    this.isPosInvoiceEnabled,
    this.posInvoiceBankDetails,
    this.enabledPaymentMethods,
  });

  PaymentGateways.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    isDeliveryPaymentEnabled = json['is_delivery_payment_enabled'];
    isPickupPaymentEnabled = json['is_pickup_payment_enabled'];
    razorpayStatus = json['razorpay_status'];
    stripeStatus = json['stripe_status'];
    isCashPaymentEnabled = json['is_cash_payment_enabled'];
    isQrPaymentEnabled = json['is_qr_payment_enabled'];
    isOfflinePaymentEnabled = json['is_offline_payment_enabled'];
    offlinePaymentDetail = json['offline_payment_detail'];
    qrCodeImage = json['qr_code_image'];
    posDefaultGateway = json['pos_default_gateway'];
    isPosOtherCardsEnabled = json['is_pos_other_cards_enabled'];
    isPosVoucherEnabled = json['is_pos_voucher_enabled'];
    isPosInvoiceEnabled = json['is_pos_invoice_enabled'];
    posInvoiceBankDetails = json['pos_invoice_bank_details'];
    enabledPaymentMethods =
        json['enabled_payment_methods'] != null
            ? List<String>.from(json['enabled_payment_methods'])
            : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurant_id': restaurantId,
    'is_delivery_payment_enabled': isDeliveryPaymentEnabled,
    'is_pickup_payment_enabled': isPickupPaymentEnabled,
    'razorpay_status': razorpayStatus,
    'stripe_status': stripeStatus,
    'is_cash_payment_enabled': isCashPaymentEnabled,
    'is_qr_payment_enabled': isQrPaymentEnabled,
    'is_offline_payment_enabled': isOfflinePaymentEnabled,
    'offline_payment_detail': offlinePaymentDetail,
    'qr_code_image': qrCodeImage,
    'pos_default_gateway': posDefaultGateway,
    'is_pos_other_cards_enabled': isPosOtherCardsEnabled,
    'is_pos_voucher_enabled': isPosVoucherEnabled,
    'is_pos_invoice_enabled': isPosInvoiceEnabled,
    'pos_invoice_bank_details': posInvoiceBankDetails,
    'enabled_payment_methods': enabledPaymentMethods,
  };
}

/// NEW class — maps the `delivery_settings` array in the branch response.
class DeliverySettings {
  int? id;
  int? branchId;
  int? maxRadius;
  String? unit;
  String? feeType;
  double? fixedFee;
  double? perDistanceRate;
  double? freeDeliveryOverAmount;
  double? minimumOrderAmount;
  dynamic freeDeliveryWithinRadius;
  String? deliveryScheduleStart;
  String? deliveryScheduleEnd;
  int? prepTimeMinutes;
  int? additionalEtaBufferTime;
  int? avgDeliverySpeedKmh;
  bool? isEnabled;
  List<dynamic>? zipcodes;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? feeTiers;

  DeliverySettings({
    this.id,
    this.branchId,
    this.maxRadius,
    this.unit,
    this.feeType,
    this.fixedFee,
    this.perDistanceRate,
    this.freeDeliveryOverAmount,
    this.minimumOrderAmount,
    this.freeDeliveryWithinRadius,
    this.deliveryScheduleStart,
    this.deliveryScheduleEnd,
    this.prepTimeMinutes,
    this.additionalEtaBufferTime,
    this.avgDeliverySpeedKmh,
    this.isEnabled,
    this.zipcodes,
    this.createdAt,
    this.updatedAt,
    this.feeTiers,
  });

  DeliverySettings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    branchId = json['branch_id'];
    maxRadius = json['max_radius'];
    unit = json['unit'];
    feeType = json['fee_type'];
    fixedFee = (json['fixed_fee'] as num?)?.toDouble();
    perDistanceRate = (json['per_distance_rate'] as num?)?.toDouble();
    freeDeliveryOverAmount =
        (json['free_delivery_over_amount'] as num?)?.toDouble();
    minimumOrderAmount = (json['minimum_order_amount'] as num?)?.toDouble();
    freeDeliveryWithinRadius = json['free_delivery_within_radius'];
    deliveryScheduleStart = json['delivery_schedule_start'];
    deliveryScheduleEnd = json['delivery_schedule_end'];
    prepTimeMinutes = json['prep_time_minutes'];
    additionalEtaBufferTime = json['additional_eta_buffer_time'];
    avgDeliverySpeedKmh = json['avg_delivery_speed_kmh'];
    isEnabled = json['is_enabled'];
    zipcodes =
        json['zipcodes'] != null ? List<dynamic>.from(json['zipcodes']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    feeTiers =
        json['fee_tiers'] != null
            ? List<dynamic>.from(json['fee_tiers'])
            : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'branch_id': branchId,
    'max_radius': maxRadius,
    'unit': unit,
    'fee_type': feeType,
    'fixed_fee': fixedFee,
    'per_distance_rate': perDistanceRate,
    'free_delivery_over_amount': freeDeliveryOverAmount,
    'minimum_order_amount': minimumOrderAmount,
    'free_delivery_within_radius': freeDeliveryWithinRadius,
    'delivery_schedule_start': deliveryScheduleStart,
    'delivery_schedule_end': deliveryScheduleEnd,
    'prep_time_minutes': prepTimeMinutes,
    'additional_eta_buffer_time': additionalEtaBufferTime,
    'avg_delivery_speed_kmh': avgDeliverySpeedKmh,
    'is_enabled': isEnabled,
    'zipcodes': zipcodes,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'fee_tiers': feeTiers,
  };
}
