import 'package:flutter/material.dart';

/// App theme configuration with liquid glass aesthetic and design tokens
class AppTheme {
  // Base color palette
  static const Color primaryGreen = Color(0xFF38E07B); // Robin Hood Green
  static const Color primaryGreenDark = Color(0xFF2EC36A);
  static const Color secondaryGreen = Color(0xFF10B981);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningYellow = Color(0xFFFACC15);
  static const Color infoBlue = Color(0xFFA8C5FF);
  static const Color backgroundLight = Color(0xFFF7FAFC);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color backgroundElevated = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFD1D5DB);
  static const Color overlay = Color(0x26FFFFFF);

  // Status colors (lighter palette)
  static const Color statusGreenLight = Color(0xFF6EE7B7); // A lighter, minty green
  static const Color statusYellowLight = Color(0xFFFDE047); // A softer, sunnier yellow
  static const Color statusRedLight = Color(0xFFFCA5A5); // A gentle, coral red

  // Spacing scale (in logical pixels)
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double space2XL = 48;
  static const double space3XL = 64;

  // Radius scale
  static const double radiusSM = 12;
  static const double radiusMD = 16;
  static const double radiusLG = 24;
  static const double radiusXL = 32;

  // Breakpoints (mobile-first but documented for responsive layouts)
  static const double breakpointSmall = 320;
  static const double breakpointStandard = 375;
  static const double breakpointLarge = 428;

  // Blur configuration for glass components
  static const double glassBlurSigma = 20;
  static const double glassOpacity = 0.72;
  static const double glassBorderOpacity = 0.18;
  static const double glassShadowOpacity = 0.12;

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: backgroundElevated,
        background: backgroundLight,
        onPrimary: textDark,
        onSecondary: Colors.white,
        onSurface: textDark,
        onBackground: textDark,
      ),
      useMaterial3: true,
      fontFamily: 'Spline Sans',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -2,
          height: 0.9,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 18,
          color: textMedium,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 16,
          color: textMedium,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 14,
          color: textLight,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: primaryGreen, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: warningYellow),
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Spline Sans',
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Spline Sans',
          color: textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLG),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Spline Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: backgroundElevated,
          foregroundColor: textDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLG),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Spline Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(
            fontFamily: 'Spline Sans',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        color: backgroundElevated,
        margin: const EdgeInsets.all(0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Spline Sans',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textMedium,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearMinHeight: 12,
      ),
      scaffoldBackgroundColor: backgroundLight,
    );
  }

  /// Base shadow used across components to achieve liquid glass depth
  static List<BoxShadow> get glassShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(glassShadowOpacity),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.18),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// Clean glass decoration that can be safely layered on top of content
  static BoxDecoration glassDecoration({double? opacity}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radiusLG),
      color: backgroundElevated.withOpacity(
        (opacity ?? glassOpacity).clamp(0.1, 1.0),
      ),
      border: Border.all(
        color: Colors.white.withOpacity(glassBorderOpacity),
        width: 1,
      ),
      boxShadow: glassShadow,
    );
  }

  /// Backwards compatible accessor retained for existing tests/components
  static BoxDecoration get liquidGlassDecoration => glassDecoration();

  /// Primary button style
  static ButtonStyle get primaryButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4AE896), // Lighter, brighter green
      foregroundColor: textDark,
      elevation: 8,
      shadowColor: primaryGreen.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLG),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Spline Sans',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Secondary button style
  static ButtonStyle get secondaryButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE5E7EB),
      foregroundColor: textDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLG),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Spline Sans',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Success button style (for POWER+ mode, etc.)
  static ButtonStyle get successButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: secondaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLG),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Spline Sans',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Outlined button style for glass surfaces
  static ButtonStyle get outlineButtonStyle {
    return OutlinedButton.styleFrom(
      foregroundColor: textDark,
      backgroundColor: backgroundElevated.withOpacity(0.4),
      side: BorderSide(color: Colors.white.withOpacity(0.4)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLG),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontFamily: 'Spline Sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  /// Gradient helper for large surfaces
  static LinearGradient get primaryBackgroundGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundLight,
          backgroundLight,
          overlay,
        ],
      );

  /// Gradient helper for highlight overlays
  static RadialGradient get highlightRadialGradient => RadialGradient(
        colors: [
          primaryGreen.withOpacity(0.16),
          Colors.transparent,
        ],
        radius: 0.9,
      );
}
