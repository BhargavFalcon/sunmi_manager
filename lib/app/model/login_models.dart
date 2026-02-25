class LoginModel {
  bool? success;
  Data? data;
  String? message;

  LoginModel({this.success, this.data, this.message});

  LoginModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  User? user;
  String? token;
  int? defaultBranchId;
  List<AvailableBranches>? availableBranches;

  Data({this.user, this.token, this.defaultBranchId, this.availableBranches});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    token = json['token'];
    defaultBranchId = json['default_branch_id'];
    if (json['available_branches'] != null) {
      availableBranches = <AvailableBranches>[];
      json['available_branches'].forEach((v) {
        availableBranches!.add(AvailableBranches.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    data['default_branch_id'] = defaultBranchId;
    if (availableBranches != null) {
      data['available_branches'] =
          availableBranches!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  int? restaurantId;
  int? branchId;
  Restaurant? restaurant;
  Restaurant? branch;
  List<String>? managerAppPermissions; // NEW

  User({
    this.id,
    this.name,
    this.email,
    this.restaurantId,
    this.branchId,
    this.restaurant,
    this.branch,
    this.managerAppPermissions,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    restaurantId = json['restaurant_id'];
    branchId = json['branch_id'];
    restaurant =
        json['restaurant'] != null
            ? Restaurant.fromJson(json['restaurant'])
            : null;
    branch =
        json['branch'] != null ? Restaurant.fromJson(json['branch']) : null;
    managerAppPermissions =
        json['manager_app_permissions'] != null
            ? List<String>.from(json['manager_app_permissions'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['restaurant_id'] = restaurantId;
    data['branch_id'] = branchId;
    if (restaurant != null) data['restaurant'] = restaurant!.toJson();
    if (branch != null) data['branch'] = branch!.toJson();
    if (managerAppPermissions != null) {
      data['manager_app_permissions'] = managerAppPermissions;
    }
    return data;
  }
}

class Restaurant {
  int? id;
  String? name;

  Restaurant({this.id, this.name});

  Restaurant.fromJson(Map<String, dynamic> json) {
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

class AvailableBranches {
  int? id;
  String? name;
  String? address;
  int? restaurantId;
  int? parentRestaurantId;
  String? createdAt;
  String? updatedAt;

  AvailableBranches({
    this.id,
    this.name,
    this.address,
    this.restaurantId,
    this.parentRestaurantId,
    this.createdAt,
    this.updatedAt,
  });

  AvailableBranches.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    restaurantId = json['restaurant_id'];
    parentRestaurantId = json['parent_restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'restaurant_id': restaurantId,
    'parent_restaurant_id': parentRestaurantId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
