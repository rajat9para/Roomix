import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:roomix/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  RemoteMessage? _lastNotification;
  List<RemoteMessage> _notificationHistory = [];

  RemoteMessage? get lastNotification => _lastNotification;
  List<RemoteMessage> get notificationHistory => _notificationHistory;

  NotificationProvider() {
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    _notificationService.onMessageReceived = (message) {
      _lastNotification = message;
      _notificationHistory.insert(0, message);
      notifyListeners();
    };

    _notificationService.onMessageOpenedApp = (message) {
      _lastNotification = message;
      notifyListeners();
    };
  }

  /// Subscribe to a notification topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
    notifyListeners();
  }

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
    notifyListeners();
  }

  /// Clear notification history
  void clearHistory() {
    _notificationHistory.clear();
    _lastNotification = null;
    notifyListeners();
  }

  /// Clear a specific notification
  void clearNotification(RemoteMessage message) {
    _notificationHistory.remove(message);
    if (_lastNotification == message) {
      _lastNotification = null;
    }
    notifyListeners();
  }

  /// Get unread notification count
  int getUnreadCount() {
    return _notificationHistory.length;
  }
}
