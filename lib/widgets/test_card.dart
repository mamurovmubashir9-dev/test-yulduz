import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/test_model.dart';
import 'pressable_card.dart';

class TestCard extends StatelessWidget {
  final TestModel test;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const TestCard({super.key, required this.test, this.onTap, this.actions});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return PressableCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.quiz_rounded, color: AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(test.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: palette.textTertiary),
            ],
          ),
          if (test.description.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              test.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
          ],
          if (actions != null) ...[
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
          ],
        ],
      ),
    );
  }
}
