import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REEMPLAZAR_WEB_API_KEY',
    appId: 'REEMPLAZAR_WEB_APP_ID',
    messagingSenderId: 'REEMPLAZAR_SENDER_ID',
    projectId: 'barberia-app',
    authDomain: 'barberia-app.firebaseapp.com',
    storageBucket: 'barberia-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REEMPLAZAR_ANDROID_API_KEY',
    appId: 'REEMPLAZAR_ANDROID_APP_ID',
    messagingSenderId: 'REEMPLAZAR_SENDER_ID',
    projectId: 'barberia-app',
    storageBucket: 'barberia-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REEMPLAZAR_IOS_API_KEY',
    appId: 'REEMPLAZAR_IOS_APP_ID',
    messagingSenderId: 'REEMPLAZAR_SENDER_ID',
    projectId: 'barberia-app',
    iosBundleId: 'com.barberia.barberiaApp',
    storageBucket: 'barberia-app.appspot.com',
  );
}
