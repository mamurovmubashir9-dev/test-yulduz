import '../../core/constants/api_constants.dart';
import '../../models/grade.dart';
import '../api_service.dart';

class GradeRepository {
  static const _table = ApiConstants.gradesTable;

  Future<Grade?> getByStudentAndTest(int studentId, int testId) async {
    final rows = await ApiService.getList(
      _table,
      filters: {'student_id': studentId, 'test_id': testId},
    );
    if (rows.isEmpty) return null;
    return Grade.fromJson(rows.first);
  }

  Future<List<Grade>> getByStudent(int studentId) async {
    final rows = await ApiService.getList(_table, filters: {'student_id': studentId});
    return rows.map(Grade.fromJson).toList();
  }

  Future<void> create({
    required int studentId,
    required int teacherId,
    required int testId,
    required int grade,
    String? comment,
  }) async {
    await ApiService.create(_table, {
      'student_id': studentId,
      'teacher_id': teacherId,
      'test_id': testId,
      'grade': grade,
      'comment': ?comment,
    });
  }
}
