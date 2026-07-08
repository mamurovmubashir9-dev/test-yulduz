import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand hues — identical in both themes; only neutrals shift between
/// light/dark via [AppPalette].
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4B3AC4);

  static const Color secondary = Color(0xFF00C48C);
  static const Color danger = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFB020);

  // Answer-option accent set (A/B/C/D), also used for quick-action tiles.
  static const Color optionRed = Color(0xFFFF6B6B);
  static const Color optionBlue = Color(0xFF4A90E2);
  static const Color optionYellow = Color(0xFFFFB020);
  static const Color optionPurple = Color(0xFF9C6ADE);

  static const List<Color> primaryGradient = [Color(0xFF7C5CFC), Color(0xFF5B3FD4)];
  static const List<Color> tealGradient = [Color(0xFF22C58B), Color(0xFF10A374)];
  static const List<Color> slateGradient = [Color(0xFF3B3E63), Color(0xFF23253F)];
}

/// Theme-aware neutrals (background/surface/text/border/shadow) that swap
/// between light and dark mode. Brand colors in [AppColors] stay constant.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color primaryTint;
  final Color secondaryTint;
  final Color dangerTint;
  final Color warningTint;
  final List<BoxShadow> cardShadow;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.primaryTint,
    required this.secondaryTint,
    required this.dangerTint,
    required this.warningTint,
    required this.cardShadow,
  });

  static const light = AppPalette(
    background: Color(0xFFF7F6FC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF3F1FB),
    textPrimary: Color(0xFF1A1F36),
    textSecondary: Color(0xFF8A8CA5),
    textTertiary: Color(0xFFB7B9CE),
    border: Color(0xFFEBE9F7),
    primaryTint: Color(0xFFEFEBFF),
    secondaryTint: Color(0xFFDFF9EE),
    dangerTint: Color(0xFFFDE9E8),
    warningTint: Color(0xFFFFF4E0),
    cardShadow: [BoxShadow(color: Color(0x0F6C5CE7), blurRadius: 24, offset: Offset(0, 8))],
  );

  static const dark = AppPalette(
    background: Color(0xFF121325),
    surface: Color(0xFF1C1E38),
    surfaceAlt: Color(0xFF262a4c),
    textPrimary: Color(0xFFF2F2FA),
    textSecondary: Color(0xFFA9ABCE),
    textTertiary: Color(0xFF71749E),
    border: Color(0xFF33355C),
    primaryTint: Color(0xFF2C2A57),
    secondaryTint: Color(0xFF163B34),
    dangerTint: Color(0xFF402232),
    warningTint: Color(0xFF3E3018),
    cardShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10))],
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? primaryTint,
    Color? secondaryTint,
    Color? dangerTint,
    Color? warningTint,
    List<BoxShadow>? cardShadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      primaryTint: primaryTint ?? this.primaryTint,
      secondaryTint: secondaryTint ?? this.secondaryTint,
      dangerTint: dangerTint ?? this.dangerTint,
      warningTint: warningTint ?? this.warningTint,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      secondaryTint: Color.lerp(secondaryTint, other.secondaryTint, t)!,
      dangerTint: Color.lerp(dangerTint, other.dangerTint, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light, AppPalette.light);

  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.danger,
        surface: palette.surface,
      ),
      scaffoldBackgroundColor: palette.background,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
        labelStyle: TextStyle(color: palette.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: palette.border, width: 1.4),
          foregroundColor: palette.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primaryTint,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primary : palette.textSecondary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.textPrimary,
        contentTextStyle: TextStyle(color: palette.surface, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: palette.border, space: 1, thickness: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
    );
  }
}
