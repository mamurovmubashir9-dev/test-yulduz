import '../core/utils/parse_utils.dart';

class Teacher {
  final int id;
  final String fullname;
  final String username;
  final String password;
  final String? createdAt;

  const Teacher({
    required this.id,
    required this.fullname,
    required this.username,
    required this.password,
    this.createdAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: ParseUtils.toInt(json['id']),
      fullname: ParseUtils.toStr(json['fullname']),
      username: ParseUtils.toStr(json['username']),
      password: ParseUtils.toStr(json['password']),
      createdAt: ParseUtils.toStrOrNull(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'fullname': fullname,
        'username': username,
        'password': password,
      };
}
