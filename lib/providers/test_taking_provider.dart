import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/answer.dart';
import '../models/question.dart';
import '../models/student_test.dart';
import '../models/test_model.dart';
import '../services/grading_service.dart';
import 'repository_providers.dart';
import 'student_providers.dart';

class TestTakingData {
  final TestModel test;
  final List<Question> questions;
  final Map<int, List<Answer>> answersByQuestion;

  const TestTakingData({
    required this.test,
    required this.questions,
    required this.answersByQuestion,
  });
}

/// Loads a test's full content (questions + answer options) for the
/// student to work through.
final testTakingDataProvider =
    FutureProvider.autoDispose.family<TestTakingData, int>((ref, testId) async {
  final testRepo = ref.watch(testRepositoryProvider);
  final questionRepo = ref.watch(questionRepositoryProvider);
  final answerRepo = ref.watch(answerRepositoryProvider);

  final test = await testRepo.getById(testId);
  if (test == null) throw StateError('Test topilmadi');

  final questions = await questionRepo.getByTest(testId);
  final closedIds =
      questions.where((q) => q.questionType == QuestionType.closed).map((q) => q.id).toList();
  final answersByQuestion = await answerRepo.getByQuestions(closedIds);

  return TestTakingData(test: test, questions: questions, answersByQuestion: answersByQuestion);
});

/// In-progress answers for the test currently being taken: question id ->
/// selected answer id (closed) or raw text (open).
class TestResponsesNotifier extends AutoDisposeNotifier<Map<int, dynamic>> {
  @override
  Map<int, dynamic> build() => {};

  void setAnswer(int questionId, dynamic value) {
    state = {...state, questionId: value};
  }

  void reset() => state = {};
}

final testResponsesProvider =
    AutoDisposeNotifierProvider<TestResponsesNotifier, Map<int, dynamic>>(
  TestResponsesNotifier.new,
);

class SubmitTestController extends AutoDisposeAsyncNotifier<TestGradeSummary?> {
  @override
  Future<TestGradeSummary?> build() async => null;

  Future<TestGradeSummary?> submit({
    required StudentTest studentTest,
    required TestTakingData data,
    required Map<int, dynamic> responses,
  }) async {
    state = const AsyncLoading();
    try {
      final summary = ref.read(gradingServiceProvider).grade(
            questions: data.questions,
            answersByQuestion: data.answersByQuestion,
            responses: responses,
          );

      final studentAnswerRepo = ref.read(studentAnswerRepositoryProvider);
      await Future.wait(summary.questionResults.map((result) => studentAnswerRepo.submit(
            studentTestId: studentTest.id,
            questionId: result.question.id,
            selectedAnswerId: result.selectedAnswerId,
            answerText: result.textResponse,
            score: result.scoreEarned,
          )));

      await ref.read(gradeRepositoryProvider).create(
            studentId: studentTest.studentId,
            teacherId: data.test.teacherId,
            testId: data.test.id,
            grade: int.parse(summary.gradeLabel),
            comment: '${summary.totalScore}/${summary.maxScore} ball '
                '(${summary.percentage.toStringAsFixed(0)}%)',
          );

      await ref.read(studentTestRepositoryProvider).markCompleted(studentTest.id);

      state = AsyncData(summary);
      ref.invalidate(studentAssignedTestsProvider);
      return summary;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final submitTestControllerProvider =
    AutoDisposeAsyncNotifierProvider<SubmitTestController, TestGradeSummary?>(
  SubmitTestController.new,
);
