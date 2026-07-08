import '../core/utils/parse_utils.dart';

/// Final computed result for one completed test attempt, matching the live
/// `grades` schema: `id, student_id, teacher_id, test_id, grade, comment,
/// created_at`. There's a single `grade` column (the 2-5 mark) — the raw
/// score/percentage breakdown isn't stored server-side, so it's summarized
/// into [comment] for a human-readable record.
class Grade {
  final int id;
  final int studentId;
  final int teacherId;
  final int testId;
  final int grade;
  final String? comment;
  final String? createdAt;

  const Grade({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.testId,
    required this.grade,
    this.comment,
    this.createdAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: ParseUtils.toInt(json['id']),
      studentId: ParseUtils.toInt(json['student_id']),
      teacherId: ParseUtils.toInt(json['teacher_id']),
      testId: ParseUtils.toInt(json['test_id']),
      grade: ParseUtils.toInt(json['grade']),
      comment: ParseUtils.toStrOrNull(json['comment']),
      createdAt: ParseUtils.toStrOrNull(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'teacher_id': teacherId,
        'test_id': testId,
        'grade': grade,
        if (comment != null) 'comment': comment,
      };
}
