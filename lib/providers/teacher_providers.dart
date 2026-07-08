import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/draft_question.dart';
import '../models/question.dart';
import '../models/student.dart';
import '../models/test_model.dart';
import '../models/test_result_info.dart';
import '../models/user_role.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Students that belong to the signed-in teacher.
final teacherStudentsProvider = FutureProvider.autoDispose<List<Student>>((ref) async {
  final session = ref.watch(authControllerProvider).valueOrNull;
  if (session == null || session.role != UserRole.teacher) return [];
  return ref.watch(studentRepositoryProvider).getByTeacher(session.userId);
});

/// Tests created by the signed-in teacher.
final teacherTestsProvider = FutureProvider.autoDispose<List<TestModel>>((ref) async {
  final session = ref.watch(authControllerProvider).valueOrNull;
  if (session == null || session.role != UserRole.teacher) return [];
  return ref.watch(testRepositoryProvider).getByTeacher(session.userId);
});

/// Per-student results for a given test, for the teacher's results screen.
final testResultsProvider =
    FutureProvider.autoDispose.family<List<TestResultInfo>, int>((ref, testId) async {
  final studentTestRepo = ref.watch(studentTestRepositoryProvider);
  final studentRepo = ref.watch(studentRepositoryProvider);
  final gradeRepo = ref.watch(gradeRepositoryProvider);

  final assignments = await studentTestRepo.getByTest(testId);
  final results = <TestResultInfo>[];
  for (final assignment in assignments) {
    final student = await studentRepo.getById(assignment.studentId);
    if (student == null) continue;
    final grade = await gradeRepo.getByStudentAndTest(assignment.studentId, testId);
    results.add(TestResultInfo(student: student, studentTest: assignment, grade: grade));
  }
  return results;
});

class AddStudentController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns an error message on failure, or null on success.
  Future<String?> addStudent({
    required String fullname,
    required String username,
    required String password,
  }) async {
    final session = ref.read(authControllerProvider).valueOrNull;
    if (session == null) return 'Sessiya topilmadi, qayta kiring';

    state = const AsyncLoading();
    try {
      final repo = ref.read(studentRepositoryProvider);
      if (await repo.usernameTaken(username)) {
        state = const AsyncData(null);
        return 'Bu login band, boshqasini tanlang';
      }
      await repo.create(
        teacherId: session.userId,
        fullname: fullname,
        username: username,
        password: password,
      );
      state = const AsyncData(null);
      ref.invalidate(teacherStudentsProvider);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'O\'quvchi qo\'shishda xatolik yuz berdi';
    }
  }
}

final addStudentControllerProvider =
    AsyncNotifierProvider.autoDispose<AddStudentController, void>(AddStudentController.new);

class DeleteStudentController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns an error message on failure, or null on success.
  Future<String?> delete(int studentId) async {
    state = const AsyncLoading();
    try {
      await ref.read(studentRepositoryProvider).delete(studentId);
      state = const AsyncData(null);
      ref.invalidate(teacherStudentsProvider);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'O\'quvchini o\'chirishda xatolik yuz berdi';
    }
  }
}

final deleteStudentControllerProvider =
    AsyncNotifierProvider.autoDispose<DeleteStudentController, void>(DeleteStudentController.new);

class CreateTestController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns an error message on failure, or null on success.
  Future<String?> createTest({
    required String title,
    required String description,
    required List<DraftQuestion> questions,
  }) async {
    final session = ref.read(authControllerProvider).valueOrNull;
    if (session == null) return 'Sessiya topilmadi, qayta kiring';
    if (questions.isEmpty) return 'Kamida bitta savol qo\'shing';

    state = const AsyncLoading();
    try {
      final testRepo = ref.read(testRepositoryProvider);
      final questionRepo = ref.read(questionRepositoryProvider);
      final answerRepo = ref.read(answerRepositoryProvider);

      final test = await testRepo.create(
        teacherId: session.userId,
        title: title,
        description: description,
      );

      for (final draft in questions) {
        final questionId = await questionRepo.create(
          testId: test.id,
          questionText: draft.questionText,
          questionType: draft.type,
          points: draft.points,
          correctAnswerText: draft.type == QuestionType.open ? draft.correctAnswerText : null,
        );

        if (draft.type == QuestionType.closed) {
          for (final option in draft.options) {
            if (option.text.trim().isEmpty) continue;
            await answerRepo.create(
              questionId: questionId,
              answerText: option.text.trim(),
              isCorrect: option.isCorrect,
            );
          }
        }
      }

      state = const AsyncData(null);
      ref.invalidate(teacherTestsProvider);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Test yaratishda xatolik yuz berdi';
    }
  }
}

final createTestControllerProvider =
    AsyncNotifierProvider.autoDispose<CreateTestController, void>(CreateTestController.new);

class DuplicateTestController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Clones a test's title/description and every question + answer option
  /// into a brand new test, so a teacher can reuse one as a starting point
  /// for a similar group/period without editing the original.
  ///
  /// Returns an error message on failure, or null on success.
  Future<String?> duplicate(int testId) async {
    final session = ref.read(authControllerProvider).valueOrNull;
    if (session == null) return 'Sessiya topilmadi, qayta kiring';

    state = const AsyncLoading();
    try {
      final testRepo = ref.read(testRepositoryProvider);
      final questionRepo = ref.read(questionRepositoryProvider);
      final answerRepo = ref.read(answerRepositoryProvider);

      final source = await testRepo.getById(testId);
      if (source == null) return 'Test topilmadi';

      final newTest = await testRepo.create(
        teacherId: session.userId,
        title: '${source.title} (nusxa)',
        description: source.description,
      );

      final questions = await questionRepo.getByTest(testId);
      for (final question in questions) {
        final newQuestionId = await questionRepo.create(
          testId: newTest.id,
          questionText: question.questionText,
          questionType: question.questionType,
          points: question.points,
          correctAnswerText: question.correctAnswerText,
        );

        if (question.questionType == QuestionType.closed) {
          final options = await answerRepo.getByQuestion(question.id);
          for (final option in options) {
            await answerRepo.create(
              questionId: newQuestionId,
              answerText: option.answerText,
              isCorrect: option.isCorrect,
            );
          }
        }
      }

      state = const AsyncData(null);
      ref.invalidate(teacherTestsProvider);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Testni nusxalashda xatolik yuz berdi';
    }
  }
}

final duplicateTestControllerProvider =
    AsyncNotifierProvider.autoDispose<DuplicateTestController, void>(DuplicateTestController.new);

class DeleteTestController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns an error message on failure, or null on success.
  Future<String?> delete(int testId) async {
    state = const AsyncLoading();
    try {
      await ref.read(testRepositoryProvider).delete(testId);
      state = const AsyncData(null);
      ref.invalidate(teacherTestsProvider);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Testni o\'chirishda xatolik yuz berdi';
    }
  }
}

final deleteTestControllerProvider =
    AsyncNotifierProvider.autoDispose<DeleteTestController, void>(DeleteTestController.new);

class EditTestController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns an error message on failure, or null on success. There's no
  /// per-question diffing — the edited draft list simply replaces every
  /// existing question (and its answer options) for the test, which is
  /// simple to reason about correctly for the small, teacher-authored sets
  /// this app deals with.
  Future<String?> editTest({
    required int testId,
    required String title,
    required String description,
    required List<DraftQuestion> questions,
  }) async {
    state = const AsyncLoading();
    try {
      final testRepo = ref.read(testRepositoryProvider);
      final questionRepo = ref.read(questionRepositoryProvider);
      final answerRepo = ref.read(answerRepositoryProvider);

      await testRepo.update(id: testId, title: title, description: description);

      final existingQuestions = await questionRepo.getByTest(testId);
      for (final question in existingQuestions) {
        if (question.questionType == QuestionType.closed) {
          final options = await answerRepo.getByQuestion(question.id);
          await Future.wait(options.map((o) => answerRepo.delete(o.id)));
        }
        await questionRepo.delete(question.id);
      }

      for (final draft in questions) {
        final questionId = await questionRepo.create(
          testId: testId,
          questionText: draft.questionText,
          questionType: draft.type,
          points: draft.points,
          correctAnswerText: draft.type == QuestionType.open ? draft.correctAnswerText : null,
        );

        if (draft.type == QuestionType.closed) {
          for (final option in draft.options) {
            if (option.text.trim().isEmpty) continue;
            await answerRepo.create(
              questionId: questionId,
              answerText: option.text.trim(),
              isCorrect: option.isCorrect,
            );
          }
        }
      }

      state = const AsyncData(null);
      ref.invalidate(teacherTestsProvider);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Testni tahrirlashda xatolik yuz berdi';
    }
  }
}

final editTestControllerProvider =
    AsyncNotifierProvider.autoDispose<EditTestController, void>(EditTestController.new);

class AssignTestController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns an error message on failure, or null on success.
  Future<String?> assign({required int testId, required List<int> studentIds}) async {
    if (studentIds.isEmpty) return 'Kamida bitta o\'quvchi tanlang';

    state = const AsyncLoading();
    try {
      await ref.read(studentTestRepositoryProvider).assignToStudents(
            testId: testId,
            studentIds: studentIds,
          );
      state = const AsyncData(null);
      return null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Testni biriktirishda xatolik yuz berdi';
    }
  }
}

final assignTestControllerProvider =
    AsyncNotifierProvider.autoDispose<AssignTestController, void>(AssignTestController.new);
