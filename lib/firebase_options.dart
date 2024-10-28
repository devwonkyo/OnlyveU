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
    apiKey: 'AIzaSyCvgUbmgevlnhpNHZpTnKFc1sapo4YN1cE',
    appId: '1:733176085534:web:1caf47e33e7190a40a420f',
    messagingSenderId: '733176085534',
    projectId: 'onlyveyou-c8f73',
    authDomain: 'onlyveyou-c8f73.firebaseapp.com',
    storageBucket: 'onlyveyou-c8f73.appspot.com',
    measurementId: 'G-EX26JNPR3N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALbfpkhJUN9BjLse4j5OjZlff_TkRsAXc',
    appId: '1:733176085534:android:059c2c0b6fb90feb0a420f',
    messagingSenderId: '733176085534',
    projectId: 'onlyveyou-c8f73',
    storageBucket: 'onlyveyou-c8f73.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7v4tdm_bCJJ3tG_P5eVvfCByMG8HWqeM',
    appId: '1:733176085534:ios:ed4898ba692ee2360a420f',
    messagingSenderId: '733176085534',
    projectId: 'onlyveyou-c8f73',
    storageBucket: 'onlyveyou-c8f73.appspot.com',
    iosBundleId: 'com.example.onlyveyou',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC7v4tdm_bCJJ3tG_P5eVvfCByMG8HWqeM',
    appId: '1:733176085534:ios:ed4898ba692ee2360a420f',
    messagingSenderId: '733176085534',
    projectId: 'onlyveyou-c8f73',
    storageBucket: 'onlyveyou-c8f73.appspot.com',
    iosBundleId: 'com.example.onlyveyou',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCvgUbmgevlnhpNHZpTnKFc1sapo4YN1cE',
    appId: '1:733176085534:web:3650bb20fe14ab7e0a420f',
    messagingSenderId: '733176085534',
    projectId: 'onlyveyou-c8f73',
    authDomain: 'onlyveyou-c8f73.firebaseapp.com',
    storageBucket: 'onlyveyou-c8f73.appspot.com',
    measurementId: 'G-SGTNX9HDR3',
  );
}
