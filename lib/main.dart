import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:io' show Platform;
import 'package:roomix/firebase_options.dart' as firebase_options;
import 'package:roomix/providers/auth_provider.dart';
import 'package:roomix/providers/notification_provider.dart';
import 'package:roomix/providers/user_preferences_provider.dart';
import 'package:roomix/screens/splash_screen.dart';
import 'package:roomix/services/api_service.dart';
import 'package:roomix/services/notification_service.dart';
import 'package:roomix/providers/utility_provider.dart';
import 'package:roomix/providers/map_provider.dart';
import 'package:roomix/utils/smooth_navigation.dart';
import 'package:roomix/services/platform_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: firebase_options.DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue even if Firebase fails to initialize
    // (allows app to work without Firebase)
  }
  
  // Initialize API Service
  try {
    ApiService.initialize();
  } catch (e) {
    debugPrint('API Service initialization error: $e');
  }
  
  // Initialize Notification Service (Mobile only)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('Notification Service initialization error: $e');
    }
  }
  
  // Set system UI overlay style (Mobile only)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A1931),
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    } catch (e) {
      debugPrint('System UI style setup error: $e');
    }
  }
  
  // Log platform info for debugging
  try {
    PlatformService.logPlatformInfo();
  } catch (e) {
    debugPrint('Platform service error: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
        ChangeNotifierProvider(create: (_) => UtilityProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: const RoomixApp(),
    ),
  );
}

class RoomixApp extends StatelessWidget {
  const RoomixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomix',
      theme: _buildDarkTheme(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      // Dark theme configuration
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B5CF6), // Electric Purple
        brightness: Brightness.dark,
        primary: const Color(0xFF8B5CF6), // Electric Purple
        secondary: const Color(0xFFF59E0B), // Energetic Orange
        tertiary: const Color(0xFFEC4899), // Hot Pink
        surface: const Color(0xFF1E293B),
        background: const Color(0xFF0F172A),
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
      // Global page transition theme for smooth navigation
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const FadeScalePageTransitionsBuilder(),
          TargetPlatform.iOS: const FadeScalePageTransitionsBuilder(),
        },
      ),
      // Dark theme text theme with better contrast
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B5CF6), // Purple accent
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE2E8F0), // Light gray
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCBD5E1), // Lighter gray
        ),
      ),
      // Elevated button theme with gradient
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF8B5CF6).withOpacity(0.4),
        ),
      ),
      // Card theme with glassmorphism
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        color: const Color(0xFF1E293B).withOpacity(0.9),
      ),
      // AppBar theme with dark mode support
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
        ),
        iconTheme: IconThemeData(color: Color(0xFF8B5CF6)),
      ),
      // Input decoration theme for text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B).withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF8B5CF6),
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
