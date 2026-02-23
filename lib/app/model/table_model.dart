class TableModel {
  bool? success;
  List<Data>? data;

  TableModel({this.success, this.data});

  TableModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  int? tablesCount;
  List<Tables>? tables;

  Data({this.id, this.name, this.tablesCount, this.tables});

  Data.fromJson(Map<String, dynamic> json) {
    id =
        json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null);
    name = json['name'];
    tablesCount =
        json['tables_count'] is int
            ? json['tables_count']
            : (json['tables_count'] is String
                ? int.tryParse(json['tables_count'])
                : null);
    if (json['tables'] != null) {
      tables = <Tables>[];
      json['tables'].forEach((v) {
        tables!.add(Tables.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tables_count'] = tablesCount;
    if (tables != null) {
      data['tables'] = tables!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tables {
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
  Area? area;
  String? qrCodeUrl;
  ActiveOrder? activeOrder;

  Tables({
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

  Tables.fromJson(Map<String, dynamic> json) {
    id =
        json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null);
    tableCode = json['table_code']?.toString();
    branchId =
        json['branch_id'] is int
            ? json['branch_id']
            : (json['branch_id'] is String
                ? int.tryParse(json['branch_id'])
                : null);
    areaId =
        json['area_id'] is int
            ? json['area_id']
            : (json['area_id'] is String
                ? int.tryParse(json['area_id'])
                : null);
    hash = json['hash']?.toString();
    width =
        json['width'] is int
            ? json['width']
            : (json['width'] is String ? int.tryParse(json['width']) : null);
    height =
        json['height'] is int
            ? json['height']
            : (json['height'] is String ? int.tryParse(json['height']) : null);
    left =
        json['left'] is int
            ? json['left']
            : (json['left'] is String ? int.tryParse(json['left']) : null);
    top =
        json['top'] is int
            ? json['top']
            : (json['top'] is String ? int.tryParse(json['top']) : null);
    shape = json['shape']?.toString();
    seatingCapacity =
        json['seating_capacity'] is int
            ? json['seating_capacity']
            : (json['seating_capacity'] is String
                ? int.tryParse(json['seating_capacity'])
                : null);
    status = json['status']?.toString();
    availableStatus = json['available_status']?.toString();
    area =
        json['area'] != null
            ? Area.fromJson(
              json['area'] is Map
                  ? json['area'] as Map<String, dynamic>
                  : (json['area'] is List && json['area'].isNotEmpty
                      ? json['area'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
    qrCodeUrl = json['qr_code_url']?.toString();
    activeOrder =
        json['active_order'] != null
            ? ActiveOrder.fromJson(
              json['active_order'] is Map
                  ? json['active_order'] as Map<String, dynamic>
                  : (json['active_order'] is List &&
                          json['active_order'].isNotEmpty
                      ? json['active_order'][0] as Map<String, dynamic>
                      : {}),
            )
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['table_code'] = tableCode;
    data['branch_id'] = branchId;
    data['area_id'] = areaId;
    data['hash'] = hash;
    data['width'] = width;
    data['height'] = height;
    data['left'] = left;
    data['top'] = top;
    data['shape'] = shape;
    data['seating_capacity'] = seatingCapacity;
    data['status'] = status;
    data['available_status'] = availableStatus;
    if (area != null) {
      data['area'] = area!.toJson();
    }
    data['qr_code_url'] = qrCodeUrl;
    if (activeOrder != null) {
      data['active_order'] = activeOrder!.toJson();
    }
    return data;
  }
}

class Area {
  int? id;
  String? name;

  Area({this.id, this.name});

  Area.fromJson(Map<String, dynamic> json) {
    id =
        json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null);
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ActiveOrder {
  int? id;
  String? uuid;
  int? orderNumber;
  String? status;
  double? total;

  ActiveOrder({this.id, this.uuid, this.orderNumber, this.status, this.total});

  ActiveOrder.fromJson(Map<String, dynamic> json) {
    id =
        json['id'] is int
            ? json['id']
            : (json['id'] is String ? int.tryParse(json['id']) : null);
    uuid = json['uuid'];
    orderNumber =
        json['order_number'] is int
            ? json['order_number']
            : (json['order_number'] is String
                ? int.tryParse(json['order_number'])
                : null);
    status = json['status'];
    total =
        json['total'] != null
            ? (json['total'] is double
                ? json['total']
                : (json['total'] is num
                    ? (json['total'] as num).toDouble()
                    : double.tryParse(json['total'].toString())))
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['order_number'] = orderNumber;
    data['status'] = status;
    data['total'] = total;
    return data;
  }
}
