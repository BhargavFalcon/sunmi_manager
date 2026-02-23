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
  List<String>? managerAppPermissions;

  MobileAppModulesData({this.managerAppPermissions});

  MobileAppModulesData.fromJson(Map<String, dynamic> json) {
    if (json['manager_app_permissions'] != null) {
      managerAppPermissions = <String>[];
      json['manager_app_permissions'].forEach((v) {
        managerAppPermissions!.add(v.toString());
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.managerAppPermissions != null) {
      data['manager_app_permissions'] = this.managerAppPermissions;
    }
    return data;
  }
}
