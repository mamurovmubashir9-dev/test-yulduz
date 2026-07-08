enum UserRole { teacher, student }

extension UserRoleX on UserRole {
  String get storageValue => this == UserRole.teacher ? 'teacher' : 'student';

  static UserRole fromStorage(String value) {
    return value == 'teacher' ? UserRole.teacher : UserRole.student;
  }
}
