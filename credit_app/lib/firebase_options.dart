// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDv-r64_EjVbPbPh-Vnwow6LcNB7CZ956U',
    appId: '1:599160843228:web:95f6c7740679e3a7d4bd19',
    messagingSenderId: '599160843228',
    projectId: 'flutter-credit-card-app-14b14',
    authDomain: 'flutter-credit-card-app-14b14.firebaseapp.com',
    storageBucket: 'flutter-credit-card-app-14b14.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZau4f4JQcnBXbEKIxX8FTREGp1UYuiUk',
    appId: '1:599160843228:android:935f2ffed8e0d576d4bd19',
    messagingSenderId: '599160843228',
    projectId: 'flutter-credit-card-app-14b14',
    storageBucket: 'flutter-credit-card-app-14b14.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD44umsH0W1dswDYcRk4xUQIn10EP8vKtQ',
    appId: '1:599160843228:ios:4bac680df3401760d4bd19',
    messagingSenderId: '599160843228',
    projectId: 'flutter-credit-card-app-14b14',
    storageBucket: 'flutter-credit-card-app-14b14.firebasestorage.app',
    iosBundleId: 'com.example.creditApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD44umsH0W1dswDYcRk4xUQIn10EP8vKtQ',
    appId: '1:599160843228:ios:4bac680df3401760d4bd19',
    messagingSenderId: '599160843228',
    projectId: 'flutter-credit-card-app-14b14',
    storageBucket: 'flutter-credit-card-app-14b14.firebasestorage.app',
    iosBundleId: 'com.example.creditApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDv-r64_EjVbPbPh-Vnwow6LcNB7CZ956U',
    appId: '1:599160843228:web:78f5c7c9e1023675d4bd19',
    messagingSenderId: '599160843228',
    projectId: 'flutter-credit-card-app-14b14',
    authDomain: 'flutter-credit-card-app-14b14.firebaseapp.com',
    storageBucket: 'flutter-credit-card-app-14b14.firebasestorage.app',
  );

}