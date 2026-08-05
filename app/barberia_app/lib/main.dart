import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/config/router.dart';
import 'core/services/notification_service.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Intl.defaultLocale = 'es_CO';
  await initializeDateFormatting('es_CO');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final container = ProviderContainer();
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.initLocalNotifications();

  FirebaseMessaging.onMessage.listen((message) {
    notificationService.showForegroundNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    notificationService.openFromNotification(message);
  });

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  await notificationService.openInitialNotification(initialMessage);

  Future<void> syncFcmTokenIfLoggedIn(String fcmToken) async {
    final authToken = await container.read(secureStorageProvider).getToken();
    if (authToken == null || authToken.isEmpty) {
      return;
    }
    try {
      await container
          .read(authRepositoryProvider)
          .actualizarTokenFCM(fcmToken);
    } catch (_) {
      // Best effort: notifications keep working with the old token until
      // the next successful sync (e.g. next login or refresh event).
    }
  }

  // Keep the backend's copy of the push token current across reinstalls
  // and token rotations, not just at the moment of login.
  FirebaseMessaging.instance.onTokenRefresh.listen(
    syncFcmTokenIfLoggedIn,
    onError: (Object e) => debugPrint('Error en onTokenRefresh de FCM: $e'),
  );

  // FCM token retrieval requires a real Firebase project config; until that's
  // set up this must not take the whole app down when it fails.
  unawaited(
    FirebaseMessaging.instance
        .getToken()
        .then((token) {
          if (token != null && token.isNotEmpty) {
            return syncFcmTokenIfLoggedIn(token);
          }
          return null;
        })
        .catchError((Object e) {
          debugPrint('No se pudo obtener el token FCM: $e');
        }),
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const BarberiaApp()),
  );
}

class BarberiaApp extends ConsumerWidget {
  const BarberiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Barbería App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
