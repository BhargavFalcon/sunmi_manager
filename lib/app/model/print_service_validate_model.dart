class PrintServiceValidateModel {
  bool? success;
  PrintServiceValidateData? data;
  String? message;

  PrintServiceValidateModel({this.success, this.data, this.message});

  PrintServiceValidateModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    data = json['data'] != null
        ? PrintServiceValidateData.fromJson(
            json['data'] as Map<String, dynamic>)
        : null;
    message = json['message'] as String?;
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

class PrintServiceValidateData {
  Branch? branch;
  Device? device;
  String? token;
  List<PrinterSetting>? printerSettings;

  PrintServiceValidateData({
    this.branch,
    this.device,
    this.token,
    this.printerSettings,
  });

  PrintServiceValidateData.fromJson(Map<String, dynamic> json) {
    branch = json['branch'] != null
        ? Branch.fromJson(json['branch'] as Map<String, dynamic>)
        : null;
    device = json['device'] != null
        ? Device.fromJson(json['device'] as Map<String, dynamic>)
        : null;
    token = json['token'] as String?;
    if (json['printer_settings'] != null) {
      printerSettings = <PrinterSetting>[];
      for (final v in json['printer_settings'] as List) {
        printerSettings!.add(
            PrinterSetting.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (branch != null) {
      data['branch'] = branch!.toJson();
    }
    if (device != null) {
      data['device'] = device!.toJson();
    }
    data['token'] = token;
    if (printerSettings != null) {
      data['printer_settings'] =
          printerSettings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Branch {
  int? id;
  String? name;

  Branch({this.id, this.name});

  Branch.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Device {
  int? id;
  String? deviceId;
  String? deviceName;
  String? lastVerifiedAt;

  Device({
    this.id,
    this.deviceId,
    this.deviceName,
    this.lastVerifiedAt,
  });

  Device.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    deviceId = json['device_id'] as String?;
    deviceName = json['device_name'] as String?;
    lastVerifiedAt = json['last_verified_at'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['device_id'] = deviceId;
    data['device_name'] = deviceName;
    data['last_verified_at'] = lastVerifiedAt;
    return data;
  }
}

class PrinterSetting {
  int? id;
  String? name;
  String? printingChoice;
  String? printFormat;
  String? type;
  String? shareName;
  bool? isActive;
  bool? isDefault;

  PrinterSetting({
    this.id,
    this.name,
    this.printingChoice,
    this.printFormat,
    this.type,
    this.shareName,
    this.isActive,
    this.isDefault,
  });

  PrinterSetting.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name'] as String?;
    printingChoice = json['printing_choice'] as String?;
    printFormat = json['print_format'] as String?;
    type = json['type'] as String?;
    shareName = json['share_name'] as String?;
    isActive = json['is_active'] as bool?;
    isDefault = json['is_default'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['printing_choice'] = printingChoice;
    data['print_format'] = printFormat;
    data['type'] = type;
    data['share_name'] = shareName;
    data['is_active'] = isActive;
    data['is_default'] = isDefault;
    return data;
  }
}
