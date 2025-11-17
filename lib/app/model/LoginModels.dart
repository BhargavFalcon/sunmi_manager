class LoginModel {
  bool? success;
  Data? data;
  String? message;

  LoginModel({this.success, this.data, this.message});

  LoginModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
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
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    token = json['token'];
    defaultBranchId = json['default_branch_id'];
    if (json['available_branches'] != null) {
      availableBranches = <AvailableBranches>[];
      json['available_branches'].forEach((v) {
        availableBranches!.add(new AvailableBranches.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    data['default_branch_id'] = this.defaultBranchId;
    if (this.availableBranches != null) {
      data['available_branches'] =
          this.availableBranches!.map((v) => v.toJson()).toList();
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

  User(
      {this.id,
        this.name,
        this.email,
        this.restaurantId,
        this.branchId,
        this.restaurant,
        this.branch});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    restaurantId = json['restaurant_id'];
    branchId = json['branch_id'];
    restaurant = json['restaurant'] != null
        ? new Restaurant.fromJson(json['restaurant'])
        : null;
    branch =
    json['branch'] != null ? new Restaurant.fromJson(json['branch']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['restaurant_id'] = this.restaurantId;
    data['branch_id'] = this.branchId;
    if (this.restaurant != null) {
      data['restaurant'] = this.restaurant!.toJson();
    }
    if (this.branch != null) {
      data['branch'] = this.branch!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class AvailableBranches {
  int? id;
  String? name;
  String? address;
  double? lat;
  double? lng;
  int? restaurantId;
  int? parentRestaurantId;
  String? createdAt;
  String? updatedAt;

  AvailableBranches(
      {this.id,
        this.name,
        this.address,
        this.lat,
        this.lng,
        this.restaurantId,
        this.parentRestaurantId,
        this.createdAt,
        this.updatedAt});

  AvailableBranches.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    lat = json['lat'];
    lng = json['lng'];
    restaurantId = json['restaurant_id'];
    parentRestaurantId = json['parent_restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['restaurant_id'] = this.restaurantId;
    data['parent_restaurant_id'] = this.parentRestaurantId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
