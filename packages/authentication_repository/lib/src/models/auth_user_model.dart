enum UserRole {
  teacher,
  coordinator,
  admin,
}

class AuthUserModel {
  final String userId;
  final UserRole userRole;
  final List<String> classIds;

  AuthUserModel({
    required this.userId,
    required this.userRole,
    this.classIds = const [],
  });

  AuthUserModel copyWith({
    String? userId,
    UserRole? userRole,
    List<String>? classIds,
  }) =>
      AuthUserModel(
        userId: userId ?? this.userId,
        userRole: userRole ?? this.userRole,
        classIds: classIds ?? this.classIds,
      );
}
