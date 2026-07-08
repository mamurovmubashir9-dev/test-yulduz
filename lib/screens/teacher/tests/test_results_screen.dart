import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/student_test.dart';
import '../../../providers/teacher_providers.dart';
import '../../../widgets/async_value_widget.dart';
import '../../../widgets/empty_view.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/grade_badge.dart';
import '../../../widgets/skeleton_list.dart';

class TestResultsScreen extends ConsumerWidget {
  final int testId;

  const TestResultsScreen({super.key, required this.testId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(testResultsProvider(testId));

    return Scaffold(
      appBar: AppBar(title: const Text('Natijalar')),
      body: AsyncValueWidget(
        value: resultsAsync,
        onRetry: () => ref.invalidate(testResultsProvider(testId)),
        loading: () => const SkeletonList(),
        data: (results) {
          if (results.isEmpty) {
            return const EmptyView(
              message: 'Bu test hali hech kimga yuborilmagan',
              icon: Icons.bar_chart_rounded,
            );
          }

          final completed = results.where((r) => r.grade != null).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Bajarildi: $completed / ${results.length}',
                  style: TextStyle(color: context.palette.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final grade = result.grade;
                    final isCompleted = result.studentTest.status == StudentTestStatus.completed;
                    final palette = context.palette;

                    return FadeSlideIn(
                      index: index,
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            child: Text(
                              result.student.fullname.isNotEmpty
                                  ? result.student.fullname[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(result.student.fullname),
                          subtitle: Text(
                            isCompleted ? 'Bajarilgan' : 'Kutilmoqda',
                            style: TextStyle(color: palette.textSecondary),
                          ),
                          trailing: grade == null
                              ? Icon(Icons.hourglass_empty_rounded, color: palette.textSecondary)
                              : GradeBadge(gradeLabel: grade.grade.toString()),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
