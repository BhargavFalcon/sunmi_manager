// ─── Safe parse helpers ───────────────────────────────────────────────────────
// API can return numeric fields as int, double, or even String.
// These helpers prevent type-cast crashes in all three cases.

/// Safely parse any value to num (double). Returns null if unparseable.
num? _toNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

/// Safely parse any value to int. Returns null if unparseable.
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt();
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────

class DailySalesSummaryModel {
  bool? success;
  DailySalesSummaryData? data;

  DailySalesSummaryModel({this.success, this.data});

  DailySalesSummaryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? DailySalesSummaryData.fromJson(json['data'])
        : null;
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

// ─── Root Data ───────────────────────────────────────────────────────────────

class DailySalesSummaryData {
  String? type;
  SummaryPeriod? period;
  SummaryOrders? orders;
  SummarySales? sales;
  SummaryPayments? payments;
  SummaryRefunds? refunds;

  DailySalesSummaryData({
    this.type,
    this.period,
    this.orders,
    this.sales,
    this.payments,
    this.refunds,
  });

  DailySalesSummaryData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    period = json['period'] != null
        ? SummaryPeriod.fromJson(json['period'])
        : null;
    orders = json['orders'] != null
        ? SummaryOrders.fromJson(json['orders'])
        : null;
    sales =
        json['sales'] != null ? SummarySales.fromJson(json['sales']) : null;
    payments = json['payments'] != null
        ? SummaryPayments.fromJson(json['payments'])
        : null;
    refunds = json['refunds'] != null
        ? SummaryRefunds.fromJson(json['refunds'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (period != null) data['period'] = period!.toJson();
    if (orders != null) data['orders'] = orders!.toJson();
    if (sales != null) data['sales'] = sales!.toJson();
    if (payments != null) data['payments'] = payments!.toJson();
    if (refunds != null) data['refunds'] = refunds!.toJson();
    return data;
  }
}

// ─── Period ──────────────────────────────────────────────────────────────────

class SummaryPeriod {
  String? businessDate;
  String? date;
  String? generatedAt;
  String? timezone;
  String? startAt;
  String? endAt;

  SummaryPeriod({
    this.businessDate,
    this.date,
    this.generatedAt,
    this.timezone,
    this.startAt,
    this.endAt,
  });

  SummaryPeriod.fromJson(Map<String, dynamic> json) {
    businessDate = json['business_date'];
    date = json['date'];
    generatedAt = json['generated_at'];
    timezone = json['timezone'];
    startAt = json['start_at'];
    endAt = json['end_at'];
  }

  Map<String, dynamic> toJson() => {
        'business_date': businessDate,
        'date': date,
        'generated_at': generatedAt,
        'timezone': timezone,
        'start_at': startAt,
        'end_at': endAt,
      };
}

// ─── Orders ──────────────────────────────────────────────────────────────────

class SummaryOrders {
  int? totalOrders;
  int? paidOrders;
  int? ordersCounted;
  int? cancelledCount;
  Map<String, dynamic>? countByType;
  Map<String, dynamic>? countByStatus;
  SummaryOngoing? ongoing;

  SummaryOrders({
    this.totalOrders,
    this.paidOrders,
    this.ordersCounted,
    this.cancelledCount,
    this.countByType,
    this.countByStatus,
    this.ongoing,
  });

  SummaryOrders.fromJson(Map<String, dynamic> json) {
    totalOrders = _toInt(json['total_orders']);
    paidOrders = _toInt(json['paid_orders']);
    ordersCounted = _toInt(json['orders_counted']);
    cancelledCount = _toInt(json['cancelled_count']);
    countByType = json['count_by_type'] != null
        ? Map<String, dynamic>.from(json['count_by_type'])
        : null;
    countByStatus = json['count_by_status'] != null
        ? Map<String, dynamic>.from(json['count_by_status'])
        : null;
    ongoing = json['ongoing'] != null
        ? SummaryOngoing.fromJson(json['ongoing'])
        : null;
  }

  Map<String, dynamic> toJson() => {
        'total_orders': totalOrders,
        'paid_orders': paidOrders,
        'orders_counted': ordersCounted,
        'cancelled_count': cancelledCount,
        'count_by_type': countByType,
        'count_by_status': countByStatus,
        'ongoing': ongoing?.toJson(),
      };
}

class SummaryOngoing {
  int? count;
  num? amount;

  SummaryOngoing({this.count, this.amount});

  SummaryOngoing.fromJson(Map<String, dynamic> json) {
    count = _toInt(json['count']);
    amount = _toNum(json['amount']);
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'amount': amount,
      };
}

// ─── Sales ───────────────────────────────────────────────────────────────────

class SummarySales {
  num? gross;
  num? subTotal;
  List<TaxByRate>? taxesByRate;
  num? totalTax;
  SummaryDiscounts? discounts;
  SummaryTips? tips;
  num? net;
  List<SalesByType>? byType;

  SummarySales({
    this.gross,
    this.subTotal,
    this.taxesByRate,
    this.totalTax,
    this.discounts,
    this.tips,
    this.net,
    this.byType,
  });

  SummarySales.fromJson(Map<String, dynamic> json) {
    gross = _toNum(json['gross']);
    subTotal = _toNum(json['sub_total']);
    if (json['taxes_by_rate'] != null) {
      taxesByRate = <TaxByRate>[];
      json['taxes_by_rate'].forEach((v) {
        taxesByRate!.add(TaxByRate.fromJson(v));
      });
    }
    totalTax = _toNum(json['total_tax']);
    discounts = json['discounts'] != null
        ? SummaryDiscounts.fromJson(json['discounts'])
        : null;
    tips =
        json['tips'] != null ? SummaryTips.fromJson(json['tips']) : null;
    net = _toNum(json['net']);
    if (json['by_type'] != null) {
      byType = <SalesByType>[];
      json['by_type'].forEach((v) {
        byType!.add(SalesByType.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
        'gross': gross,
        'sub_total': subTotal,
        'taxes_by_rate': taxesByRate?.map((v) => v.toJson()).toList(),
        'total_tax': totalTax,
        'discounts': discounts?.toJson(),
        'tips': tips?.toJson(),
        'net': net,
        'by_type': byType?.map((v) => v.toJson()).toList(),
      };
}

class TaxByRate {
  num? taxPercentage;
  num? netAmount;
  num? taxAmount;
  String? tax;
  String? name;

  TaxByRate({
    this.taxPercentage,
    this.netAmount,
    this.taxAmount,
    this.tax,
    this.name,
  });

  TaxByRate.fromJson(Map<String, dynamic> json) {
    taxPercentage = _toNum(json['tax_percentage']);
    netAmount = _toNum(json['net_amount']);
    taxAmount = _toNum(json['tax_amount']);
    tax = json['tax'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() => {
        'tax_percentage': taxPercentage,
        'net_amount': netAmount,
        'tax_amount': taxAmount,
        'tax': tax,
        'name': name,
      };
}

class SummaryDiscounts {
  num? orderLevel;
  num? paymentLevel;
  num? total;

  SummaryDiscounts({this.orderLevel, this.paymentLevel, this.total});

  SummaryDiscounts.fromJson(Map<String, dynamic> json) {
    orderLevel = _toNum(json['order_level']);
    paymentLevel = _toNum(json['payment_level']);
    total = _toNum(json['total']);
  }

  Map<String, dynamic> toJson() => {
        'order_level': orderLevel,
        'payment_level': paymentLevel,
        'total': total,
      };
}

class SummaryTips {
  num? orderLevel;
  num? paymentLevel;
  num? total;

  SummaryTips({this.orderLevel, this.paymentLevel, this.total});

  SummaryTips.fromJson(Map<String, dynamic> json) {
    orderLevel = _toNum(json['order_level']);
    paymentLevel = _toNum(json['payment_level']);
    total = _toNum(json['total']);
  }

  Map<String, dynamic> toJson() => {
        'order_level': orderLevel,
        'payment_level': paymentLevel,
        'total': total,
      };
}

class SalesByType {
  String? type;
  int? count;
  num? amount;

  SalesByType({this.type, this.count, this.amount});

  SalesByType.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    count = _toInt(json['count']);
    amount = _toNum(json['amount']);
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'count': count,
        'amount': amount,
      };
}

// ─── Payments ────────────────────────────────────────────────────────────────

class SummaryPayments {
  List<PaymentByMethod>? byMethod;
  num? total;
  num? dueOutstanding;
  num? duePlaceholder;
  num? netOfDue;
  SummaryAwaitingVerification? awaitingVerification;

  SummaryPayments({
    this.byMethod,
    this.total,
    this.dueOutstanding,
    this.duePlaceholder,
    this.netOfDue,
    this.awaitingVerification,
  });

  SummaryPayments.fromJson(Map<String, dynamic> json) {
    if (json['by_method'] != null) {
      byMethod = <PaymentByMethod>[];
      json['by_method'].forEach((v) {
        byMethod!.add(PaymentByMethod.fromJson(v));
      });
    }
    total = _toNum(json['total']);
    dueOutstanding = _toNum(json['due_outstanding']);
    duePlaceholder = _toNum(json['due_placeholder']);
    netOfDue = _toNum(json['net_of_due']);
    awaitingVerification = json['awaiting_verification'] != null
        ? SummaryAwaitingVerification.fromJson(json['awaiting_verification'])
        : null;
  }

  Map<String, dynamic> toJson() => {
        'by_method': byMethod?.map((v) => v.toJson()).toList(),
        'total': total,
        'due_outstanding': dueOutstanding,
        'due_placeholder': duePlaceholder,
        'net_of_due': netOfDue,
        'awaiting_verification': awaitingVerification?.toJson(),
      };
}

class PaymentByMethod {
  String? method;
  int? count;
  num? amount;
  num? tips;
  num? vouchers;

  PaymentByMethod({
    this.method,
    this.count,
    this.amount,
    this.tips,
    this.vouchers,
  });

  PaymentByMethod.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    count = _toInt(json['count']);
    amount = _toNum(json['amount']);
    tips = _toNum(json['tips']);
    vouchers = _toNum(json['vouchers']);
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'count': count,
        'amount': amount,
        'tips': tips,
        'vouchers': vouchers,
      };
}

class SummaryAwaitingVerification {
  int? count;
  num? amount;

  SummaryAwaitingVerification({this.count, this.amount});

  SummaryAwaitingVerification.fromJson(Map<String, dynamic> json) {
    count = _toInt(json['count']);
    amount = _toNum(json['amount']);
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'amount': amount,
      };
}

// ─── Refunds ─────────────────────────────────────────────────────────────────

class SummaryRefunds {
  int? count;
  num? total;
  num? amount;
  List<RefundByMethod>? byMethod;

  SummaryRefunds({this.count, this.total, this.amount, this.byMethod});

  SummaryRefunds.fromJson(Map<String, dynamic> json) {
    count = _toInt(json['count']);
    total = _toNum(json['total']);
    amount = _toNum(json['amount']);
    if (json['by_method'] != null) {
      byMethod = <RefundByMethod>[];
      json['by_method'].forEach((v) {
        byMethod!.add(RefundByMethod.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'total': total,
        'amount': amount,
        'by_method': byMethod?.map((v) => v.toJson()).toList(),
      };
}

class RefundByMethod {
  String? method;
  int? count;
  num? amount;

  RefundByMethod({this.method, this.count, this.amount});

  RefundByMethod.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    count = _toInt(json['count']);
    amount = _toNum(json['amount']);
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'count': count,
        'amount': amount,
      };
}
