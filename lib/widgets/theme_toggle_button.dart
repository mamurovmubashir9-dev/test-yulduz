import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';

/// Compact icon button that flips between light and dark mode, matching the
/// filled circular icon buttons already used in the dashboard headers.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: context.palette.surface,
        foregroundColor: context.palette.textPrimary,
      ),
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
      icon: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
      tooltip: 'Mavzuni almashtirish',
    );
  }
}
