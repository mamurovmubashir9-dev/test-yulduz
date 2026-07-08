import '../core/utils/parse_utils.dart';

class Student {
  final int id;
  final int teacherId;
  final String fullname;
  final String username;
  final String password;
  final String? createdAt;

  const Student({
    required this.id,
    required this.teacherId,
    required this.fullname,
    required this.username,
    required this.password,
    this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: ParseUtils.toInt(json['id']),
      teacherId: ParseUtils.toInt(json['teacher_id']),
      fullname: ParseUtils.toStr(json['fullname']),
      username: ParseUtils.toStr(json['username']),
      password: ParseUtils.toStr(json['password']),
      createdAt: ParseUtils.toStrOrNull(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'teacher_id': teacherId,
        'fullname': fullname,
        'username': username,
        'password': password,
      };
}
