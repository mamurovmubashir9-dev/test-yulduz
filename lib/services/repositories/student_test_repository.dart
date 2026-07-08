import 'package:intl/intl.dart';

import '../../core/constants/api_constants.dart';
import '../../models/student_test.dart';
import '../api_service.dart';

class StudentTestRepository {
  static const _table = ApiConstants.studentTestsTable;

  Future<List<StudentTest>> getByStudent(int studentId) async {
    final rows = await ApiService.getList(_table, filters: {'student_id': studentId});
    return rows.map(StudentTest.fromJson).toList();
  }

  Future<List<StudentTest>> getByTest(int testId) async {
    final rows = await ApiService.getList(_table, filters: {'test_id': testId});
    return rows.map(StudentTest.fromJson).toList();
  }

  Future<StudentTest?> getById(int id) async {
    final row = await ApiService.getOne(_table, id);
    if (row == null) return null;
    return StudentTest.fromJson(row);
  }

  /// Assigns [testId] to every id in [studentIds].
  Future<void> assignToStudents({required int testId, required List<int> studentIds}) async {
    final assignedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await Future.wait(studentIds.map((studentId) => ApiService.create(_table, {
          'student_id': studentId,
          'test_id': testId,
          'status': 'pending',
          'assigned_at': assignedAt,
        })));
  }

  Future<void> markCompleted(int id) async {
    await ApiService.update(_table, id, {'status': 'completed'});
  }
}
