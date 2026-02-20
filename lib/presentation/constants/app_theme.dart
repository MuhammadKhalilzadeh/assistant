import 'dart:ui';

import 'package:flutter/material.dart';

/// Ember Dark — Premium warm dark theme for the Jarvis AI Assistant
///
/// Design Philosophy:
/// 1. Depth Through Darkness — Layered dark surfaces create hierarchy
/// 2. Warm Presence — Orange and amber accents create an inviting, energetic feel
/// 3. Contained Color — Color used surgically for status, actions, and data
/// 4. Breathing Space — Generous spacing; content floats in dark canvas
/// 5. Subtle Motion — Glow pulses, shimmer loading, smooth transitions
class AppTheme {
  // Primary Color Palette — Ember Orange
  static const Color primaryColor = Color(0xFFFF7A2F); // Ember Orange
  static const Color primaryDark = Color(0xFFE06515); // Deep Ember
  static const Color primaryLight = Color(0xFFFF9A5C); // Light Ember

  // Secondary Colors
  static const Color secondaryColor = Color(0xFFFF5500); // Burnt Orange
  static const Color accentColor = Color(0xFFFFB347); // Warm Amber

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF7A2F), // Ember Orange
      Color(0xFFFF5500), // Burnt Orange
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF26262C), // Card surface
      Color(0xFF242428), // Subtle variation
    ],
  );

  static const LinearGradient ambientGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1C1C20), // Surface depth
      Color(0xFF141416), // Background
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB347), // Warm Amber
      Color(0xFFFF7A2F), // Ember Orange
    ],
  );

  static RadialGradient get glowGradient => RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      );

  /// Bottom ambient glow — warm radial glow at screen bottom
  static RadialGradient bottomAmbientGlow({double opacity = 0.08}) =>
      RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.8,
        colors: [
          primaryColor.withValues(alpha: opacity),
          Colors.transparent,
        ],
      );

  // Neutral Colors — Layered Dark Surfaces (warm-shifted)
  static const Color backgroundColor = Color(0xFF141416); // Background (deepest)
  static const Color surfaceColor = Color(0xFF1C1C20); // Surface (elevated)
  static const Color cardColor = Color(0xFF26262C); // Card surface
  static const Color cardBorderColor = Color(0xFF3A3A44); // Visible border

  // Text Colors — Light on Dark (WCAG compliant, warm-shifted)
  static const Color textPrimary = Color(0xFFF2F0ED); // Primary text ~12.5:1
  static const Color textSecondary = Color(0xFFA8A4A0); // Secondary text ~5.8:1 AA
  static const Color textTertiary = Color(0xFF7A7774); // Hint/disabled ~3.2:1 AA large
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors — Universal UX
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF5B731); // Yellow-amber (distinct from orange primary)
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFFFF7A2F); // Matches primary

  // Divider & Border Colors
  static const Color dividerColor = Color(0xFF2E2E34);
  static const Color activeBorderColor = Color(0xFFFF7A2F);
  static Color get glassBorderColor => Colors.white.withValues(alpha: 0.12);

  // Overlay Colors
  static Color get overlayLight => Colors.white.withValues(alpha: 0.07);
  static Color get overlayMedium => Colors.white.withValues(alpha: 0.12);

  // Glow Colors
  static const Color primaryGlow = Color(0xFFFF7A2F);
  static const Color secondaryGlow = Color(0xFFFF5500);
  static const Color accentGlow = Color(0xFFFFB347);

  // Star Color
  static const Color starActive = Color(0xFFF5B731);

  // Food Category Colors (contextual, unchanged)
  static const Color foodGrains = Color(0xFFFFB74D);
  static const Color foodProtein = Color(0xFFFF6B6B);
  static const Color foodDairy = Color(0xFF42A5F5);
  static const Color foodFruits = Color(0xFF66BB6A);
  static const Color foodVegetables = Color(0xFF4CAF50);
  static const Color foodFats = Color(0xFFFFC107);
  static const Color foodSweets = Color(0xFFEC407A);
  static const Color foodBeverages = Color(0xFF8D6E63);
  static const Color foodOther = Color(0xFF78909C);

  // Chart Color Palette — ordered orange/amber sequence for data visualization
  static const List<Color> chartPalette = [
    Color(0xFFFF7A2F), // Orange (primary)
    Color(0xFFFFB347), // Amber (accent)
    Color(0xFFFF5500), // Burnt Orange (secondary)
    Color(0xFFF5B731), // Gold
    Color(0xFFFF9A5C), // Peach (primaryLight)
    Color(0xFFF2F0ED), // White (textPrimary)
  ];

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFF26262C);
  static const Color shimmerHighlight = Color(0xFF3A3A44);

  // Glow & Glass Tokens
  static const double glowRadius = 20.0;
  static const double glassBlurAmount = 10.0;
  static const double glassBorderWidth = 1.0;
  static const double activeBorderWidth = 1.5;

  // Shadows — Glow-Based for Dark Theme (reduced opacities for orange)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: Offset.zero,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: Offset.zero,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.20),
          blurRadius: 20,
          offset: Offset.zero,
        ),
      ];

  static List<BoxShadow> get neonGlow => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.30),
          blurRadius: 20,
          offset: Offset.zero,
        ),
        BoxShadow(
          color: secondaryColor.withValues(alpha: 0.15),
          blurRadius: 30,
          offset: Offset.zero,
        ),
      ];

  // Text Glow — for glowing numbers/values
  static List<Shadow> get textGlow => [
        Shadow(
          color: primaryColor.withValues(alpha: 0.60),
          blurRadius: 12,
        ),
      ];

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusCard = 16.0;
  static const double borderRadiusPill = 999.0; // Pill-shaped CTA buttons

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// Get the complete Material 3 dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusCard),
        ),
        color: cardColor,
        shadowColor: Colors.black.withValues(alpha: 0.30),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: cardBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: cardBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide:
              const BorderSide(color: activeBorderColor, width: activeBorderWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMD,
          vertical: spacingMD,
        ),
        hintStyle: const TextStyle(color: textTertiary),
        labelStyle: const TextStyle(color: textSecondary),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textSecondary,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundColor,

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadiusLarge),
          ),
        ),
      ),
    );
  }

  /// Helper method to create gradient container
  static Widget gradientContainer({
    required Widget child,
    Gradient? gradient,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusCard),
        boxShadow: boxShadow ?? cardShadow,
      ),
      child: child,
    );
  }

  /// Glassmorphism container with backdrop blur for dark theme
  static Widget glassmorphismContainer({
    required Widget child,
    double? borderRadius,
    Color? backgroundColor,
  }) {
    final radius = borderRadius ?? borderRadiusCard;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: glassBlurAmount,
          sigmaY: glassBlurAmount,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? cardColor).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: glassBorderColor,
              width: glassBorderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Elevated card decoration with dark surface and glow shadow
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadiusCard),
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: cardShadow,
      );

  /// Helper method to create elevated card container
  static Widget elevatedCard({
    required Widget child,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    Color? color,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusCard),
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: cardShadow,
      ),
      child: child,
    );
  }

  /// Card decoration with dark surface, border, and glow shadow
  static BoxDecoration cardDecoration({double? borderRadius}) => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusCard),
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: cardShadow,
      );

  /// Glow card decoration — card with orange border glow for interactive elements
  static BoxDecoration glowCardDecoration({double? borderRadius}) =>
      BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusCard),
        border: Border.all(color: activeBorderColor, width: activeBorderWidth),
        boxShadow: glowShadow,
      );

  /// Gradient card decoration — warm-tinted card surface
  static BoxDecoration gradientCardDecoration({double? borderRadius}) =>
      BoxDecoration(
        gradient: secondaryGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusCard),
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: cardShadow,
      );

  /// Gradient text effect via ShaderMask (orange-to-burnt-orange)
  static Widget gradientText({
    required Widget child,
    Gradient? gradient,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          (gradient ?? primaryGradient)
              .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: child,
    );
  }
}
