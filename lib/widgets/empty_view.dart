import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'blob_backdrop.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyView({super.key, required this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlobBackdrop(
              size: 120,
              colors: const [AppColors.primary, AppColors.secondary, AppColors.optionYellow],
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: palette.surfaceAlt, shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: palette.textTertiary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
