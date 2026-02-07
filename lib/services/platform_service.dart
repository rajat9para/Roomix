import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for handling platform-specific operations (Web, Android, iOS)
class PlatformService {
  // ===== Platform Detection =====
  
  /// Check if running on web
  static bool get isWeb => kIsWeb;
  
  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Check if running on mobile (Android or iOS)
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  /// Check if running on desktop (Windows, macOS, Linux)
  static bool get isDesktop => !kIsWeb && 
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Get platform name
  static String get platformName {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  // ===== Feature Availability =====

  /// Check if notifications are supported on this platform
  static bool get supportsNotifications => !kIsWeb || _webNotificationsSupported();

  /// Check if geolocation is supported
  static bool get supportsGeolocation => 
      isWeb || isAndroid || isIOS;

  /// Check if file picker is supported
  static bool get supportsFilePicker => true;

  /// Check if camera is supported
  static bool get supportsCamera => !kIsWeb;

  /// Check if biometric auth is supported
  static bool get supportsBiometric => isAndroid || isIOS;

  // ===== Web-Specific Checks =====

  /// Check if browser supports push notifications
  static bool _webNotificationsSupported() {
    if (!kIsWeb) return false;
    // Check for notification API support
    try {
      return _checkNotificationSupport();
    } catch (e) {
      return false;
    }
  }

  /// Check browser API support (called via JS interop in actual app)
  static bool _checkNotificationSupport() {
    // This would typically use js interop to check:
    // - window.Notification !== undefined
    // - navigator.serviceWorker !== undefined
    // - 'serviceWorker' in navigator
    return true; // Simplified - implement with js package
  }

  // ===== Notification Methods =====

  /// Show notification using platform-appropriate method
  static Future<void> showNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? payload,
  }) async {
    if (isWeb) {
      _showWebNotification(title, body, imageUrl, payload);
    } else if (isAndroid || isIOS) {
      _showMobileNotification(title, body, imageUrl, payload);
    }
  }

  /// Platform-specific web notification display
  static void _showWebNotification(
    String title,
    String body,
    String? imageUrl,
    Map<String, String>? payload,
  ) {
    // Implement using flutter_local_notifications for web
    // or direct web notification API via js interop
    print('Web Notification: $title - $body');
  }

  /// Platform-specific mobile notification display
  static void _showMobileNotification(
    String title,
    String body,
    String? imageUrl,
    Map<String, String>? payload,
  ) {
    // Use flutter_local_notifications or firebase_messaging
    print('Mobile Notification: $title - $body');
  }

  // ===== Navigation Methods =====

  /// Perform platform-specific deep link navigation
  static Future<bool> handleDeepLink(String route) async {
    print('Handling deep link: $route');
    // Implement navigation logic for all platforms
    return true;
  }

  // ===== Storage Methods =====

  /// Get platform-specific storage path
  static String getStoragePath() {
    if (isWeb) {
      return 'indexeddb://roomix'; // IndexedDB path for web
    } else if (isAndroid) {
      return '/data/data/com.example.roomix/'; // Android app data
    } else if (isIOS) {
      return '/var/mobile/Containers/Data/Application/'; // iOS app data
    }
    return '/tmp/roomix/'; // Default temp path
  }

  // ===== Permission Methods =====

  /// Check and request required permissions
  static Future<Map<String, bool>> requestPermissions() async {
    final permissions = <String, bool>{};

    if (isWeb) {
      // Web permissions
      permissions['notification'] = await _requestWebNotificationPermission();
      permissions['geolocation'] = await _requestWebGeolocationPermission();
    } else if (isAndroid || isIOS) {
      // Mobile permissions would be handled by respective permission packages
      permissions['camera'] = false; // Implement with permission_handler
      permissions['location'] = false; // Implement with geolocator
      permissions['contacts'] = false; // Implement with permission_handler
    }

    return permissions;
  }

  /// Request web-specific notification permission
  static Future<bool> _requestWebNotificationPermission() async {
    // Use js interop to request Notification.requestPermission()
    return false;
  }

  /// Request web-specific geolocation permission
  static Future<bool> _requestWebGeolocationPermission() async {
    // Use js interop to request geolocation
    return false;
  }

  // ===== Environment/Version Info =====

  /// Get app environment (production, staging, development)
  static String getEnvironment() {
    const String env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    return env;
  }

  /// Get API base URL based on platform
  static String getApiBaseUrl() {
    const String url = String.fromEnvironment('BACKEND_API_URL', defaultValue: 'http://localhost:3000');
    return url;
  }

  /// Get Firebase project ID
  static String getFirebaseProjectId() {
    const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
    return projectId;
  }

  // ===== Web-specific Configuration =====

  /// Configure web-specific settings for Firebase
  static Map<String, String> getFirebaseWebConfig() {
    return {
      'apiKey': const String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
      'authDomain': const String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: ''),
      'projectId': const String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
      'storageBucket': const String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: ''),
      'messagingSenderId': const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
      'appId': const String.fromEnvironment('FIREBASE_APP_ID', defaultValue: ''),
    };
  }

  // ===== Utility Methods =====

  /// Log platform info for debugging
  static void logPlatformInfo() {
    print('=== Platform Information ===');
    print('Platform: $platformName');
    print('Is Web: $isWeb');
    print('Is Mobile: $isMobile');
    print('Is Desktop: $isDesktop');
    print('Environment: ${getEnvironment()}');
    print('API Base URL: ${getApiBaseUrl()}');
    print('============================');
  }
}
