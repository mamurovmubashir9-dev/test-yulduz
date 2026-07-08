import '../../core/constants/api_constants.dart';
import '../../models/test_model.dart';
import '../api_service.dart';

class TestRepository {
  static const _table = ApiConstants.testsTable;

  Future<List<TestModel>> getByTeacher(int teacherId) async {
    final rows = await ApiService.getList(_table, filters: {'teacher_id': teacherId});
    return rows.map(TestModel.fromJson).toList();
  }

  Future<TestModel?> getById(int id) async {
    final row = await ApiService.getOne(_table, id);
    if (row == null) return null;
    return TestModel.fromJson(row);
  }

  Future<TestModel> create({
    required int teacherId,
    required String title,
    required String description,
  }) async {
    final body = {
      'teacher_id': teacherId,
      'title': title,
      'description': description,
    };
    final id = await ApiService.create(_table, body);
    if (id != null) {
      final created = await getById(id);
      if (created != null) return created;
    }
    final rows = await ApiService.getList(_table, filters: {'teacher_id': teacherId});
    final matching = rows.map(TestModel.fromJson).where((t) => t.title == title).toList();
    if (matching.isNotEmpty) return matching.last;
    throw StateError('Test yaratildi, lekin natijani o\'qib bo\'lmadi');
  }

  Future<void> update({required int id, required String title, required String description}) {
    return ApiService.update(_table, id, {'title': title, 'description': description});
  }

  Future<void> delete(int id) => ApiService.delete(_table, id);
}
