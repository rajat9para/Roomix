import 'package:flutter/material.dart';

class AppColors {
  // Bold, Vibrant Premium Theme
  // Primary Colors - Electric Purple & Energetic Orange
  static const Color primary = Color(0xFF8B5CF6); // Electric Purple
  static const Color primaryColor = Color(0xFF8B5CF6); // Alias for primary
  static const Color secondary = Color(0xFFF59E0B); // Energetic Orange
  static const Color accent = Color(0xFF10B981); // Fresh Green
  static const Color primaryAccent = Color(0xFF10B981); // Alias for accent
  static const Color tertiary = Color(0xFFEC4899); // Hot Pink
  static const Color primaryDark = Color(0xFF5B21B6); // Deep Purple
  
  // Glassmorphism Colors
  static const Color glassWhite = Color(0xE6FFFFFF); // 90% white
  static const Color glassDark = Color(0x33000000); // 20% black
  static const Color glassPurple = Color(0x1A8B5CF6); // 10% purple
  
  // Text Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFFAEB7C8);
  static const Color textPrimary = Color(0xFF1E293B);
  
  // Background Colors
  static const Color background = Color(0xFF0F172A); // Deep dark background
  static const Color darkBackground = Color(0xFF0F172A); // Alias for background
  static const Color surface = Color(0xFF1E293B); // Slightly lighter surface
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color scaffoldDark = Color(0xFF0F172A);
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Fresh Green
  static const Color warning = Color(0xFFF59E0B); // Energetic Orange
  static const Color error = Color(0xFFEF4444);
  static const Color errorRed = Color(0xFFEF4444); // Alias for error
  static const Color info = Color(0xFF06B6D4);
  
  // Vibrant Accent Colors
  static const Color vibrantPurple = Color(0xFF8B5CF6); // Electric Purple
  static const Color vibrantOrange = Color(0xFFF59E0B); // Energetic Orange
  static const Color vibrantGreen = Color(0xFF10B981); // Fresh Green
  static const Color vibrantPink = Color(0xFFEC4899); // Hot Pink
  
  // Border Colors
  static const Color border = Color(0xFF334155);
  static const Color borderLight = Color(0xFF475569);
  static const Color shadow = Color(0x33000000);
  
  // Role Colors
  static const Color student = Color(0xFF06B6D4); // Cyan
  static const Color owner = Color(0xFF10B981); // Fresh Green
  static const Color admin = Color(0xFFF59E0B); // Energetic Orange

  // Bold Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Purple to Pink
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEC4899)], // Orange to Pink
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)], // Green to Cyan
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFF59E0B), Color(0xFFEC4899)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
  );

  // Glass Effect BoxDecoration
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.95),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.4),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 25,
        offset: const Offset(0, 15),
      ),
    ],
  );

  static BoxDecoration get glassDarkDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.08),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.15),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 25,
        offset: const Offset(0, 15),
      ),
    ],
  );

  // Premium 3D-Style Decoration with Gradient & Shadow
  static BoxDecoration get premium3DDecoration => BoxDecoration(
    gradient: premiumGradient,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF8B5CF6).withOpacity(0.4),
        blurRadius: 30,
        offset: const Offset(0, 20),
      ),
      BoxShadow(
        color: const Color(0xFFEC4899).withOpacity(0.2),
        blurRadius: 40,
        offset: const Offset(10, 10),
      ),
    ],
  );

  // Vibrant Card Decoration
  static BoxDecoration get vibrantCardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: const Color(0xFF8B5CF6).withOpacity(0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF8B5CF6).withOpacity(0.25),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // Elevated 3D Card Decoration
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: const Color(0xFF1E293B),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: const Color(0xFF8B5CF6).withOpacity(0.15),
        blurRadius: 30,
        offset: const Offset(0, 20),
      ),
    ],
  );
}
