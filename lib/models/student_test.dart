import '../core/utils/parse_utils.dart';

enum StudentTestStatus { pending, completed }

StudentTestStatus studentTestStatusFromString(String value) {
  return value.trim().toLowerCase() == 'completed'
      ? StudentTestStatus.completed
      : StudentTestStatus.pending;
}

String studentTestStatusToString(StudentTestStatus status) {
  return status == StudentTestStatus.completed ? 'completed' : 'pending';
}

/// A test assigned by a teacher to a specific student.
class StudentTest {
  final int id;
  final int studentId;
  final int testId;
  final String? assignedAt;
  final StudentTestStatus status;

  const StudentTest({
    required this.id,
    required this.studentId,
    required this.testId,
    required this.status,
    this.assignedAt,
  });

  factory StudentTest.fromJson(Map<String, dynamic> json) {
    return StudentTest(
      id: ParseUtils.toInt(json['id']),
      studentId: ParseUtils.toInt(json['student_id']),
      testId: ParseUtils.toInt(json['test_id']),
      status: studentTestStatusFromString(ParseUtils.toStr(json['status'])),
      assignedAt: ParseUtils.toStrOrNull(json['assigned_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'test_id': testId,
        'status': studentTestStatusToString(status),
        if (assignedAt != null) 'assigned_at': assignedAt,
      };
}
