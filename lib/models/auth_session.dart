import 'user_role.dart';

/// The currently signed-in user, regardless of role.
class AuthSession {
  final UserRole role;
  final int userId;
  final String fullname;
  final String username;

  /// Only set when [role] is [UserRole.student] — links back to the
  /// teacher who created the account.
  final int? teacherId;

  const AuthSession({
    required this.role,
    required this.userId,
    required this.fullname,
    required this.username,
    this.teacherId,
  });

  Map<String, dynamic> toJson() => {
        'role': role.storageValue,
        'user_id': userId,
        'fullname': fullname,
        'username': username,
        if (teacherId != null) 'teacher_id': teacherId,
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      role: UserRoleX.fromStorage(json['role'] as String),
      userId: json['user_id'] as int,
      fullname: json['fullname'] as String,
      username: json['username'] as String,
      teacherId: json['teacher_id'] as int?,
    );
  }
}
