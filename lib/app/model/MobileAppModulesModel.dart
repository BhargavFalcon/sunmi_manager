class MobileAppModulesModel {
  bool? success;
  MobileAppModulesData? data;

  MobileAppModulesModel({this.success, this.data});

  MobileAppModulesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data =
        json['data'] != null
            ? new MobileAppModulesData.fromJson(json['data'])
            : null;
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

class MobileAppModulesData {
  List<String>? modules;
  int? restaurantId;

  MobileAppModulesData({this.modules, this.restaurantId});

  MobileAppModulesData.fromJson(Map<String, dynamic> json) {
    if (json['modules'] != null) {
      modules = <String>[];
      json['modules'].forEach((v) {
        modules!.add(v.toString());
      });
    }
    restaurantId = json['restaurant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.modules != null) {
      data['modules'] = this.modules;
    }
    data['restaurant_id'] = this.restaurantId;
    return data;
  }
}
