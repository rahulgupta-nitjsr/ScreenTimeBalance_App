import 'package:flutter/material.dart';

/// App theme configuration with liquid glass aesthetic
class AppTheme {
  // Color palette
  static const Color primaryGreen = Color(0xFF38E07B); // Robin Hood Green
  static const Color secondaryGreen = Color(0xFF10B981);
  static const Color backgroundLight = Color(0xFFF7FAFC);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: cardBackground,
        background: backgroundLight,
        onPrimary: textDark,
        onSecondary: Colors.white,
        onSurface: textDark,
        onBackground: textDark,
      ),
      
      // Material Design 3
      useMaterial3: true,
      
      // Typography
      fontFamily: 'Spline Sans',
      textTheme: const TextTheme(
        // Headlines
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
        
        // Body text
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
        
        // Labels
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
      
      // App bar theme
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
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Spline Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: cardBackground,
      ),
      
      // Bottom navigation bar theme
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
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: textMedium,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Clean card decoration without blur effects
  static BoxDecoration get liquidGlassDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: cardBackground,
      border: Border.all(
        color: Colors.grey.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Primary button style
  static ButtonStyle get primaryButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      foregroundColor: textDark,
      elevation: 8,
      shadowColor: primaryGreen.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
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
        borderRadius: BorderRadius.circular(28),
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
        borderRadius: BorderRadius.circular(28),
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
}
