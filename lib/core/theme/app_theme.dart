import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/zyvora_design_system.dart';

/// Light-first design system for Zyvora.
class ZyvoraColors {
  ZyvoraColors._();

  static const background = Color(0xFFF6F7FB);
  static const backgroundSecondary = Color(0xFFEFF2FA);
  static const card = Color(0xFFFFFFFF);
  static const cardMuted = Color(0xFFF4F6FC);

  static const primary = Color(0xFF6C4DFF);
  static const secondary = Color(0xFF5B8CFF);
  static const accentBlue = secondary;
  static const accentPurple = primary;
  static const success = Color(0xFF3CCF91);
  static const warning = Color(0xFFFFB84D);
  static const error = Color(0xFFFF5C5C);

  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const borderLight = Color(0xFFE3E7F0);

  static const bgLight = background;
  static const surfaceLight = card;
  static const surfaceSoftLight = cardMuted;
  static const textLight = textPrimary;
  static const textSecondaryLight = textSecondary;

  static const bgDark = Color(0xFF0F1117);
  static const surfaceDark = Color(0xFF171A23);
  static const surfaceSoftDark = Color(0xFF202432);
  static const textDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFFAAB2C5);
  static const borderDark = Color(0xFF2B3040);

  static const primarySoft = Color(0xFFEDE9FF);
  static const coral = warning;
  static const coralSoft = Color(0xFFFFF2DF);
  static const green = success;
  static const greenSoft = Color(0xFFE9FBF4);
  static const red = error;
  static const redSoft = Color(0xFFFFECEC);
  static const blue = secondary;
  static const blueSoft = Color(0xFFEAF1FF);
  static const purple = primary;
  static const purpleSoft = Color(0xFFF0ECFF);
  static const yellow = warning;
  static const yellowSoft = Color(0xFFFFF5E2);
  static const cyan = Color(0xFF19B6D2);
  static const cyanSoft = Color(0xFFE7F9FC);
  static const muted = textSecondary;
  static const orange = warning;
  static const orangeLight = Color(0xFFFFD080);
  static const orangeSoft = coralSoft;
}

class ZyvoraRadius {
  ZyvoraRadius._();

  static const double sm = 8;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double hero = 28;
}

class ZyvoraMotion {
  ZyvoraMotion._();

  static const fast = Duration(milliseconds: 160);
  static const regular = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);
  static const curve = Curves.easeOutCubic;
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color primaryText, Color secondaryText) {
    TextStyle inter({
      required double size,
      required FontWeight weight,
      required Color color,
      double height = 1.3,
    }) {
      return GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: 0,
      );
    }

    return TextTheme(
      headlineLarge: inter(
        size: 34,
        weight: FontWeight.w800,
        color: primaryText,
        height: 1.12,
      ),
      headlineMedium: inter(
        size: 28,
        weight: FontWeight.w800,
        color: primaryText,
        height: 1.16,
      ),
      headlineSmall: inter(
        size: 24,
        weight: FontWeight.w700,
        color: primaryText,
      ),
      titleLarge: inter(size: 20, weight: FontWeight.w700, color: primaryText),
      titleMedium: inter(size: 16, weight: FontWeight.w700, color: primaryText),
      titleSmall: inter(size: 14, weight: FontWeight.w700, color: primaryText),
      bodyLarge: inter(
        size: 16,
        weight: FontWeight.w500,
        color: secondaryText,
        height: 1.45,
      ),
      bodyMedium: inter(
        size: 14,
        weight: FontWeight.w500,
        color: secondaryText,
        height: 1.4,
      ),
      bodySmall: inter(
        size: 12,
        weight: FontWeight.w500,
        color: secondaryText,
        height: 1.35,
      ),
      labelLarge: inter(size: 14, weight: FontWeight.w700, color: primaryText),
      labelMedium: inter(
        size: 12,
        weight: FontWeight.w700,
        color: secondaryText,
      ),
      labelSmall: inter(
        size: 11,
        weight: FontWeight.w600,
        color: secondaryText,
      ),
    );
  }

  static ThemeData light() => ZyvoraTheme.buildLightTheme();

  static ThemeData dark() => ZyvoraTheme.buildDarkTheme();

  static ThemeData _theme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceSoft,
    required Color text,
    required Color secondaryText,
    required Color border,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: ZyvoraColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: ZyvoraColors.primary,
          onPrimary: Colors.white,
          secondary: ZyvoraColors.secondary,
          onSecondary: Colors.white,
          tertiary: ZyvoraColors.success,
          error: ZyvoraColors.error,
          onError: Colors.white,
          surface: surface,
          onSurface: text,
          outline: border,
          surfaceContainerHighest: surfaceSoft,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme,
      textTheme: _textTheme(text, secondaryText),
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.xl),
          side: BorderSide(
            color: border.withValues(alpha: isDark ? 0.55 : 0.9),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSoft,
        labelStyle: TextStyle(color: secondaryText),
        hintStyle: TextStyle(color: secondaryText.withValues(alpha: 0.72)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
          borderSide: BorderSide(color: border.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
          borderSide: const BorderSide(color: ZyvoraColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
          borderSide: const BorderSide(color: ZyvoraColors.error, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ZyvoraColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.hero),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ZyvoraColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZyvoraColors.primary,
          side: BorderSide(color: border.withValues(alpha: 0.8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZyvoraColors.primary,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? ZyvoraColors.surfaceSoftDark : text,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        dragHandleColor: secondaryText.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSoft,
        selectedColor: ZyvoraColors.primary.withValues(
          alpha: isDark ? 0.28 : 0.12,
        ),
        side: BorderSide(color: border.withValues(alpha: 0.65)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.md),
        ),
        labelStyle: GoogleFonts.inter(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      dividerTheme: DividerThemeData(color: border.withValues(alpha: 0.72)),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraRadius.xl),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyvoraColors.primary;
          }
          return secondaryText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyvoraColors.primary.withValues(alpha: isDark ? 0.42 : 0.24);
          }
          return border.withValues(alpha: 0.82);
        }),
      ),
    );
  }
}
