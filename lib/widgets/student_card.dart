import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/student.dart';
import 'pressable_card.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final Widget? trailing;
  final ValueChanged<bool>? onSelectChanged;
  final bool? selected;

  const StudentCard({
    super.key,
    required this.student,
    this.trailing,
    this.onSelectChanged,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isSelected = selected ?? false;

    return PressableCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: onSelectChanged == null ? null : () => onSelectChanged!(!isSelected),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              student.fullname.isNotEmpty ? student.fullname[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullname, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text('@${student.username}', style: TextStyle(color: palette.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (onSelectChanged != null)
            Checkbox(value: isSelected, onChanged: (v) => onSelectChanged!(v ?? false)),
          ?trailing,
        ],
      ),
    );
  }
}
