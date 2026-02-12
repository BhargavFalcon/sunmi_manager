int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class AddressListModel {
  bool? success;
  List<AddressItem>? data;

  AddressListModel({this.success, this.data});

  AddressListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <AddressItem>[];
      for (final v in json['data']) {
        data!.add(AddressItem.fromJson(v as Map<String, dynamic>));
      }
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

class AddressItem {
  int? id;
  String? zipcode;
  String? city;
  String? state;
  String? street;
  int? countryId;
  Country? country;
  String? createdAt;
  String? updatedAt;

  AddressItem({
    this.id,
    this.zipcode,
    this.city,
    this.state,
    this.street,
    this.countryId,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  AddressItem.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    zipcode = json['zipcode']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
    street = json['street']?.toString();
    countryId = _toInt(json['country_id']);
    country = json['country'] != null
        ? Country.fromJson(json['country'] as Map<String, dynamic>)
        : null;
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['zipcode'] = zipcode;
    data['city'] = city;
    data['state'] = state;
    data['street'] = street;
    data['country_id'] = countryId;
    if (country != null) {
      data['country'] = country!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Country {
  int? id;
  String? name;
  String? code;

  Country({this.id, this.name, this.code});

  Country.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    name = json['name']?.toString();
    code = json['code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    return data;
  }
}
