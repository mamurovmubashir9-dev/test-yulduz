import '../../core/constants/api_constants.dart';
import '../../models/student.dart';
import '../api_service.dart';

class StudentRepository {
  static const _table = ApiConstants.studentsTable;

  Future<List<Student>> getByTeacher(int teacherId) async {
    final rows = await ApiService.getList(_table, filters: {'teacher_id': teacherId});
    return rows.map(Student.fromJson).toList();
  }

  Future<Student?> findByCredentials(String username, String password) async {
    final rows = await ApiService.getList(
      _table,
      filters: {'username': username, 'password': password},
    );
    if (rows.isEmpty) return null;
    return Student.fromJson(rows.first);
  }

  Future<Student?> getById(int id) async {
    final row = await ApiService.getOne(_table, id);
    if (row == null) return null;
    return Student.fromJson(row);
  }

  Future<bool> usernameTaken(String username) async {
    final rows = await ApiService.getList(_table, filters: {'username': username});
    return rows.isNotEmpty;
  }

  Future<Student> create({
    required int teacherId,
    required String fullname,
    required String username,
    required String password,
  }) async {
    final body = {
      'teacher_id': teacherId,
      'fullname': fullname,
      'username': username,
      'password': password,
    };
    final id = await ApiService.create(_table, body);
    if (id != null) {
      final created = await getById(id);
      if (created != null) return created;
    }
    // Fallback for backends that don't echo the new id: re-read by the
    // unique username we just wrote.
    final rows = await ApiService.getList(_table, filters: {'username': username});
    if (rows.isNotEmpty) return Student.fromJson(rows.first);
    throw StateError('O\'quvchi yaratildi, lekin natijani o\'qib bo\'lmadi');
  }

  Future<void> delete(int id) => ApiService.delete(_table, id);
}
