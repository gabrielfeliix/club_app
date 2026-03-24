import 'package:equatable/equatable.dart';
import 'schedule_block_model.dart';

class ScheduleModel extends Equatable {
  final String id;
  final String clubId;
  final DateTime date;
  final List<ScheduleBlockModel> blocks;
  final DateTime? createdAt;

  const ScheduleModel({
    required this.id,
    required this.clubId,
    required this.date,
    this.blocks = const [],
    this.createdAt,
  });

  ScheduleModel copyWith({
    String? id,
    String? clubId,
    DateTime? date,
    List<ScheduleBlockModel>? blocks,
    DateTime? createdAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      date: date ?? this.date,
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json,
      {List<ScheduleBlockModel> blocks = const []}) {
    return ScheduleModel(
      id: json['id'] ?? '',
      clubId: json['club_id'] ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      blocks: blocks,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'club_id': clubId,
      'date': date.toIso8601String().split('T').first,
    };
  }

  @override
  List<Object?> get props => [id, clubId, date, blocks, createdAt];
}
