class CancelReasonModel {
  bool? success;
  List<Data>? data;

  CancelReasonModel({this.success, this.data});

  CancelReasonModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  int? id;
  String? reason;
  bool? cancelOrder;
  bool? cancelKot;

  Data({this.id, this.reason, this.cancelOrder, this.cancelKot});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reason = json['reason'];
    cancelOrder = json['cancel_order'];
    cancelKot = json['cancel_kot'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason'] = reason;
    data['cancel_order'] = cancelOrder;
    data['cancel_kot'] = cancelKot;
    return data;
  }
}
