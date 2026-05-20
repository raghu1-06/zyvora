import 'package:flutter/material.dart';

/// Premium Zyvora Design System - Centralized Theme Management
class ZyvoraDesignSystem {
  /// **COLOR SYSTEM** - Premium Dark Theme
  static const Color backgroundPrimary = Color(0xFF0D0D0D);
  static const Color backgroundSecondary = Color(0xFF151515);
  static const Color surfaceCard = Color(0xFF1E1E1E);
  static const Color surfaceAlt = Color(0xFF272727);

  static const Color accentBlue = Color(0xFF5B8CFF);
  static const Color accentPurple = Color(0xFF8A5CFF);
  static const Color accentGreen = Color(0xFF3CCF91);
  static const Color accentOrange = Color(0xFFFFB84D);
  static const Color accentRed = Color(0xFFFF5C5C);
  static const Color accentPink = Color(0xFFFF6B9D);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  static const Color divider = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF333333);

  /// **SPACING SYSTEM** - Consistent 4-8 scale
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;

  /// **BORDER RADIUS SYSTEM** - Clean rounded corners
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusCircular = 99.0;

  /// **ELEVATION/SHADOWS** - Subtle depth
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  /// **TYPOGRAPHY SCALE**
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  static const double fontSizeXS = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 28.0;
  static const double fontSize4XL = 32.0;

  static const double lineHeightSmall = 1.3;
  static const double lineHeightBase = 1.5;
  static const double lineHeightLarge = 1.6;

  /// **ANIMATION DURATIONS**
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationBase = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  static const Curve curveSmooth = Curves.easeInOutCubic;
  static const Curve curveQuick = Curves.easeOutCubic;
  static const Curve curveSoft = Curves.easeInOutQuad;
}

/// **PREMIUM MATERIAL THEME** - Complete ThemeData
class ZyvoraTheme {
  static ThemeData buildDarkTheme([BuildContext? context]) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ZyvoraDesignSystem.backgroundPrimary,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: ZyvoraDesignSystem.accentBlue,
        secondary: ZyvoraDesignSystem.accentPurple,
        tertiary: ZyvoraDesignSystem.accentGreen,
        surface: ZyvoraDesignSystem.backgroundPrimary,
        surfaceContainer: ZyvoraDesignSystem.surfaceCard,
        surfaceContainerHighest: ZyvoraDesignSystem.surfaceAlt,
        error: ZyvoraDesignSystem.accentRed,
        outline: ZyvoraDesignSystem.border,
        outlineVariant: ZyvoraDesignSystem.divider,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: ZyvoraDesignSystem.backgroundPrimary,
        foregroundColor: ZyvoraDesignSystem.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeLarge,
          fontWeight: ZyvoraDesignSystem.weightSemiBold,
          color: ZyvoraDesignSystem.textPrimary,
          fontFamily: 'Inter',
        ),
      ),

      // Bottom App Bar Theme
      bottomAppBarTheme: BottomAppBarThemeData(
        color: ZyvoraDesignSystem.backgroundSecondary,
        elevation: 0,
        height: 68,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: ZyvoraDesignSystem.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusLarge),
          side: const BorderSide(color: ZyvoraDesignSystem.border, width: 1),
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZyvoraDesignSystem.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          borderSide: const BorderSide(
            color: ZyvoraDesignSystem.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          borderSide: const BorderSide(
            color: ZyvoraDesignSystem.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          borderSide: const BorderSide(
            color: ZyvoraDesignSystem.accentBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          borderSide: const BorderSide(
            color: ZyvoraDesignSystem.accentRed,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ZyvoraDesignSystem.spacing16,
          vertical: ZyvoraDesignSystem.spacing12,
        ),
        labelStyle: const TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeSmall,
          fontWeight: ZyvoraDesignSystem.weightMedium,
          color: ZyvoraDesignSystem.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeSmall,
          color: ZyvoraDesignSystem.textTertiary,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZyvoraDesignSystem.accentBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: ZyvoraDesignSystem.spacing24,
            vertical: ZyvoraDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ZyvoraDesignSystem.radiusMedium,
            ),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: ZyvoraDesignSystem.fontSizeBase,
            fontWeight: ZyvoraDesignSystem.weightSemiBold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZyvoraDesignSystem.accentBlue,
          side: const BorderSide(
            color: ZyvoraDesignSystem.accentBlue,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ZyvoraDesignSystem.spacing24,
            vertical: ZyvoraDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ZyvoraDesignSystem.radiusMedium,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: ZyvoraDesignSystem.fontSizeBase,
            fontWeight: ZyvoraDesignSystem.weightSemiBold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZyvoraDesignSystem.accentBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: ZyvoraDesignSystem.spacing16,
            vertical: ZyvoraDesignSystem.spacing8,
          ),
          textStyle: const TextStyle(
            fontSize: ZyvoraDesignSystem.fontSizeBase,
            fontWeight: ZyvoraDesignSystem.weightMedium,
          ),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: ZyvoraDesignSystem.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusLarge),
          side: const BorderSide(color: ZyvoraDesignSystem.border, width: 1),
        ),
        contentTextStyle: const TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeBase,
          color: ZyvoraDesignSystem.textPrimary,
        ),
        titleTextStyle: const TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeLarge,
          fontWeight: ZyvoraDesignSystem.weightSemiBold,
          color: ZyvoraDesignSystem.textPrimary,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ZyvoraDesignSystem.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ZyvoraDesignSystem.radiusLarge),
            topRight: Radius.circular(ZyvoraDesignSystem.radiusLarge),
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: ZyvoraDesignSystem.divider,
        thickness: 0.5,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyvoraDesignSystem.accentBlue;
          }
          return ZyvoraDesignSystem.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyvoraDesignSystem.accentBlue.withValues(alpha: 0.3);
          }
          return ZyvoraDesignSystem.surfaceAlt;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyvoraDesignSystem.accentBlue;
          }
          return Colors.transparent;
        }),
        side: WidgetStateBorderSide.resolveWith((states) {
          return const BorderSide(
            color: ZyvoraDesignSystem.accentBlue,
            width: 2,
          );
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    const fontFamily = 'Inter';

    return TextTheme(
      // Display Styles
      displayLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSize4XL,
        fontWeight: ZyvoraDesignSystem.weightBold,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
      ),
      displayMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSize3XL,
        fontWeight: ZyvoraDesignSystem.weightBold,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
      ),
      displaySmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSize2XL,
        fontWeight: ZyvoraDesignSystem.weightBold,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
      ),

      // Headline Styles
      headlineLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSize2XL,
        fontWeight: ZyvoraDesignSystem.weightBold,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
      ),
      headlineMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeXL,
        fontWeight: ZyvoraDesignSystem.weightSemiBold,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      headlineSmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeLarge,
        fontWeight: ZyvoraDesignSystem.weightSemiBold,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),

      // Title Styles
      titleLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeLarge,
        fontWeight: ZyvoraDesignSystem.weightSemiBold,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      titleMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeBase,
        fontWeight: ZyvoraDesignSystem.weightSemiBold,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      titleSmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeSmall,
        fontWeight: ZyvoraDesignSystem.weightMedium,
        color: ZyvoraDesignSystem.textSecondary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),

      // Body Styles
      bodyLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeBase,
        fontWeight: ZyvoraDesignSystem.weightRegular,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      bodyMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeSmall,
        fontWeight: ZyvoraDesignSystem.weightRegular,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      bodySmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeXS,
        fontWeight: ZyvoraDesignSystem.weightRegular,
        color: ZyvoraDesignSystem.textSecondary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),

      // Label Styles
      labelLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeBase,
        fontWeight: ZyvoraDesignSystem.weightMedium,
        color: ZyvoraDesignSystem.textPrimary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
        letterSpacing: 0.5,
      ),
      labelMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeSmall,
        fontWeight: ZyvoraDesignSystem.weightMedium,
        color: ZyvoraDesignSystem.textSecondary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
        letterSpacing: 0.5,
      ),
      labelSmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeXS,
        fontWeight: ZyvoraDesignSystem.weightMedium,
        color: ZyvoraDesignSystem.textTertiary,
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Get gradient for cards
  static LinearGradient getCardGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ZyvoraDesignSystem.surfaceCard,
        ZyvoraDesignSystem.surfaceCard.withValues(alpha: 0.8),
      ],
    );
  }

  /// Get shadow for elevated elements
  static List<BoxShadow> getElevatedShadow({
    double elevation = ZyvoraDesignSystem.elevationMedium,
  }) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  /// Get subtle border decoration
  static BoxDecoration getCardDecoration({
    bool withGradient = false,
    double radius = ZyvoraDesignSystem.radiusLarge,
    Color borderColor = ZyvoraDesignSystem.border,
  }) {
    return BoxDecoration(
      gradient: withGradient ? getCardGradient() : null,
      color: !withGradient ? ZyvoraDesignSystem.surfaceCard : null,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
    );
  }

  /// Light theme builder for support
  static ThemeData buildLightTheme([BuildContext? context]) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F8F8),

      colorScheme: ColorScheme.light(
        primary: ZyvoraDesignSystem.accentBlue,
        secondary: ZyvoraDesignSystem.accentPurple,
        tertiary: ZyvoraDesignSystem.accentGreen,
        surface: const Color(0xFFF8F8F8),
        surfaceContainer: Colors.white,
        surfaceContainerHighest: const Color(0xFFEEEEEE),
        error: ZyvoraDesignSystem.accentRed,
        outline: const Color(0xFFDDDDDD),
        outlineVariant: const Color(0xFFF0F0F0),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeLarge,
          fontWeight: ZyvoraDesignSystem.weightSemiBold,
          color: Color(0xFF1A1A1A),
          fontFamily: 'Inter',
        ),
      ),

      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Colors.white,
        elevation: 0,
        height: 68,
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusLarge),
          side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),

      textTheme: _buildLightTextTheme(),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          borderSide: const BorderSide(
            color: ZyvoraDesignSystem.accentBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusMedium),
          borderSide: const BorderSide(
            color: ZyvoraDesignSystem.accentRed,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ZyvoraDesignSystem.spacing16,
          vertical: ZyvoraDesignSystem.spacing12,
        ),
        labelStyle: const TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeSmall,
          fontWeight: ZyvoraDesignSystem.weightMedium,
          color: Color(0xFF666666),
        ),
        hintStyle: const TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeSmall,
          color: Color(0xFF999999),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZyvoraDesignSystem.accentBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: ZyvoraDesignSystem.spacing24,
            vertical: ZyvoraDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ZyvoraDesignSystem.radiusMedium,
            ),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: ZyvoraDesignSystem.fontSizeBase,
            fontWeight: ZyvoraDesignSystem.weightSemiBold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZyvoraDesignSystem.accentBlue,
          side: const BorderSide(
            color: ZyvoraDesignSystem.accentBlue,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ZyvoraDesignSystem.spacing24,
            vertical: ZyvoraDesignSystem.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ZyvoraDesignSystem.radiusMedium,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: ZyvoraDesignSystem.fontSizeBase,
            fontWeight: ZyvoraDesignSystem.weightSemiBold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZyvoraDesignSystem.accentBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: ZyvoraDesignSystem.spacing16,
            vertical: ZyvoraDesignSystem.spacing8,
          ),
          textStyle: const TextStyle(
            fontSize: ZyvoraDesignSystem.fontSizeBase,
            fontWeight: ZyvoraDesignSystem.weightMedium,
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZyvoraDesignSystem.radiusLarge),
          side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        contentTextStyle: const TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeBase,
          color: Color(0xFF1A1A1A),
        ),
        titleTextStyle: const TextStyle(
          fontSize: ZyvoraDesignSystem.fontSizeLarge,
          fontWeight: ZyvoraDesignSystem.weightSemiBold,
          color: Color(0xFF1A1A1A),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ZyvoraDesignSystem.radiusLarge),
            topRight: Radius.circular(ZyvoraDesignSystem.radiusLarge),
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 0.5,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyvoraDesignSystem.accentBlue;
          }
          return const Color(0xFFCCCCCC);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyvoraDesignSystem.accentBlue.withValues(alpha: 0.3);
          }
          return const Color(0xFFDDDDDD);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ZyvoraDesignSystem.accentBlue;
          }
          return Colors.transparent;
        }),
        side: WidgetStateBorderSide.resolveWith((states) {
          return const BorderSide(
            color: ZyvoraDesignSystem.accentBlue,
            width: 2,
          );
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  static TextTheme _buildLightTextTheme() {
    const fontFamily = 'Inter';

    return TextTheme(
      displayLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSize4XL,
        fontWeight: ZyvoraDesignSystem.weightBold,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
      ),
      displayMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSize3XL,
        fontWeight: ZyvoraDesignSystem.weightBold,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
      ),
      displaySmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSize2XL,
        fontWeight: ZyvoraDesignSystem.weightBold,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
      ),

      headlineLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSize2XL,
        fontWeight: ZyvoraDesignSystem.weightBold,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
      ),
      headlineMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeXL,
        fontWeight: ZyvoraDesignSystem.weightSemiBold,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      headlineSmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeLarge,
        fontWeight: ZyvoraDesignSystem.weightSemiBold,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),

      titleLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeLarge,
        fontWeight: ZyvoraDesignSystem.weightSemiBold,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      titleMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeBase,
        fontWeight: ZyvoraDesignSystem.weightSemiBold,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      titleSmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeSmall,
        fontWeight: ZyvoraDesignSystem.weightMedium,
        color: Color(0xFF666666),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),

      bodyLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeBase,
        fontWeight: ZyvoraDesignSystem.weightRegular,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      bodyMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeSmall,
        fontWeight: ZyvoraDesignSystem.weightRegular,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),
      bodySmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeXS,
        fontWeight: ZyvoraDesignSystem.weightRegular,
        color: Color(0xFF666666),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightBase,
      ),

      labelLarge: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeBase,
        fontWeight: ZyvoraDesignSystem.weightMedium,
        color: Color(0xFF1A1A1A),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
        letterSpacing: 0.5,
      ),
      labelMedium: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeSmall,
        fontWeight: ZyvoraDesignSystem.weightMedium,
        color: Color(0xFF666666),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
        letterSpacing: 0.5,
      ),
      labelSmall: const TextStyle(
        fontSize: ZyvoraDesignSystem.fontSizeXS,
        fontWeight: ZyvoraDesignSystem.weightMedium,
        color: Color(0xFF999999),
        fontFamily: fontFamily,
        height: ZyvoraDesignSystem.lineHeightSmall,
        letterSpacing: 0.5,
      ),
    );
  }
}
