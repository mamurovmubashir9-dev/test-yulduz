import 'student_test.dart';
import 'test_model.dart';

/// A test assignment joined with its test details, for the student's
/// "my tests" list.
class AssignedTestInfo {
  final StudentTest studentTest;
  final TestModel test;

  const AssignedTestInfo({required this.studentTest, required this.test});
}
