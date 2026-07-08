import '../../core/constants/api_constants.dart';
import '../../models/teacher.dart';
import '../api_service.dart';

class TeacherRepository {
  static const _table = ApiConstants.teachersTable;

  Future<List<Teacher>> getAll() async {
    final rows = await ApiService.getList(_table);
    return rows.map(Teacher.fromJson).toList();
  }

  Future<Teacher?> findByCredentials(String username, String password) async {
    final rows = await ApiService.getList(
      _table,
      filters: {'username': username, 'password': password},
    );
    if (rows.isEmpty) return null;
    return Teacher.fromJson(rows.first);
  }

  Future<Teacher?> getById(int id) async {
    final row = await ApiService.getOne(_table, id);
    if (row == null) return null;
    return Teacher.fromJson(row);
  }
}
