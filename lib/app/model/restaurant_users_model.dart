import 'package:managerapp/app/model/login_models.dart';

class RestaurantUsersModel {
  bool? success;
  List<RestaurantUser>? data;

  RestaurantUsersModel({this.success, this.data});

  RestaurantUsersModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <RestaurantUser>[];
      json['data'].forEach((v) {
        data!.add(RestaurantUser.fromJson(v));
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

class RestaurantUser {
  int? id;
  String? name;
  String? email;
  String? username;
  String? phoneNumber;
  String? phoneCode;
  int? branchId;
  int? restaurantId;
  Role? role;

  RestaurantUser({
    this.id,
    this.name,
    this.email,
    this.username,
    this.phoneNumber,
    this.phoneCode,
    this.branchId,
    this.restaurantId,
    this.role,
  });

  RestaurantUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    username = json['username'];
    phoneNumber = json['phone_number'];
    phoneCode = json['phone_code'];
    branchId = json['branch_id'];
    restaurantId = json['restaurant_id'];
    role = json['role'] != null ? Role.fromJson(json['role']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['username'] = username;
    data['phone_number'] = phoneNumber;
    data['phone_code'] = phoneCode;
    data['branch_id'] = branchId;
    data['restaurant_id'] = restaurantId;
    if (role != null) {
      data['role'] = role!.toJson();
    }
    return data;
  }
}
