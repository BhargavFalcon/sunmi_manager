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
  int? id;
  String? uuid;
  String? orderNumber;
  String? formattedOrderNumber;
  String? orderType;
  String? status;
  String? dateTime;
  String? formattedDateTime;
  Customer? customer;
  Table? table;
  Customer? waiter;
  int? itemsCount;
  String? total;
  String? formattedTotal;
  int? currencyId;
  Coupon? coupon;
  String? placedVia;

  Orders({
    this.id,
    this.uuid,
    this.orderNumber,
    this.formattedOrderNumber,
    this.orderType,
    this.status,
    this.dateTime,
    this.formattedDateTime,
    this.customer,
    this.table,
    this.waiter,
    this.itemsCount,
    this.total,
    this.formattedTotal,
    this.currencyId,
    this.coupon,
    this.placedVia,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    orderNumber = json['order_number'];
    formattedOrderNumber = json['formatted_order_number'].toString();
    orderType = json['order_type'];
    status = json['status'];
    dateTime = json['date_time'];
    formattedDateTime = json['formatted_date_time'];
    customer =
        json['customer'] != null
            ? new Customer.fromJson(
              json['customer'] is Map
                  ? json['customer'] as Map<String, dynamic>
                  : (json['customer'] is List && json['customer'].isNotEmpty
                      ? json['customer'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    table =
        json['table'] != null
            ? new Table.fromJson(
              json['table'] is Map
                  ? json['table'] as Map<String, dynamic>
                  : (json['table'] is List && json['table'].isNotEmpty
                      ? json['table'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    waiter =
        json['waiter'] != null
            ? new Customer.fromJson(
              json['waiter'] is Map
                  ? json['waiter'] as Map<String, dynamic>
                  : (json['waiter'] is List && json['waiter'].isNotEmpty
                      ? json['waiter'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    itemsCount = json['items_count'];
    total = json['total']?.toString();
    formattedTotal = json['formatted_total']?.toString();
    currencyId = json['currency_id'];
    coupon =
        json['coupon'] != null
            ? new Coupon.fromJson(
              json['coupon'] is Map
                  ? json['coupon'] as Map<String, dynamic>
                  : (json['coupon'] is List && json['coupon'].isNotEmpty
                      ? json['coupon'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    placedVia = json['placed_via'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['order_number'] = this.orderNumber;
    data['formatted_order_number'] = this.formattedOrderNumber;
    data['order_type'] = this.orderType;
    data['status'] = this.status;
    data['date_time'] = this.dateTime;
    data['formatted_date_time'] = this.formattedDateTime;
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    if (this.table != null) {
      data['table'] = this.table!.toJson();
    }
    if (this.waiter != null) {
      data['waiter'] = this.waiter!.toJson();
    }
    data['items_count'] = this.itemsCount;
    data['total'] = this.total;
    data['formatted_total'] = this.formattedTotal;
    data['currency_id'] = this.currencyId;
    if (this.coupon != null) {
      data['coupon'] = this.coupon!.toJson();
    }
    data['placed_via'] = this.placedVia;
    return data;
  }
}

class Customer {
  int? id;
  String? name;

  Customer({this.id, this.name});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
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

class Coupon {
  int? id;
  String? code;

  Coupon({this.id, this.code});

  Coupon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
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
