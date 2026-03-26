class WifiPrinterModel {
  String name;
  String ipAddress;
  String port;
  String paperWidth;
  bool isDefault;

  WifiPrinterModel({
    required this.name,
    required this.ipAddress,
    required this.port,
    this.paperWidth = '80mm',
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'paperWidth': paperWidth,
      'isDefault': isDefault,
    };
  }

  factory WifiPrinterModel.fromJson(Map<String, dynamic> json) {
    return WifiPrinterModel(
      name: json['name'],
      ipAddress: json['ipAddress'],
      port: json['port'],
      paperWidth: json['paperWidth'] ?? '80mm',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
