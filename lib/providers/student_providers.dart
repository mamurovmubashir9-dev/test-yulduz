import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/assigned_test_info.dart';
import '../models/grade.dart';
import '../models/student_test.dart';
import '../models/test_model.dart';
import '../models/user_role.dart';
import '../services/grading_service.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';
import 'test_taking_provider.dart';

/// Tests assigned to the signed-in student, joined with test details.
final studentAssignedTestsProvider = FutureProvider.autoDispose<List<AssignedTestInfo>>((ref) async {
  final session = ref.watch(authControllerProvider).valueOrNull;
  if (session == null || session.role != UserRole.student) return [];

  final studentTestRepo = ref.watch(studentTestRepositoryProvider);
  final testRepo = ref.watch(testRepositoryProvider);

  final assignments = await studentTestRepo.getByStudent(session.userId);
  final infos = <AssignedTestInfo>[];
  for (final assignment in assignments) {
    final test = await testRepo.getById(assignment.testId);
    if (test != null) {
      infos.add(AssignedTestInfo(studentTest: assignment, test: test));
    }
  }
  infos.sort((a, b) => b.studentTest.id.compareTo(a.studentTest.id));
  return infos;
});

/// The grade for one completed assignment, used to show a score badge on
/// the student's dashboard without loading every grade up front. Keyed by
/// (studentId, testId) since `grades` links to those, not to a
/// `student_tests` row.
final studentTestGradeProvider =
    FutureProvider.autoDispose.family<Grade?, (int studentId, int testId)>((ref, key) {
  return ref.watch(gradeRepositoryProvider).getByStudentAndTest(key.$1, key.$2);
});

/// A single `student_tests` assignment by its own id, used by the
/// test-taking screen to know which assignment to grade against.
final studentTestByIdProvider =
    FutureProvider.autoDispose.family<StudentTest?, int>((ref, studentTestId) {
  return ref.watch(studentTestRepositoryProvider).getById(studentTestId);
});

typedef CompletedTestReview = ({TestModel test, TestGradeSummary summary});

/// Rebuilds the full question-by-question breakdown for a test the student
/// already finished, so they can review it again later from the dashboard
/// (the score alone is shown inline, but the "why" needs the original
/// questions/answers re-graded from what was actually submitted).
final completedTestReviewProvider =
    FutureProvider.autoDispose.family<CompletedTestReview, int>((ref, studentTestId) async {
  final studentTest = await ref.watch(studentTestRepositoryProvider).getById(studentTestId);
  if (studentTest == null) throw StateError('Topshiriq topilmadi');

  final data = await ref.watch(testTakingDataProvider(studentTest.testId).future);
  final answers = await ref.watch(studentAnswerRepositoryProvider).getByStudentTest(studentTestId);

  final responses = <int, dynamic>{
    for (final answer in answers) answer.questionId: answer.selectedAnswerId ?? answer.answerText,
  };

  final summary = ref.watch(gradingServiceProvider).grade(
        questions: data.questions,
        answersByQuestion: data.answersByQuestion,
        responses: responses,
      );

  return (test: data.test, summary: summary);
});

typedef StudentStats = ({int completedCount, double averageGrade});

/// Simple lifetime performance summary shown on the student's profile tab.
final studentStatsProvider = FutureProvider.autoDispose<StudentStats>((ref) async {
  final session = ref.watch(authControllerProvider).valueOrNull;
  if (session == null) return (completedCount: 0, averageGrade: 0.0);

  final grades = await ref.watch(gradeRepositoryProvider).getByStudent(session.userId);
  if (grades.isEmpty) return (completedCount: 0, averageGrade: 0.0);

  final average = grades.map((g) => g.grade).reduce((a, b) => a + b) / grades.length;
  return (completedCount: grades.length, averageGrade: average);
});
