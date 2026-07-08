import '../core/utils/parse_utils.dart';

enum QuestionType { closed, open }

QuestionType questionTypeFromString(String value) {
  return value.trim().toLowerCase() == 'open' ? QuestionType.open : QuestionType.closed;
}

String questionTypeToString(QuestionType type) {
  return type == QuestionType.open ? 'open' : 'closed';
}

class Question {
  final int id;
  final int testId;
  final String questionText;
  final QuestionType questionType;
  final int points;

  /// Reference answer for open-ended questions, used for automatic grading
  /// by text comparison. Assumed column name — verify against the live
  /// `questions` table schema (`correct_answer_text`) and adjust if it
  /// differs.
  final String? correctAnswerText;

  const Question({
    required this.id,
    required this.testId,
    required this.questionText,
    required this.questionType,
    required this.points,
    this.correctAnswerText,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: ParseUtils.toInt(json['id']),
      testId: ParseUtils.toInt(json['test_id']),
      questionText: ParseUtils.toStr(json['question_text']),
      questionType: questionTypeFromString(ParseUtils.toStr(json['question_type'])),
      points: ParseUtils.toInt(json['points'], fallback: 1),
      correctAnswerText: ParseUtils.toStrOrNull(json['correct_answer_text']),
    );
  }

  Map<String, dynamic> toJson() => {
        'test_id': testId,
        'question_text': questionText,
        'question_type': questionTypeToString(questionType),
        'points': points,
        if (correctAnswerText != null) 'correct_answer_text': correctAnswerText,
      };
}
