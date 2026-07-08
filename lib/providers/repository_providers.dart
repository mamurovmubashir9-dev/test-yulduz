import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/grading_service.dart';
import '../services/repositories/answer_repository.dart';
import '../services/repositories/grade_repository.dart';
import '../services/repositories/question_repository.dart';
import '../services/repositories/student_answer_repository.dart';
import '../services/repositories/student_repository.dart';
import '../services/repositories/student_test_repository.dart';
import '../services/repositories/teacher_repository.dart';
import '../services/repositories/test_repository.dart';

final teacherRepositoryProvider = Provider((ref) => TeacherRepository());
final studentRepositoryProvider = Provider((ref) => StudentRepository());
final testRepositoryProvider = Provider((ref) => TestRepository());
final questionRepositoryProvider = Provider((ref) => QuestionRepository());
final answerRepositoryProvider = Provider((ref) => AnswerRepository());
final studentTestRepositoryProvider = Provider((ref) => StudentTestRepository());
final studentAnswerRepositoryProvider = Provider((ref) => StudentAnswerRepository());
final gradeRepositoryProvider = Provider((ref) => GradeRepository());

final gradingServiceProvider = Provider((ref) => const GradingService());

final authServiceProvider = Provider((ref) {
  return AuthService(
    teacherRepository: ref.watch(teacherRepositoryProvider),
    studentRepository: ref.watch(studentRepositoryProvider),
  );
});
