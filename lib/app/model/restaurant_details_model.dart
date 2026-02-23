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
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
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
      json['branches'].forEach((v) {
        branches!.add(Branches.fromJson(v));
      });
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

  Branches({
    this.id,
    this.restaurantId,
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
  });

  Branches.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
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
        json['language'] != null
            ? Language.fromJson(json['language'])
            : null;
    currency =
        json['currency'] != null
            ? Currency.fromJson(json['currency'])
            : null;
    if (json['additional_charges'] != null) {
      additionalCharges = <AdditionalCharges>[];
      json['additional_charges'].forEach((v) {
        additionalCharges!.add(AdditionalCharges.fromJson(v));
      });
    }
    paymentGateways =
        json['payment_gateways'] != null
            ? PaymentGateways.fromJson(json['payment_gateways'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
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
    if (language != null) {
      data['language'] = language!.toJson();
    }
    if (currency != null) {
      data['currency'] = currency!.toJson();
    }
    if (additionalCharges != null) {
      data['additional_charges'] =
          additionalCharges!.map((v) => v.toJson()).toList();
    }
    if (paymentGateways != null) {
      data['payment_gateways'] = paymentGateways!.toJson();
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['language_code'] = languageCode;
    data['language_name'] = languageName;
    data['active'] = active;
    data['flag_url'] = flagUrl;
    return data;
  }
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['currency'] = currency;
    data['code'] = code;
    data['iso_code'] = isoCode;
    return data;
  }
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
    orderTypes = json['order_types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['rate'] = rate;
    data['is_enabled'] = isEnabled;
    data['order_types'] = orderTypes;
    return data;
  }
}

class PaymentGateways {
  int? id;
  int? restaurantId;
  int? isDeliveryPaymentEnabled;
  int? isPickupPaymentEnabled;
  int? razorpayStatus;
  int? stripeStatus;
  int? isCashPaymentEnabled;
  int? isQrPaymentEnabled;
  int? isOfflinePaymentEnabled;
  String? offlinePaymentDetail;
  Null qrCodeImage;

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['is_delivery_payment_enabled'] = isDeliveryPaymentEnabled;
    data['is_pickup_payment_enabled'] = isPickupPaymentEnabled;
    data['razorpay_status'] = razorpayStatus;
    data['stripe_status'] = stripeStatus;
    data['is_cash_payment_enabled'] = isCashPaymentEnabled;
    data['is_qr_payment_enabled'] = isQrPaymentEnabled;
    data['is_offline_payment_enabled'] = isOfflinePaymentEnabled;
    data['offline_payment_detail'] = offlinePaymentDetail;
    data['qr_code_image'] = qrCodeImage;
    return data;
  }
}
