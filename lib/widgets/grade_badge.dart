import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class GradeBadge extends StatelessWidget {
  final String gradeLabel;
  final double? percentage;

  const GradeBadge({super.key, required this.gradeLabel, this.percentage});

  Color get _color {
    switch (gradeLabel) {
      case '5':
        return AppColors.secondary;
      case '4':
        return AppColors.primary;
      case '3':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            gradeLabel,
            style: TextStyle(color: _color, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          if (percentage != null) ...[
            const SizedBox(width: 6),
            Text(
              '${percentage!.toStringAsFixed(0)}%',
              style: TextStyle(color: _color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
