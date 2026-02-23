import 'package:fl_chart/fl_chart.dart';

class ChartDataModel {
  final String amount;
  final String percentage;
  final bool status;
  final List<FlSpot> points;

  ChartDataModel({
    required this.amount,
    required this.percentage,
    required this.status,
    required this.points,
  });

  /// ✅ Factory to convert JSON → Model
  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      amount: json['amount'] ?? '',
      percentage: json['percentage'] ?? '',
      status: json['status'] ?? false,
      points:
          (json['points'] as List<dynamic>)
              .map(
                (e) => FlSpot(
                  (e['x'] as num).toDouble(),
                  (e['y'] as num).toDouble(),
                ),
              )
              .toList(),
    );
  }

  /// ✅ Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'percentage': percentage,
      'status': status,
      'points': points.map((spot) => {'x': spot.x, 'y': spot.y}).toList(),
    };
  }
}
