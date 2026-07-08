import '../core/utils/parse_utils.dart';

/// A single answer a student submitted for one question of an assigned
/// test, matching the live `student_answers` schema: `id, student_test_id,
/// question_id, answer_text, selected_answer_id, score`.
///
/// There's no stored correctness flag — with binary (all-or-nothing)
/// grading, `score > 0` implies the answer was correct.
class StudentAnswer {
  final int id;
  final int studentTestId;
  final int questionId;

  /// Selected option id for closed questions.
  final int? selectedAnswerId;

  /// Free-text response for open questions.
  final String? answerText;

  final int score;

  const StudentAnswer({
    required this.id,
    required this.studentTestId,
    required this.questionId,
    required this.score,
    this.selectedAnswerId,
    this.answerText,
  });

  factory StudentAnswer.fromJson(Map<String, dynamic> json) {
    return StudentAnswer(
      id: ParseUtils.toInt(json['id']),
      studentTestId: ParseUtils.toInt(json['student_test_id']),
      questionId: ParseUtils.toInt(json['question_id']),
      selectedAnswerId: ParseUtils.toIntOrNull(json['selected_answer_id']),
      answerText: ParseUtils.toStrOrNull(json['answer_text']),
      score: ParseUtils.toInt(json['score']),
    );
  }

  Map<String, dynamic> toJson() => {
        'student_test_id': studentTestId,
        'question_id': questionId,
        'selected_answer_id': ?selectedAnswerId,
        'answer_text': ?answerText,
        'score': score,
      };
}
