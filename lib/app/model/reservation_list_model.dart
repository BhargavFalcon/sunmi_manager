class ReservationListModel {
  bool? success;
  ReservationListData? data;

  ReservationListModel({this.success, this.data});

  ReservationListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        data = ReservationListData.fromJson(json['data'] as Map<String, dynamic>);
      } else if (json['data'] is List) {
        data = ReservationListData(
          reservations:
              (json['data'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((v) => ReservationListItem.fromJson(v))
                  .toList(),
        );
      }
    }
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
    if (json['reservations'] != null && json['reservations'] is List) {
      reservations =
          (json['reservations'] as List)
              .whereType<Map<String, dynamic>>()
              .map((v) => ReservationListItem.fromJson(v))
              .toList();
    } else if (json['data'] != null && json['data'] is List) {
      // Some APIs wrap data in another 'data' key
      reservations =
          (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((v) => ReservationListItem.fromJson(v))
              .toList();
    }
    pagination =
        json['pagination'] != null && json['pagination'] is Map<String, dynamic>
            ? ReservationPagination.fromJson(
              json['pagination'] as Map<String, dynamic>,
            )
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
    id = int.tryParse(json['id']?.toString() ?? '');
    reservationDateTime = json['reservation_date_time']?.toString();
    reservationDate = json['reservation_date']?.toString();
    reservationTime = json['reservation_time']?.toString();
    reservationSlotType = json['reservation_slot_type']?.toString();
    reservationStatus = json['reservation_status']?.toString();
    statusLabel = json['status_label']?.toString();
    partySize = int.tryParse(json['party_size']?.toString() ?? '');
    specialRequests = json['special_requests']?.toString();
    customer =
        json['customer'] != null && json['customer'] is Map<String, dynamic>
            ? ReservationCustomer.fromJson(
              json['customer'] as Map<String, dynamic>,
            )
            : null;
    if (json['table'] != null) {
      if (json['table'] is List) {
        table =
            (json['table'] as List)
                .whereType<Map<String, dynamic>>()
                .map((v) => ReservationTable.fromJson(v))
                .toList();
      } else if (json['table'] is Map<String, dynamic>) {
        table = [ReservationTable.fromJson(json['table'] as Map<String, dynamic>)];
      }
    }
    branch =
        json['branch'] != null && json['branch'] is Map<String, dynamic>
            ? ReservationBranch.fromJson(json['branch'] as Map<String, dynamic>)
            : null;
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
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
    id = int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    email = json['email']?.toString();
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
    currentPage = int.tryParse(json['current_page']?.toString() ?? '');
    perPage = int.tryParse(json['per_page']?.toString() ?? '');
    lastPage = int.tryParse(json['last_page']?.toString() ?? '');
    total = int.tryParse(json['total']?.toString() ?? '');
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
