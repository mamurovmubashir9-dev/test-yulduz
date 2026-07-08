import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/student_login_screen.dart';
import '../screens/auth/teacher_login_screen.dart';
import '../screens/role_selection/role_selection_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/take_test_screen.dart';
import '../screens/student/test_review_screen.dart';
import '../screens/teacher/students/add_student_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/teacher/tests/assign_test_screen.dart';
import '../screens/teacher/tests/create_test_screen.dart';
import '../screens/teacher/tests/test_results_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const roleSelection = '/';
  static const teacherLogin = '/teacher/login';
  static const studentLogin = '/student/login';
  static const teacherDashboard = '/teacher';
  static const addStudent = '/teacher/students/add';
  static const createTest = '/teacher/tests/create';
  static String editTest(int testId) => '/teacher/tests/$testId/edit';
  static String assignTest(int testId) => '/teacher/tests/$testId/assign';
  static String testResults(int testId) => '/teacher/tests/$testId/results';
  static const studentDashboard = '/student';
  static String takeTest(int studentTestId, int testId) => '/student/take/$studentTestId/$testId';
  static String reviewTest(int studentTestId) => '/student/review/$studentTestId';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (authState.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final session = authState.valueOrNull;
      final onAuthScreen = location == AppRoutes.splash ||
          location == AppRoutes.roleSelection ||
          location == AppRoutes.teacherLogin ||
          location == AppRoutes.studentLogin;

      if (session == null) {
        return (onAuthScreen && location != AppRoutes.splash) ? null : AppRoutes.roleSelection;
      }

      final onTeacherArea = location.startsWith('/teacher');
      final onStudentArea = location.startsWith('/student');

      if (session.role == UserRole.teacher) {
        if (onAuthScreen || onStudentArea) return AppRoutes.teacherDashboard;
      } else {
        if (onAuthScreen || onTeacherArea) return AppRoutes.studentDashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherLogin,
        builder: (context, state) => const TeacherLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentLogin,
        builder: (context, state) => const StudentLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherDashboard,
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.addStudent,
        builder: (context, state) => const AddStudentScreen(),
      ),
      GoRoute(
        path: AppRoutes.createTest,
        builder: (context, state) => const CreateTestScreen(),
      ),
      GoRoute(
        path: '/teacher/tests/:testId/edit',
        builder: (context, state) {
          final testId = int.parse(state.pathParameters['testId']!);
          return CreateTestScreen(testId: testId);
        },
      ),
      GoRoute(
        path: '/teacher/tests/:testId/assign',
        builder: (context, state) {
          final testId = int.parse(state.pathParameters['testId']!);
          return AssignTestScreen(testId: testId);
        },
      ),
      GoRoute(
        path: '/teacher/tests/:testId/results',
        builder: (context, state) {
          final testId = int.parse(state.pathParameters['testId']!);
          return TestResultsScreen(testId: testId);
        },
      ),
      GoRoute(
        path: AppRoutes.studentDashboard,
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/student/take/:studentTestId/:testId',
        builder: (context, state) {
          final studentTestId = int.parse(state.pathParameters['studentTestId']!);
          final testId = int.parse(state.pathParameters['testId']!);
          return TakeTestScreen(studentTestId: studentTestId, testId: testId);
        },
      ),
      GoRoute(
        path: '/student/review/:studentTestId',
        builder: (context, state) {
          final studentTestId = int.parse(state.pathParameters['studentTestId']!);
          return TestReviewScreen(studentTestId: studentTestId);
        },
      ),
    ],
  );
});
