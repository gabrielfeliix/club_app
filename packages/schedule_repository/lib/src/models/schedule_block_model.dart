import 'package:equatable/equatable.dart';

class ScheduleBlockModel extends Equatable {
  final String id;
  final String scheduleId;
  final int order;
  final String title;
  final int durationMinutes;
  final List<String> responsibleNames;
  final String description;
  final String? link;

  const ScheduleBlockModel({
    required this.id,
    required this.scheduleId,
    required this.order,
    required this.title,
    required this.durationMinutes,
    required this.responsibleNames,
    this.description = '',
    this.link,
  });

  ScheduleBlockModel copyWith({
    String? id,
    String? scheduleId,
    int? order,
    String? title,
    int? durationMinutes,
    List<String>? responsibleNames,
    String? description,
    String? link,
  }) {
    return ScheduleBlockModel(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      order: order ?? this.order,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      responsibleNames: responsibleNames ?? this.responsibleNames,
      description: description ?? this.description,
      link: link ?? this.link,
    );
  }

  factory ScheduleBlockModel.fromJson(Map<String, dynamic> json) {
    return ScheduleBlockModel(
      id: json['id'] ?? '',
      scheduleId: json['schedule_id'] ?? '',
      order: json['order'] ?? 0,
      title: json['title'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      responsibleNames: (json['responsible_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: json['description'] ?? '',
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (scheduleId.isNotEmpty) 'schedule_id': scheduleId,
      'order': order,
      'title': title,
      'duration_minutes': durationMinutes,
      'responsible_names': responsibleNames,
      'description': description,
      if (link != null) 'link': link,
    };
  }

  @override
  List<Object?> get props => [
        id,
        scheduleId,
        order,
        title,
        durationMinutes,
        responsibleNames,
        description,
        link,
      ];
}
