import '../../core/constants/api_constants.dart';
import '../../models/question.dart';
import '../api_service.dart';

class QuestionRepository {
  static const _table = ApiConstants.questionsTable;

  Future<List<Question>> getByTest(int testId) async {
    final rows = await ApiService.getList(_table, filters: {'test_id': testId});
    final questions = rows.map(Question.fromJson).toList()..sort((a, b) => a.id.compareTo(b.id));
    return questions;
  }

  Future<int> create({
    required int testId,
    required String questionText,
    required QuestionType questionType,
    required int points,
    String? correctAnswerText,
  }) async {
    final body = {
      'test_id': testId,
      'question_text': questionText,
      'question_type': questionTypeToString(questionType),
      'points': points,
      'correct_answer_text': ?correctAnswerText,
    };
    final id = await ApiService.create(_table, body);
    if (id != null) return id;

    final rows = await ApiService.getList(_table, filters: {'test_id': testId});
    final matching = rows.map(Question.fromJson).where((q) => q.questionText == questionText);
    if (matching.isNotEmpty) return matching.last.id;
    throw StateError('Savol yaratildi, lekin id topilmadi');
  }

  Future<void> delete(int id) => ApiService.delete(_table, id);
}
