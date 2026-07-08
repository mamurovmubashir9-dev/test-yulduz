import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'routing/app_router.dart';

void main() {
  runApp(const ProviderScope(child: ImtixonIlovaApp()));
}
class ImtixonIlovaApp extends ConsumerWidget {
  const ImtixonIlovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'TestYulduz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final isWide = MediaQuery.sizeOf(context).width > 600;
        if (!isWide) return child;

        // Phone-first layouts look lost stretched across a desktop window,
        // so cap content at phone width and center it once here instead of
        // touching every screen.
        return ColoredBox(
          color: context.palette.background,
          child: Center(
            child: SizedBox(width: 460, child: child),
          ),
        );
      },
    );
  }
}
