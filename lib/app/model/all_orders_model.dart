import 'package:managerapp/app/model/get_order_model.dart' show DeliveryExecutiveInfo;

class AllOrdersModel {
  bool? success;
  Data? data;

  AllOrdersModel({this.success, this.data});

  AllOrdersModel.fromJson(Map<String, dynamic> json) {
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
  List<Orders>? orders;
  Pagination? pagination;

  Data({this.orders, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Orders {
  int? id;
  String? uuid;
  String? orderNumber;
  String? formattedOrderNumber;
  String? orderType;
  String? status;
  String? orderStatus;
  String? dateTime;
  String? formattedDateTime;
  Customer? customer;
  Table? table;
  Customer? waiter;
  int? itemsCount;
  String? total;
  String? formattedTotal;
  String? formattedEffectiveTotal;
  double? effectiveTotal;
  int? currencyId;
  Coupon? coupon;
  String? placedVia;
  String? providerName;
  DeliveryExecutiveInfo? deliveryExecutive;
  int? deliveryExecutiveId;

  Orders({
    this.id,
    this.uuid,
    this.orderNumber,
    this.formattedOrderNumber,
    this.orderType,
    this.status,
    this.orderStatus,
    this.dateTime,
    this.formattedDateTime,
    this.customer,
    this.table,
    this.waiter,
    this.itemsCount,
    this.total,
    this.formattedTotal,
    this.formattedEffectiveTotal,
    this.effectiveTotal,
    this.currencyId,
    this.coupon,
    this.placedVia,
    this.providerName,
    this.deliveryExecutive,
    this.deliveryExecutiveId,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    orderNumber = json['order_number']?.toString();
    formattedOrderNumber =
        json['formatted_order_number']?.toString() ??
        json['order_number']?.toString();
    orderType = json['order_type'];
    status = json['status'];
    orderStatus = json['order_status'];
    dateTime = json['date_time'];
    formattedDateTime = json['formatted_date_time'];
    customer =
        json['customer'] != null
            ? Customer.fromJson(
              json['customer'] is Map
                  ? json['customer'] as Map<String, dynamic>
                  : (json['customer'] is List && json['customer'].isNotEmpty
                      ? json['customer'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    table =
        json['table'] != null
            ? Table.fromJson(
              json['table'] is Map
                  ? json['table'] as Map<String, dynamic>
                  : (json['table'] is List && json['table'].isNotEmpty
                      ? json['table'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    waiter =
        json['waiter'] != null
            ? Customer.fromJson(
              json['waiter'] is Map
                  ? json['waiter'] as Map<String, dynamic>
                  : (json['waiter'] is List && json['waiter'].isNotEmpty
                      ? json['waiter'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    itemsCount =
        json['items_count'] is int
            ? json['items_count']
            : int.tryParse(json['items_count']?.toString() ?? '');
    total = json['total']?.toString();
    formattedTotal = json['formatted_total']?.toString();
    formattedEffectiveTotal = json['formatted_effective_total']?.toString();
    effectiveTotal =
        json['effective_total'] != null
            ? double.tryParse(json['effective_total'].toString())
            : null;
    currencyId =
        json['currency_id'] is int
            ? json['currency_id']
            : int.tryParse(json['currency_id']?.toString() ?? '');
    coupon =
        json['coupon'] != null
            ? Coupon.fromJson(
              json['coupon'] is Map
                  ? json['coupon'] as Map<String, dynamic>
                  : (json['coupon'] is List && json['coupon'].isNotEmpty
                      ? json['coupon'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    placedVia = json['placed_via']?.toString();
    providerName = json['provider_name']?.toString();
    deliveryExecutive =
        json['delivery_executive'] is Map
            ? DeliveryExecutiveInfo.fromJson(
              json['delivery_executive'] as Map<String, dynamic>,
            )
            : null;
    deliveryExecutiveId =
        json['delivery_executive_id'] != null
            ? int.tryParse(json['delivery_executive_id'].toString())
            : (json['delivery_executive'] is Map &&
                    json['delivery_executive']['id'] != null
                ? int.tryParse(json['delivery_executive']['id'].toString())
                : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['order_number'] = orderNumber;
    data['formatted_order_number'] = formattedOrderNumber;
    data['order_type'] = orderType;
    data['status'] = status;
    data['order_status'] = orderStatus;
    data['date_time'] = dateTime;
    data['formatted_date_time'] = formattedDateTime;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (table != null) {
      data['table'] = table!.toJson();
    }
    if (waiter != null) {
      data['waiter'] = waiter!.toJson();
    }
    data['items_count'] = itemsCount;
    data['total'] = total;
    data['formatted_total'] = formattedTotal;
    data['formatted_effective_total'] = formattedEffectiveTotal;
    data['effective_total'] = effectiveTotal;
    data['currency_id'] = currencyId;
    if (coupon != null) {
      data['coupon'] = coupon!.toJson();
    }
    data['placed_via'] = placedVia;
    data['provider_name'] = providerName;
    data['delivery_executive'] = deliveryExecutive?.toJson();
    data['delivery_executive_id'] = deliveryExecutiveId;
    return data;
  }
}

class Customer {
  int? id;
  String? name;
  String? email;
  String? phone;

  Customer({this.id, this.name, this.email, this.phone});

  Customer.fromJson(Map<String, dynamic> json) {
    id =
        json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    email = json['email']?.toString();
    phone = json['phone']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}

class Table {
  int? id;
  String? tableCode;
  String? tableName;

  Table({this.id, this.tableCode, this.tableName});

  Table.fromJson(Map<String, dynamic> json) {
    id =
        json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '');
    tableCode = json['table_code']?.toString() ?? json['name']?.toString();
    tableName = json['table_name']?.toString() ?? json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['table_code'] = tableCode;
    data['table_name'] = tableName;
    return data;
  }
}

class Coupon {
  int? id;
  String? code;

  Coupon({this.id, this.code});

  Coupon.fromJson(Map<String, dynamic> json) {
    id =
        json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '');
    code = json['code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
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
    currentPage =
        json['current_page'] is int
            ? json['current_page']
            : int.tryParse(json['current_page']?.toString() ?? '');
    lastPage =
        json['last_page'] is int
            ? json['last_page']
            : int.tryParse(json['last_page']?.toString() ?? '');
    perPage =
        json['per_page'] is int
            ? json['per_page']
            : int.tryParse(json['per_page']?.toString() ?? '');
    total =
        json['total'] is int
            ? json['total']
            : int.tryParse(json['total']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['total'] = total;
    return data;
  }
}
