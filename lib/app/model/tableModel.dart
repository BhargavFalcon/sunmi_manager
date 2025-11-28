class TableModel {
  bool? success;
  List<Data>? data;

  TableModel({this.success, this.data});

  TableModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
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
    id = json['id'];
    name = json['name'];
    tablesCount = json['tables_count'];
    if (json['tables'] != null) {
      tables = <Tables>[];
      json['tables'].forEach((v) {
        tables!.add(new Tables.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['tables_count'] = this.tablesCount;
    if (this.tables != null) {
      data['tables'] = this.tables!.map((v) => v.toJson()).toList();
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
    id = json['id'];
    tableCode = json['table_code']?.toString();
    branchId = json['branch_id'];
    areaId = json['area_id'];
    hash = json['hash']?.toString();
    width = json['width'];
    height = json['height'];
    left = json['left'];
    top = json['top'];
    shape = json['shape']?.toString();
    seatingCapacity = json['seating_capacity'];
    status = json['status']?.toString();
    availableStatus = json['available_status']?.toString();
    area = json['area'] != null ? new Area.fromJson(json['area']) : null;
    qrCodeUrl = json['qr_code_url']?.toString();
    activeOrder =
        json['active_order'] != null
            ? new ActiveOrder.fromJson(json['active_order'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['table_code'] = this.tableCode;
    data['branch_id'] = this.branchId;
    data['area_id'] = this.areaId;
    data['hash'] = this.hash;
    data['width'] = this.width;
    data['height'] = this.height;
    data['left'] = this.left;
    data['top'] = this.top;
    data['shape'] = this.shape;
    data['seating_capacity'] = this.seatingCapacity;
    data['status'] = this.status;
    data['available_status'] = this.availableStatus;
    if (this.area != null) {
      data['area'] = this.area!.toJson();
    }
    data['qr_code_url'] = this.qrCodeUrl;
    if (this.activeOrder != null) {
      data['active_order'] = this.activeOrder!.toJson();
    }
    return data;
  }
}

class Area {
  int? id;
  String? name;

  Area({this.id, this.name});

  Area.fromJson(Map<String, dynamic> json) {
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

class ActiveOrder {
  int? id;
  String? uuid;
  int? orderNumber;
  String? status;
  double? total;

  ActiveOrder({this.id, this.uuid, this.orderNumber, this.status, this.total});

  ActiveOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    orderNumber = json['order_number'];
    status = json['status'];
    total = json['total'] != null ? (json['total'] is double ? json['total'] : (json['total'] as num).toDouble()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['order_number'] = this.orderNumber;
    data['status'] = this.status;
    data['total'] = this.total;
    return data;
  }
}
