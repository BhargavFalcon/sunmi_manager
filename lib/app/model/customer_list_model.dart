class CustomerListModel {
  bool? success;
  CustomerListData? data;

  CustomerListModel({this.success, this.data});

  CustomerListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data =
        json['data'] != null
            ? CustomerListData.fromJson(json['data'] as Map<String, dynamic>)
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

class CustomerListData {
  List<CustomerListItem>? data;
  CustomerListMeta? meta;

  CustomerListData({this.data, this.meta});

  CustomerListData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CustomerListItem>[];
      for (final v in json['data'] as List) {
        if (v is Map<String, dynamic>) {
          data!.add(CustomerListItem.fromJson(v));
        }
      }
    }
    meta =
        json['meta'] != null
            ? CustomerListMeta.fromJson(json['meta'] as Map<String, dynamic>)
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class CustomerListItem {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? phoneCode;
  List<CustomerAddress>? addresses;
  int? orderCount;

  CustomerListItem({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.phoneCode,
    this.addresses,
    this.orderCount,
  });

  CustomerListItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    phoneCode = json['phone_code'];
    if (json['addresses'] != null) {
      addresses = <CustomerAddress>[];
      for (final v in json['addresses'] as List) {
        if (v is Map<String, dynamic>) {
          addresses!.add(CustomerAddress.fromJson(v));
        }
      }
    }
    orderCount = json['order_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['phone_code'] = phoneCode;
    if (addresses != null) {
      data['addresses'] = addresses!.map((v) => v.toJson()).toList();
    }
    data['order_count'] = orderCount;
    return data;
  }
}

class CustomerAddress {
  int? id;
  String? address;
  String? houseNumber;
  String? zipCode;
  String? city;
  String? state;
  String? country;
  bool? isDefault;

  CustomerAddress({
    this.id,
    this.address,
    this.houseNumber,
    this.zipCode,
    this.city,
    this.state,
    this.country,
    this.isDefault,
  });

  CustomerAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    houseNumber = json['house_number']?.toString();
    zipCode = json['zip_code']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
    country = json['country']?.toString();
    isDefault = json['is_default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address'] = address;
    data['house_number'] = houseNumber;
    data['zip_code'] = zipCode;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['is_default'] = isDefault;
    return data;
  }
}

class CustomerListMeta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  CustomerListMeta({this.currentPage, this.lastPage, this.perPage, this.total});

  CustomerListMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
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
