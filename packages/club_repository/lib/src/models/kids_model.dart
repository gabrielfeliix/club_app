import 'package:equatable/equatable.dart';

class KidsModel extends Equatable {
  final String id;
  final String age;
  final String fullName;
  final String address;
  final String birthDate;
  final String contactNumber;
  final String fatherName;
  final String motherName;
  final String notes;
  final String clubIdSave;

  const KidsModel({
    required this.id,
    required this.age,
    required this.fullName,
    required this.birthDate,
    required this.address,
    required this.contactNumber,
    required this.fatherName,
    required this.motherName,
    required this.notes,
    required this.clubIdSave,
  });

  /// Empty user witch represents an unauthenticaded user
  static const empty = KidsModel(
    id: '',
    address: '',
    age: '',
    birthDate: '',
    contactNumber: '',
    fatherName: '',
    fullName: '',
    motherName: '',
    notes: '',
    clubIdSave: '',
  );

  ///modify KidsModel parameters
  KidsModel copyWith({
    String? age,
    String? fullName,
    String? address,
    String? birthDate,
    String? contactNumber,
    String? fatherName,
    String? motherName,
    String? notes,
    String? id,
    String? clubIdSave,
  }) {
    return KidsModel(
      id: id ?? this.id,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      contactNumber: contactNumber ?? this.contactNumber,
      fatherName: fatherName ?? this.fatherName,
      fullName: fullName ?? this.fullName,
      motherName: motherName ?? this.motherName,
      notes: notes ?? this.notes,
      age: age ?? this.age,
      clubIdSave: clubIdSave ?? this.clubIdSave,
    );
  }

  factory KidsModel.fromJson(Map<String, dynamic> json) {
    // final data = json.data()!;
    return KidsModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      age: json['age'] ?? '',
      birthDate: json['birth_date'] ?? json['birthDate'] ?? '',
      address: json['address'] ?? '',
      contactNumber: json['contact_number'] ?? json['contactNumber'] ?? '',
      fatherName: json['father_name'] ?? json['fatherName'] ?? '',
      motherName: json['mother_name'] ?? json['motherName'] ?? '',
      notes: json['notes'] ?? '',
      clubIdSave: json['club_id'] ?? '',
    );
  }

  /// Convenience getter to determine whether the current user is empty
  bool get isEmpty => this == KidsModel.empty;

  /// Convenience getter to determine whether the current user is not empty
  bool get isNotEmpty => this != KidsModel.empty;

  @override
  List<Object?> get props => [
        address,
        birthDate,
        contactNumber,
        fatherName,
        fullName,
        motherName,
        notes,
        age,
        clubIdSave,
      ];
}
