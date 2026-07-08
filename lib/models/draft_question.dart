import 'question.dart';

/// A closed-question option being edited in the test builder, before it's
/// persisted to the `answers` table.
class DraftAnswer {
  String text;
  bool isCorrect;

  DraftAnswer({this.text = '', this.isCorrect = false});
}

/// A question being edited in the test builder, before it's persisted to
/// the `questions` (+ `answers`) tables.
class DraftQuestion {
  String questionText;
  QuestionType type;
  int points;
  String correctAnswerText;
  List<DraftAnswer> options;

  DraftQuestion({
    this.questionText = '',
    this.type = QuestionType.closed,
    this.points = 1,
    this.correctAnswerText = '',
    List<DraftAnswer>? options,
  }) : options = options ?? List.generate(4, (_) => DraftAnswer());

  bool get isValid {
    if (questionText.trim().isEmpty || points <= 0) return false;
    if (type == QuestionType.open) return correctAnswerText.trim().isNotEmpty;

    final filled = options.where((o) => o.text.trim().isNotEmpty).toList();
    final hasCorrect = filled.any((o) => o.isCorrect);
    return filled.length >= 2 && hasCorrect;
  }
}
