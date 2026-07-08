import '../../core/constants/api_constants.dart';
import '../../models/student_answer.dart';
import '../api_service.dart';

class StudentAnswerRepository {
  static const _table = ApiConstants.studentAnswersTable;

  Future<List<StudentAnswer>> getByStudentTest(int studentTestId) async {
    final rows = await ApiService.getList(_table, filters: {'student_test_id': studentTestId});
    return rows.map(StudentAnswer.fromJson).toList();
  }

  Future<void> submit({
    required int studentTestId,
    required int questionId,
    int? selectedAnswerId,
    String? answerText,
    required int score,
  }) async {
    await ApiService.create(_table, {
      'student_test_id': studentTestId,
      'question_id': questionId,
      'selected_answer_id': ?selectedAnswerId,
      'answer_text': ?answerText,
      'score': score,
    });
  }
}
