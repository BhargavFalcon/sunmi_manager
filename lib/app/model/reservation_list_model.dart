class ReservationListModel {
  bool? success;
  ReservationListData? data;

  ReservationListModel({this.success, this.data});

  ReservationListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? ReservationListData.fromJson(json['data'] as Map<String, dynamic>)
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

class ReservationListData {
  List<ReservationListItem>? reservations;
  ReservationPagination? pagination;

  ReservationListData({this.reservations, this.pagination});

  ReservationListData.fromJson(Map<String, dynamic> json) {
    if (json['reservations'] != null) {
      reservations = <ReservationListItem>[];
      for (final v in json['reservations'] as List) {
        if (v is Map<String, dynamic>) {
          reservations!.add(ReservationListItem.fromJson(v));
        }
      }
    }
    pagination = json['pagination'] != null
        ? ReservationPagination.fromJson(
            json['pagination'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (reservations != null) {
      data['reservations'] = reservations!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class ReservationListItem {
  int? id;
  String? reservationDateTime;
  String? reservationDate;
  String? reservationTime;
  String? reservationSlotType;
  String? reservationStatus;
  String? statusLabel;
  int? partySize;
  String? specialRequests;
  ReservationCustomer? customer;
  List<ReservationTable>? table;
  ReservationBranch? branch;
  String? createdAt;
  String? updatedAt;

  ReservationListItem({
    this.id,
    this.reservationDateTime,
    this.reservationDate,
    this.reservationTime,
    this.reservationSlotType,
    this.reservationStatus,
    this.statusLabel,
    this.partySize,
    this.specialRequests,
    this.customer,
    this.table,
    this.branch,
    this.createdAt,
    this.updatedAt,
  });

  ReservationListItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reservationDateTime = json['reservation_date_time'];
    reservationDate = json['reservation_date'];
    reservationTime = json['reservation_time'];
    reservationSlotType = json['reservation_slot_type'];
    reservationStatus = json['reservation_status'];
    statusLabel = json['status_label'];
    partySize = json['party_size'];
    specialRequests = json['special_requests'];
    customer = json['customer'] != null
        ? ReservationCustomer.fromJson(
            json['customer'] as Map<String, dynamic>)
        : null;
    if (json['table'] != null) {
      table = <ReservationTable>[];
      for (final v in json['table'] as List) {
        if (v is Map<String, dynamic>) {
          table!.add(ReservationTable.fromJson(v));
        }
      }
    }
    branch = json['branch'] != null
        ? ReservationBranch.fromJson(json['branch'] as Map<String, dynamic>)
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reservation_date_time'] = reservationDateTime;
    data['reservation_date'] = reservationDate;
    data['reservation_time'] = reservationTime;
    data['reservation_slot_type'] = reservationSlotType;
    data['reservation_status'] = reservationStatus;
    data['status_label'] = statusLabel;
    data['party_size'] = partySize;
    data['special_requests'] = specialRequests;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (table != null) {
      data['table'] = table!.map((v) => v.toJson()).toList();
    }
    if (branch != null) {
      data['branch'] = branch!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ReservationCustomer {
  int? id;
  String? name;
  String? phone;
  String? email;

  ReservationCustomer({this.id, this.name, this.phone, this.email});

  ReservationCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    return data;
  }
}

class ReservationTable {
  // Placeholder for when API returns table objects; extend with id, name, etc. as needed
  Map<String, dynamic>? raw;

  ReservationTable({this.raw});

  ReservationTable.fromJson(Map<String, dynamic> json) : raw = json;

  Map<String, dynamic> toJson() => raw ?? <String, dynamic>{};
}

class ReservationBranch {
  int? id;
  String? name;

  ReservationBranch({this.id, this.name});

  ReservationBranch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ReservationPagination {
  int? currentPage;
  int? perPage;
  int? lastPage;
  int? total;

  ReservationPagination({
    this.currentPage,
    this.perPage,
    this.lastPage,
    this.total,
  });

  ReservationPagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    perPage = json['per_page'];
    lastPage = json['last_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['per_page'] = perPage;
    data['last_page'] = lastPage;
    data['total'] = total;
    return data;
  }
}
