import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/router.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'barberia_high_importance',
    'Barbería Notificaciones',
    description: 'Canal principal de notificaciones de la app.',
    importance: Importance.high,
  );

  Future<void> initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTapNotification,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<String?> getToken() async {
    return _firebaseMessaging.getToken();
  }

  Future<void> showForegroundNotification(RemoteMessage message) async {
    await _handleForegroundMessage(message);
  }

  void openFromNotification(RemoteMessage message) {
    _navigateFromMessage(message, push: true);
  }

  Future<void> openInitialNotification(RemoteMessage? message) async {
    if (message == null) {
      return;
    }
    _navigateFromMessage(message, push: true);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final route = _routeFromMessage(message);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'barberia_high_importance',
          'Barbería Notificaciones',
          channelDescription: 'Canal principal de notificaciones de la app.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: route,
    );
  }

  void _navigateFromMessage(RemoteMessage message, {bool push = false}) {
    final route = _routeFromMessage(message);
    if (route == null || route.isEmpty) {
      return;
    }

    final router = _ref.read(routerProvider);
    scheduleMicrotask(() {
      if (push) {
        router.push(route);
      } else {
        router.go(route);
      }
    });
  }

  void _onTapNotification(NotificationResponse response) {
    final route = response.payload;
    if (route == null || route.isEmpty) {
      return;
    }

    final router = _ref.read(routerProvider);
    router.push(route);
  }

  String? _routeFromMessage(RemoteMessage message) {
    final data = message.data;
    final explicitRoute = (data['ruta'] ?? data['route']) as String?;
    if (explicitRoute != null && explicitRoute.isNotEmpty) {
      return explicitRoute;
    }

    final citaId = data['citaId'] as String?;
    if (citaId != null && citaId.isNotEmpty) {
      return '/mis-citas/$citaId';
    }

    return null;
  }
}
