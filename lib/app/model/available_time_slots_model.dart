class AvailableTimeSlotsModel {
  bool? success;
  AvailableTimeSlotsData? data;

  AvailableTimeSlotsModel({this.success, this.data});

  AvailableTimeSlotsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    data =
        json['data'] != null
            ? AvailableTimeSlotsData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AvailableTimeSlotsData {
  bool? isClosed;
  Map<String, List<String>>? timeSlots;

  AvailableTimeSlotsData({this.isClosed, this.timeSlots});

  AvailableTimeSlotsData.fromJson(Map<String, dynamic> json) {
    isClosed = json['is_closed'] as bool?;
    if (json['time_slots'] != null && json['time_slots'] is Map) {
      timeSlots = <String, List<String>>{};
      final raw = json['time_slots'] as Map<String, dynamic>;
      for (final entry in raw.entries) {
        if (entry.value is List) {
          timeSlots![entry.key] =
              (entry.value as List).map((e) => e.toString()).toList();
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_closed'] = isClosed;
    if (timeSlots != null) {
      data['time_slots'] = timeSlots;
    }
    return data;
  }
}

class TimeSlotSection {
  final String title;
  final List<String> slots;

  TimeSlotSection({required this.title, required this.slots});
}
