import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';

class UsersModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String contact;
  final List<String> classIds;
  final UserRole userRole;

  const UsersModel({
    required this.id,
    required this.classIds,
    required this.name,
    required this.email,
    required this.contact,
    required this.userRole,
  });

  // Empty user witch represents an unauthenticaded user
  static const empty = UsersModel(
      name: '', email: '', contact: '', classIds: [], id: '', userRole: UserRole.teacher);

  //modify UsersModel parameters
  UsersModel copyWith({
    String? contact,
    String? name,
    String? email,
    String? id,
    List<String>? classIds,
    UserRole? userRole,
  }) {
    return UsersModel(
        id: id ?? this.id,
        classIds: classIds ?? this.classIds,
        name: name ?? this.name,
        email: email ?? this.email,
        contact: contact ?? this.contact,
        userRole: userRole ?? this.userRole);
  }

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: "",
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      classIds: (json['classIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      userRole: _getRoleLabel(json['role'] ?? ''),
    );
  }

  // Convenience getter to determine whether the current user is empty
  bool get isEmpty => this == UsersModel.empty;
  // Convenience getter to determine whether the current user is not empty
  bool get isNotEmpty => this != UsersModel.empty;

  /// Helper function to get the role label
  static UserRole _getRoleLabel(String role) {
    switch (role) {
      case 'teacher':
        return UserRole.teacher;
      case 'coordinator':
        return UserRole.coordinator;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.teacher;
    }
  }

  @override
  List<Object?> get props => [name, email, contact, classIds, id, userRole];
}
