import '../core/utils/parse_utils.dart';

class TestModel {
  final int id;
  final int teacherId;
  final String title;
  final String description;
  final String? createdAt;

  const TestModel({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.description,
    this.createdAt,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: ParseUtils.toInt(json['id']),
      teacherId: ParseUtils.toInt(json['teacher_id']),
      title: ParseUtils.toStr(json['title']),
      description: ParseUtils.toStr(json['description']),
      createdAt: ParseUtils.toStrOrNull(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'teacher_id': teacherId,
        'title': title,
        'description': description,
      };
}
