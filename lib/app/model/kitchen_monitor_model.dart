import '../constants/api_constants.dart';

class KitchenMonitorResponse {
  bool? success;
  List<KitchenMonitor>? data;

  KitchenMonitorResponse({this.success, this.data});

  KitchenMonitorResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <KitchenMonitor>[];
      json['data'].forEach((v) {
        data!.add(KitchenMonitor.fromJson(v));
      });
    }
  }
}

List<String> kitchenMonitorChannelNames(
  int branchId,
  Iterable<KitchenMonitor> monitors,
) {
  final suffix = ArgumentConstant.envSuffix;
  return [
    for (final m in monitors)
      if (m.id != null)
        'kitchen-monitors.$branchId.${m.id}.kots.created.$suffix',
  ];
}

class KitchenMonitor {
  int? id;
  String? name;
  bool? isDefault;

  KitchenMonitor({this.id, this.name, this.isDefault});

  KitchenMonitor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isDefault = json['is_default'];
  }
}
