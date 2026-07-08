import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';
import '../models/user_role.dart';
import 'repositories/student_repository.dart';
import 'repositories/teacher_repository.dart';

/// Handles login and session persistence.
///
/// The VIPS backend has no auth endpoint — it's a raw table CRUD API with
/// passwords stored in plain text. Login here is just a filtered lookup
/// against `teachers`/`students`, done client-side. This is adequate for
/// a school-project scope but should not be treated as secure credential
/// handling.
class AuthService {
  AuthService({
    TeacherRepository? teacherRepository,
    StudentRepository? studentRepository,
  })  : _teacherRepository = teacherRepository ?? TeacherRepository(),
        _studentRepository = studentRepository ?? StudentRepository();

  static const _sessionKey = 'auth_session';

  final TeacherRepository _teacherRepository;
  final StudentRepository _studentRepository;

  Future<AuthSession?> loginTeacher(String username, String password) async {
    final teacher = await _teacherRepository.findByCredentials(username, password);
    if (teacher == null) return null;

    final session = AuthSession(
      role: UserRole.teacher,
      userId: teacher.id,
      fullname: teacher.fullname,
      username: teacher.username,
    );
    await _persist(session);
    return session;
  }

  Future<AuthSession?> loginStudent(String username, String password) async {
    final student = await _studentRepository.findByCredentials(username, password);
    if (student == null) return null;

    final session = AuthSession(
      role: UserRole.student,
      userId: student.id,
      fullname: student.fullname,
      username: student.username,
      teacherId: student.teacherId,
    );
    await _persist(session);
    return session;
  }

  Future<void> _persist(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<AuthSession?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    try {
      return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
