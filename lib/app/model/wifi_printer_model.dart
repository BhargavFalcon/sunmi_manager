class WifiPrinterModel {
  String name;
  String ipAddress;
  String port;
  bool isDefault;

  WifiPrinterModel({
    required this.name,
    required this.ipAddress,
    required this.port,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'isDefault': isDefault,
    };
  }

  factory WifiPrinterModel.fromJson(Map<String, dynamic> json) {
    return WifiPrinterModel(
      name: json['name'],
      ipAddress: json['ipAddress'],
      port: json['port'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}
