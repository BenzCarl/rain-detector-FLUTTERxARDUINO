import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Notification callbacks
  static Function(Map<String, dynamic>)? onRainDetected;
  static Function(Map<String, dynamic>)? onRainStopped;
  static Function(Map<String, dynamic>)? onClothesMovedInside;
  static Function(Map<String, dynamic>)? onClothesMovedOutside;
  static Function(Map<String, dynamic>)? onAutoModeToggled;

  // Initialize notifications
  static Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification}');
          _handleNotification(message.data);
        }
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
        _handleNotification(message.data);
      });

      // Handle terminated app notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('Got a message from terminated state!');
        _handleNotification(initialMessage.data);
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Handle notification based on type
  static void _handleNotification(Map<String, dynamic> data) {
    final notificationType = data['type'] ?? '';

    debugPrint('Handling notification type: $notificationType');

    switch (notificationType) {
      case 'rain_detected':
        onRainDetected?.call(data);
        break;
      case 'rain_stopped':
        onRainStopped?.call(data);
        break;
      case 'clothes_moved_inside':
        onClothesMovedInside?.call(data);
        break;
      case 'clothes_moved_outside':
        onClothesMovedOutside?.call(data);
        break;
      case 'auto_mode_toggled':
        onAutoModeToggled?.call(data);
        break;
      default:
        debugPrint('Unknown notification type: $notificationType');
    }
  }

  // Get FCM token
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
}
