import 'grade.dart';
import 'student.dart';
import 'student_test.dart';

/// One student's assignment + grade for a test, for the teacher's results
/// list.
class TestResultInfo {
  final Student student;
  final StudentTest studentTest;
  final Grade? grade;

  const TestResultInfo({required this.student, required this.studentTest, this.grade});
}
