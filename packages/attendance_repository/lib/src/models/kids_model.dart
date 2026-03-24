import 'package:equatable/equatable.dart';

class KidsModel extends Equatable {
  final String id;
  final String clubId;
  final String age;
  final String fullName;
  final bool isPresent;
  final bool isAbsent;
  final DateTime? createdAt;

  const KidsModel(
      {required this.id,
      required this.age,
      required this.fullName,
      required this.isAbsent,
      required this.isPresent,
      required this.clubId,
      this.createdAt});

  /// Empty user which represents an unauthenticated user
  static const empty = KidsModel(
    id: '',
    isAbsent: false,
    isPresent: false,
    age: '',
    fullName: '',
    clubId: '',
  );

  /// Modify KidsModel parameters
  KidsModel copyWith({
    String? id,
    String? age,
    String? fullName,
    String? clubId,
    bool? isAbsent,
    bool? isPresent,
    DateTime? createdAt,
  }) {
    return KidsModel(
      clubId: clubId ?? this.clubId,
      id: id ?? this.id,
      age: age ?? this.age,
      fullName: fullName ?? this.fullName,
      isAbsent: isAbsent ?? this.isAbsent,
      isPresent: isPresent ?? this.isPresent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory KidsModel.fromJsonBasic(Map<String, dynamic> json) {
    return KidsModel(
      clubId: json['club_id'] ?? '',
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? json['fullName'] ?? '',
      age: json['age'] ?? '',
      isAbsent: false,
      isPresent: false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  /// Convenience getter to determine whether the current user is empty
  bool get isEmpty => this == KidsModel.empty;

  /// Convenience getter to determine whether the current user is not empty
  bool get isNotEmpty => this != KidsModel.empty;

  @override
  List<Object?> get props => [
        id,
        age,
        fullName,
        isAbsent,
        isPresent,
        clubId,
        createdAt,
      ];
}
