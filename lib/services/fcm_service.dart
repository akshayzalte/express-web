import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/glass_container.dart';

class FCMService extends GetxService {
  late final FirebaseMessaging _fcm;
  final fcmToken = ''.obs;

  Future<void> initFirebase() async {
    try {
      // Initialize Firebase App
      // In production, the developer will bundle google-services.json / GoogleService-Info.plist.
      // We log the Firebase Sender ID configured.
      const senderId = '665210843897';
      debugPrint('Initializing Firebase Messaging with Sender ID: $senderId');

      await Firebase.initializeApp();
      _fcm = FirebaseMessaging.instance;

      
      // Request notifications permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted push notification permission.');
        
        // Get token
        final token = await _fcm.getToken();
        if (token != null) {
          fcmToken.value = token;
          debugPrint('FCM Token: $token');
        }

        // Listen for foreground notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Received foreground notification: ${message.notification?.title}');
          _showInAppBanner(
            message.notification?.title ?? 'Notification',
            message.notification?.body ?? '',
          );
        });
      }
    } catch (e) {
      debugPrint('Firebase not initialized. Running FCMService in Mock Mode: $e');
    }
  }

  void simulatePushNotification(String title, String message) {
    _showInAppBanner(title, message);
  }

  void _showInAppBanner(String title, String body) {
    // Show a beautiful glassmorphic toast notification banner at the top of the screen
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
      ),
      messageText: Text(
        body,
        style: const TextStyle(color: Color(0xFF0A2342)),
      ),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16.0),
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 300),
      // Custom glassmorphic decoration
      message: body,
      icon: const Icon(Icons.notifications_active, color: Color(0xFF1D9E75)),
      shouldIconPulse: true,
      onTap: (_) {},
      overlayColor: Colors.black12,
      borderRadius: 20,
      borderWidth: 1.0,
      borderColor: Colors.white.withOpacity(0.3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}
