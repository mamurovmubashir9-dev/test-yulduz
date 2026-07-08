import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_session.dart';
import 'repository_providers.dart';

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    // Session restore from local storage resolves almost instantly, which
    // made the splash screen flash by unnoticed. Holding it back to a
    // fixed minimum keeps the brand moment visible without adding real
    // startup latency for anyone on a slow connection (the two run in
    // parallel, so the wait is only as long as whichever takes longer).
    final results = await Future.wait([
      ref.watch(authServiceProvider).restoreSession(),
      Future.delayed(const Duration(milliseconds: 1300)),
    ]);
    return results[0] as AuthSession?;
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> loginTeacher(String username, String password) async {
    state = const AsyncLoading();
    try {
      final session = await ref.read(authServiceProvider).loginTeacher(username, password);
      state = AsyncData(session);
      return session == null ? 'Login yoki parol noto\'g\'ri' : null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Xatolik yuz berdi. Internetni tekshiring.';
    }
  }

  Future<String?> loginStudent(String username, String password) async {
    state = const AsyncLoading();
    try {
      final session = await ref.read(authServiceProvider).loginStudent(username, password);
      state = AsyncData(session);
      return session == null ? 'Login yoki parol noto\'g\'ri' : null;
    } catch (e) {
      state = const AsyncData(null);
      return 'Xatolik yuz berdi. Internetni tekshiring.';
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthSession?>(
  AuthController.new,
);
