import '../core/utils/parse_utils.dart';

/// An answer option for a closed (multiple-choice) question.
class Answer {
  final int id;
  final int questionId;
  final String answerText;
  final bool isCorrect;

  const Answer({
    required this.id,
    required this.questionId,
    required this.answerText,
    required this.isCorrect,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: ParseUtils.toInt(json['id']),
      questionId: ParseUtils.toInt(json['question_id']),
      answerText: ParseUtils.toStr(json['answer_text']),
      isCorrect: ParseUtils.toBool(json['is_correct']),
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'answer_text': answerText,
        'is_correct': isCorrect ? 1 : 0,
      };
}
