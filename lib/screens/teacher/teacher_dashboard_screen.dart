import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teacher_providers.dart';
import '../../providers/theme_provider.dart';
import '../../routing/app_router.dart';
import '../../widgets/async_value_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/quick_action_tile.dart';
import '../../widgets/search_field.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/student_card.dart';
import '../../widgets/test_card.dart';
import '../../widgets/theme_toggle_button.dart';

enum _TestAction { edit, duplicate, delete }

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> {
  int _navIndex = 0;

  void _goTo(int index) {
    if (index != _navIndex) HapticFeedback.selectionClick();
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TeacherHomeTab(onNavigate: _goTo),
      const _StudentsTab(),
      const _TestsTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_navIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Bosh sahifa',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded, color: AppColors.primary),
            label: 'O\'quvchilar',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz_rounded, color: AppColors.primary),
            label: 'Testlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _TeacherHomeTab extends ConsumerWidget {
  final ValueChanged<int> onNavigate;

  const _TeacherHomeTab({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final studentsAsync = ref.watch(teacherStudentsProvider);
    final testsAsync = ref.watch(teacherTestsProvider);
    final firstName = session?.fullname.split(' ').first ?? 'Ustoz';

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teacherStudentsProvider);
        ref.invalidate(teacherTestsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Salom, $firstName 👋',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Bugun nima qilamiz?',
                        style: TextStyle(color: context.palette.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
              const ThemeToggleButton(),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: context.palette.surface,
                  foregroundColor: context.palette.textPrimary,
                ),
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Chiqish',
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.45,
            children: [
              FadeSlideIn(
                index: 0,
                child: QuickActionTile(
                  title: 'Testlar',
                  subtitle: '${testsAsync.valueOrNull?.length ?? 0} ta test',
                  icon: Icons.quiz_rounded,
                  color: AppColors.primary,
                  onTap: () => onNavigate(2),
                ),
              ),
              FadeSlideIn(
                index: 1,
                child: QuickActionTile(
                  title: 'O\'quvchilar',
                  subtitle: '${studentsAsync.valueOrNull?.length ?? 0} nafar',
                  icon: Icons.groups_rounded,
                  color: AppColors.optionBlue,
                  onTap: () => onNavigate(1),
                ),
              ),
              FadeSlideIn(
                index: 2,
                child: QuickActionTile(
                  title: 'Yangi test',
                  subtitle: 'Yaratish',
                  icon: Icons.add_circle_rounded,
                  color: AppColors.secondary,
                  onTap: () => context.push(AppRoutes.createTest),
                ),
              ),
              FadeSlideIn(
                index: 3,
                child: QuickActionTile(
                  title: 'O\'quvchi',
                  subtitle: 'Qo\'shish',
                  icon: Icons.person_add_rounded,
                  color: AppColors.optionRed,
                  onTap: () => context.push(AppRoutes.addStudent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('So\'nggi testlar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              TextButton(onPressed: () => onNavigate(2), child: const Text('Barchasi')),
            ],
          ),
          const SizedBox(height: 4),
          AsyncValueWidget(
            value: testsAsync,
            onRetry: () => ref.invalidate(teacherTestsProvider),
            loading: () => const SkeletonList(itemCount: 3, padding: EdgeInsets.zero),
            data: (tests) {
              if (tests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyView(message: 'Hali test yaratilmagan', icon: Icons.quiz_outlined),
                );
              }
              final recent = tests.reversed.take(4).toList();
              return Column(
                children: [
                  for (final (i, test) in recent.indexed) ...[
                    FadeSlideIn(
                      index: i,
                      child: TestCard(
                        test: test,
                        onTap: () => context.push(AppRoutes.testResults(test.id)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StudentsTab extends ConsumerStatefulWidget {
  const _StudentsTab();

  @override
  ConsumerState<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends ConsumerState<_StudentsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(teacherStudentsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('O\'quvchilar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              FilledButton.tonalIcon(
                onPressed: () => context.push(AppRoutes.addStudent),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Qo\'shish'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: SearchField(
            controller: _searchController,
            hint: 'O\'quvchi qidirish...',
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(teacherStudentsProvider),
            child: AsyncValueWidget(
              value: studentsAsync,
              onRetry: () => ref.invalidate(teacherStudentsProvider),
              loading: () => const SkeletonList(),
              data: (allStudents) {
                if (allStudents.isEmpty) {
                  return const _ScrollableEmpty(
                    message: 'Hali o\'quvchi qo\'shilmagan.\n"Qo\'shish" tugmasini bosing.',
                    icon: Icons.groups_outlined,
                  );
                }
                final students = _query.isEmpty
                    ? allStudents
                    : allStudents
                        .where((s) =>
                            s.fullname.toLowerCase().contains(_query) ||
                            s.username.toLowerCase().contains(_query))
                        .toList();
                if (students.isEmpty) {
                  return const _ScrollableEmpty(
                    message: 'Hech narsa topilmadi',
                    icon: Icons.search_off_rounded,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: students.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return FadeSlideIn(
                      index: index,
                      child: StudentCard(
                        student: student,
                        trailing: IconButton(
                          onPressed: () async {
                            final confirmed = await showConfirmDialog(
                              context,
                              title: 'O\'quvchini o\'chirish',
                              message:
                                  '"${student.fullname}" butunlay o\'chiriladi, shu jumladan uning barcha natijalari. Davom etasizmi?',
                            );
                            if (!confirmed || !context.mounted) return;
                            final error =
                                await ref.read(deleteStudentControllerProvider.notifier).delete(student.id);
                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                            }
                          },
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                          tooltip: 'O\'chirish',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TestsTab extends ConsumerStatefulWidget {
  const _TestsTab();

  @override
  ConsumerState<_TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends ConsumerState<_TestsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testsAsync = ref.watch(teacherTestsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Testlar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              FilledButton.tonalIcon(
                onPressed: () => context.push(AppRoutes.createTest),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Yaratish'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: SearchField(
            controller: _searchController,
            hint: 'Test qidirish...',
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(teacherTestsProvider),
            child: AsyncValueWidget(
              value: testsAsync,
              onRetry: () => ref.invalidate(teacherTestsProvider),
              loading: () => const SkeletonList(),
              data: (allTests) {
                if (allTests.isEmpty) {
                  return const _ScrollableEmpty(
                    message: 'Hali test yaratilmagan.\n"Yaratish" tugmasini bosing.',
                    icon: Icons.quiz_outlined,
                  );
                }
                final tests = _query.isEmpty
                    ? allTests
                    : allTests.where((t) => t.title.toLowerCase().contains(_query)).toList();
                if (tests.isEmpty) {
                  return const _ScrollableEmpty(
                    message: 'Hech narsa topilmadi',
                    icon: Icons.search_off_rounded,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: tests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    return FadeSlideIn(
                      index: index,
                      child: TestCard(
                        test: test,
                        actions: [
                          PopupMenuButton<_TestAction>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            tooltip: 'Ko\'proq',
                            onSelected: (action) async {
                              switch (action) {
                                case _TestAction.edit:
                                  context.push(AppRoutes.editTest(test.id));
                                case _TestAction.duplicate:
                                  final error = await ref
                                      .read(duplicateTestControllerProvider.notifier)
                                      .duplicate(test.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error ?? 'Test nusxalandi')),
                                    );
                                  }
                                case _TestAction.delete:
                                  final confirmed = await showConfirmDialog(
                                    context,
                                    title: 'Testni o\'chirish',
                                    message:
                                        '"${test.title}" testi va unga tegishli barcha natijalar butunlay o\'chiriladi. Davom etasizmi?',
                                  );
                                  if (!confirmed || !context.mounted) return;
                                  final error =
                                      await ref.read(deleteTestControllerProvider.notifier).delete(test.id);
                                  if (error != null && context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text(error)));
                                  }
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _TestAction.edit,
                                child: ListTile(
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Tahrirlash'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: _TestAction.duplicate,
                                child: ListTile(
                                  leading: Icon(Icons.copy_rounded),
                                  title: Text('Nusxalash'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: _TestAction.delete,
                                child: ListTile(
                                  leading: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                  title: Text('O\'chirish', style: TextStyle(color: AppColors.danger)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => context.push(AppRoutes.testResults(test.id)),
                            icon: const Icon(Icons.bar_chart_rounded, size: 18),
                            label: const Text('Natijalar'),
                          ),
                          const SizedBox(width: 4),
                          FilledButton.icon(
                            onPressed: () => context.push(AppRoutes.assignTest(test.id)),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('Yuborish'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3B3E63), Color(0xFF23253F)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        session?.fullname.isNotEmpty == true ? session!.fullname[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session?.fullname ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('@${session?.username ?? ''}',
                            style: TextStyle(color: context.palette.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: SwitchListTile(
              value: ref.watch(themeModeProvider) == ThemeMode.dark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
              secondary: const Icon(Icons.dark_mode_rounded),
              title: const Text('Tungi rejim', style: TextStyle(fontWeight: FontWeight.w600)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: const Text('Chiqish', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _ScrollableEmpty extends StatelessWidget {
  final String message;
  final IconData icon;

  const _ScrollableEmpty({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: EmptyView(message: message, icon: icon),
          ),
        ],
      ),
    );
  }
}
