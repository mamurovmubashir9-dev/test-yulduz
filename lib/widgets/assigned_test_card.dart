import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../models/assigned_test_info.dart';
import '../models/student_test.dart';
import '../providers/student_providers.dart';
import 'grade_badge.dart';
import 'pressable_card.dart';

class AssignedTestCard extends ConsumerWidget {
  final AssignedTestInfo info;
  final VoidCallback onTap;

  const AssignedTestCard({super.key, required this.info, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final isCompleted = info.studentTest.status == StudentTestStatus.completed;
    final gradeAsync = isCompleted
        ? ref.watch(studentTestGradeProvider((info.studentTest.studentId, info.test.id)))
        : null;

    return PressableCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isCompleted ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.assignment_outlined,
              color: isCompleted ? AppColors.secondary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.test.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? 'Bajarilgan' : 'Ishlashingiz kerak',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (isCompleted) ...[
            gradeAsync!.when(
              data: (grade) =>
                  grade == null ? const SizedBox.shrink() : GradeBadge(gradeLabel: grade.grade.toString()),
              loading: () => const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_right_rounded, color: palette.textTertiary),
        ],
      ),
    );
  }
}
