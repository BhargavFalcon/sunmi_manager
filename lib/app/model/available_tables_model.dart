import 'table_model.dart';

class AvailableTablesModel {
  bool? success;
  List<Tables>? data;

  AvailableTablesModel({this.success, this.data});

  AvailableTablesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null && json['data'] is List) {
      data = <Tables>[];
      for (final v in (json['data'] as List)) {
        if (v is Map<String, dynamic>) {
          data!.add(Tables.fromJson(v));
        }
      }
    }
  }
}
