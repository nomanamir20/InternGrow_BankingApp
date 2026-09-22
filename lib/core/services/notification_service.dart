import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // TODO: replace with your real VAPID key from Firebase Console.
  static const String _vapidKey = 'YOUR_VAPID_KEY_HERE';

  Future<void> initialize({
    required void Function(RemoteMessage message) onForegroundMessage,
  }) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission status: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen(onForegroundMessage);
  }

  Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        return await _messaging.getToken(vapidKey: _vapidKey);
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }
}