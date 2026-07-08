/// VIPS D190 low-code backend configuration.
///
/// This backend has no custom endpoints or business logic — every table is
/// exposed as a generic CRUD resource identified by a numeric table id.
/// Login, grading and score calculation therefore all happen client-side.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://d190.vips.uz';
  static const String connId = '20';
  static const String databaseId = '1466';
  static const String apiKey = 'qwerty';

  static const String teachersTable = '12733';
  static const String studentsTable = '12730';
  static const String testsTable = '12460';
  static const String questionsTable = '12458';
  static const String answersTable = '12728';
  static const String studentTestsTable = '12732';
  static const String studentAnswersTable = '12731';
  static const String gradesTable = '12729';
}
