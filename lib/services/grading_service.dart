import '../models/answer.dart';
import '../models/question.dart';

class QuestionResult {
  final Question question;
  final bool isCorrect;
  final int scoreEarned;
  final int? selectedAnswerId;
  final String? textResponse;

  const QuestionResult({
    required this.question,
    required this.isCorrect,
    required this.scoreEarned,
    this.selectedAnswerId,
    this.textResponse,
  });
}

class TestGradeSummary {
  final List<QuestionResult> questionResults;
  final int totalScore;
  final int maxScore;
  final double percentage;
  final String gradeLabel;

  const TestGradeSummary({
    required this.questionResults,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.gradeLabel,
  });
}

/// Grades a completed test attempt entirely on-device, since the VIPS
/// backend has no scoring logic of its own.
///
/// Grading is binary per question (full points or zero) — the spec doesn't
/// call for partial credit. Open questions are graded by a normalized
/// (trimmed, case-insensitive, collapsed-whitespace) exact text match
/// against the teacher-provided reference answer.
class GradingService {
  const GradingService();

  /// [responses] maps question id -> selected answer id (closed questions)
  /// or the student's raw text (open questions).
  TestGradeSummary grade({
    required List<Question> questions,
    required Map<int, List<Answer>> answersByQuestion,
    required Map<int, dynamic> responses,
  }) {
    final results = <QuestionResult>[];

    for (final question in questions) {
      final response = responses[question.id];

      if (question.questionType == QuestionType.closed) {
        final options = answersByQuestion[question.id] ?? const <Answer>[];
        final selectedId = response is int ? response : int.tryParse('$response');
        final selected = options.where((a) => a.id == selectedId).toList();
        final isCorrect = selected.isNotEmpty && selected.first.isCorrect;

        results.add(QuestionResult(
          question: question,
          isCorrect: isCorrect,
          scoreEarned: isCorrect ? question.points : 0,
          selectedAnswerId: selectedId,
        ));
      } else {
        final text = (response as String?)?.trim() ?? '';
        final isCorrect = _normalize(text) == _normalize(question.correctAnswerText ?? '') &&
            _normalize(text).isNotEmpty;

        results.add(QuestionResult(
          question: question,
          isCorrect: isCorrect,
          scoreEarned: isCorrect ? question.points : 0,
          textResponse: text,
        ));
      }
    }

    final totalScore = results.fold<int>(0, (sum, r) => sum + r.scoreEarned);
    final maxScore = questions.fold<int>(0, (sum, q) => sum + q.points);
    final percentage = maxScore == 0 ? 0.0 : (totalScore / maxScore) * 100;

    return TestGradeSummary(
      questionResults: results,
      totalScore: totalScore,
      maxScore: maxScore,
      percentage: percentage,
      gradeLabel: _gradeLabelFor(percentage),
    );
  }

  String _normalize(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Standard 5-point O'zbekiston maktab baholash shkalasi.
  String _gradeLabelFor(double percentage) {
    if (percentage >= 90) return '5';
    if (percentage >= 70) return '4';
    if (percentage >= 50) return '3';
    return '2';
  }
}
