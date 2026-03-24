import 'package:equatable/equatable.dart';

class DecisionModel extends Equatable {
  final String id;
  final String clubId;
  final String childName;
  final String address;
  final String age;
  final String phone;
  final bool isVisitor;
  final bool isEnrolled;
  final DateTime decisionDate;
  final String counselorName;
  final DateTime? createdAt;

  const DecisionModel({
    required this.id,
    required this.clubId,
    required this.childName,
    required this.address,
    required this.age,
    required this.phone,
    required this.isVisitor,
    required this.isEnrolled,
    required this.decisionDate,
    required this.counselorName,
    this.createdAt,
  });

  /// Empty decision representation
  static final empty = DecisionModel(
    id: '',
    clubId: '',
    childName: '',
    address: '',
    age: '',
    phone: '',
    isVisitor: false,
    isEnrolled: false,
    decisionDate: DateTime.now(),
    counselorName: '',
  );

  bool get isEmpty => this == DecisionModel.empty;
  bool get isNotEmpty => this != DecisionModel.empty;

  DecisionModel copyWith({
    String? id,
    String? clubId,
    String? childName,
    String? address,
    String? age,
    String? phone,
    bool? isVisitor,
    bool? isEnrolled,
    DateTime? decisionDate,
    String? counselorName,
    DateTime? createdAt,
  }) {
    return DecisionModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      childName: childName ?? this.childName,
      address: address ?? this.address,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      isVisitor: isVisitor ?? this.isVisitor,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      decisionDate: decisionDate ?? this.decisionDate,
      counselorName: counselorName ?? this.counselorName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    return DecisionModel(
      id: json['id'] ?? '',
      clubId: json['club_id'] ?? '',
      childName: json['child_name'] ?? '',
      address: json['address'] ?? '',
      age: json['age']?.toString() ?? '',
      phone: json['phone'] ?? '',
      isVisitor: json['is_visitor'] ?? false,
      isEnrolled: json['is_enrolled'] ?? false,
      decisionDate: json['decision_date'] != null
          ? DateTime.tryParse(json['decision_date']) ?? DateTime.now()
          : DateTime.now(),
      counselorName: json['counselor_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'club_id': clubId,
      'child_name': childName,
      'address': address,
      'age': age,
      'phone': phone,
      'is_visitor': isVisitor,
      'is_enrolled': isEnrolled,
      'decision_date': decisionDate.toIso8601String().split('T').first,
      'counselor_name': counselorName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        clubId,
        childName,
        address,
        age,
        phone,
        isVisitor,
        isEnrolled,
        decisionDate,
        counselorName,
        createdAt,
      ];
}
