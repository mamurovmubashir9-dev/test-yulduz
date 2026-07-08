import '../../core/constants/api_constants.dart';
import '../../models/answer.dart';
import '../api_service.dart';

class AnswerRepository {
  static const _table = ApiConstants.answersTable;

  Future<List<Answer>> getByQuestion(int questionId) async {
    final rows = await ApiService.getList(_table, filters: {'question_id': questionId});
    return rows.map(Answer.fromJson).toList();
  }

  /// Fetches answer options for several questions in parallel, keyed by
  /// question id.
  Future<Map<int, List<Answer>>> getByQuestions(List<int> questionIds) async {
    final result = <int, List<Answer>>{};
    final lists = await Future.wait(questionIds.map(getByQuestion));
    for (var i = 0; i < questionIds.length; i++) {
      result[questionIds[i]] = lists[i];
    }
    return result;
  }

  Future<void> create({
    required int questionId,
    required String answerText,
    required bool isCorrect,
  }) async {
    await ApiService.create(_table, {
      'question_id': questionId,
      'answer_text': answerText,
      'is_correct': isCorrect ? 1 : 0,
    });
  }

  Future<void> delete(int id) => ApiService.delete(_table, id);
}
