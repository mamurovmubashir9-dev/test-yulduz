import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/assigned_test_info.dart';
import '../../models/student_test.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_providers.dart';
import '../../routing/app_router.dart';
import '../../widgets/assigned_test_card.dart';
import '../../widgets/async_value_widget.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/theme_toggle_button.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends ConsumerState<StudentDashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tests = ref.watch(studentAssignedTestsProvider).valueOrNull;
    final pendingCount =
        tests?.where((t) => t.studentTest.status == StudentTestStatus.pending).length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: _navIndex == 0 ? const _StudentHomeTab() : const _StudentProfileTab(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: [
          NavigationDestination(
            icon: pendingCount > 0
                ? Badge(label: Text('$pendingCount'), child: const Icon(Icons.home_outlined))
                : const Icon(Icons.home_outlined),
            selectedIcon: pendingCount > 0
                ? Badge(
                    label: Text('$pendingCount'),
                    child: const Icon(Icons.home_rounded, color: AppColors.primary),
                  )
                : const Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Bosh sahifa',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _StudentHomeTab extends ConsumerStatefulWidget {
  const _StudentHomeTab();

  @override
  ConsumerState<_StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends ConsumerState<_StudentHomeTab> {
  bool _showPending = true;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final testsAsync = ref.watch(studentAssignedTestsProvider);
    final firstName = session?.fullname.split(' ').first ?? 'O\'quvchi';

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(studentAssignedTestsProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Salom, $firstName! 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Bugun o\'zingizni sinab ko\'ring',
              style: TextStyle(color: context.palette.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          AsyncValueWidget(
            value: testsAsync,
            onRetry: () => ref.invalidate(studentAssignedTestsProvider),
            loading: () => const SkeletonList(padding: EdgeInsets.zero),
            data: (tests) {
              final pendingCount =
                  tests.where((t) => t.studentTest.status == StudentTestStatus.pending).length;
              final completedCount = tests.length - pendingCount;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Bajarilishi kerak',
                          value: '$pendingCount',
                          color: AppColors.primary,
                          icon: Icons.assignment_late_rounded,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatTile(
                          label: 'Bajarilgan',
                          value: '$completedCount',
                          color: AppColors.secondary,
                          icon: Icons.task_alt_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _FilterChip(
                        label: 'Bugungi testlar',
                        selected: _showPending,
                        onTap: () => setState(() => _showPending = true),
                      ),
                      const SizedBox(width: 10),
                      _FilterChip(
                        label: 'Oldingi natijalar',
                        selected: !_showPending,
                        onTap: () => setState(() => _showPending = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildList(tests),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<AssignedTestInfo> tests) {
    final filtered = tests
        .where((t) => _showPending
            ? t.studentTest.status == StudentTestStatus.pending
            : t.studentTest.status == StudentTestStatus.completed)
        .toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: EmptyView(
          message: _showPending ? 'Bajarilishi kerak bo\'lgan test yo\'q' : 'Hali test bajarilmagan',
          icon: _showPending ? Icons.assignment_turned_in_outlined : Icons.history_rounded,
        ),
      );
    }

    return Column(
      children: [
        for (final (i, info) in filtered.indexed) ...[
          FadeSlideIn(
            index: i,
            child: AssignedTestCard(
              info: info,
              onTap: () => info.studentTest.status == StudentTestStatus.completed
                  ? context.push(AppRoutes.reviewTest(info.studentTest.id))
                  : context.push(AppRoutes.takeTest(info.studentTest.id, info.test.id)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _StudentProfileTab extends ConsumerWidget {
  const _StudentProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final statsAsync = ref.watch(studentStatsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const ThemeToggleButton(),
            ],
          ),
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
                      gradient: const LinearGradient(colors: AppColors.tealGradient),
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
                        Text(session?.fullname ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
          const Text('Statistika', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          statsAsync.when(
            loading: () => const SkeletonList(itemCount: 1, padding: EdgeInsets.zero),
            error: (_, _) => const SizedBox.shrink(),
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Bajarilgan testlar',
                    value: '${stats.completedCount}',
                    color: AppColors.primary,
                    icon: Icons.task_alt_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatTile(
                    label: 'O\'rtacha baho',
                    value: stats.completedCount == 0 ? '—' : stats.averageGrade.toStringAsFixed(1),
                    color: AppColors.secondary,
                    icon: Icons.stars_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : palette.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : palette.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
