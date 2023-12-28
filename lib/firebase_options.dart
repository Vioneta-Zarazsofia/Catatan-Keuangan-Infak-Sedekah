// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDLSSoJGlwT6uBsPiQjXIoyzM3EsL4Aspo',
    appId: '1:398872951874:web:df934447b36444618ac1db',
    messagingSenderId: '398872951874',
    projectId: 'catataninfakdansedekah-9ab0c',
    authDomain: 'catataninfakdansedekah-9ab0c.firebaseapp.com',
    storageBucket: 'catataninfakdansedekah-9ab0c.appspot.com',
    measurementId: 'G-YL9T5FWFC0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXT_xCHD5JJru5Nt3BVONO-cwueTWgrBs',
    appId: '1:398872951874:android:737d09d56a0588bf8ac1db',
    messagingSenderId: '398872951874',
    projectId: 'catataninfakdansedekah-9ab0c',
    storageBucket: 'catataninfakdansedekah-9ab0c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzkS1OxKnLF78SZgADaxH6_2wbXqzrrKA',
    appId: '1:398872951874:ios:814d29cde83bc6028ac1db',
    messagingSenderId: '398872951874',
    projectId: 'catataninfakdansedekah-9ab0c',
    storageBucket: 'catataninfakdansedekah-9ab0c.appspot.com',
    iosBundleId: 'com.example.catatanKeuangan',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzkS1OxKnLF78SZgADaxH6_2wbXqzrrKA',
    appId: '1:398872951874:ios:3beef1772f5070268ac1db',
    messagingSenderId: '398872951874',
    projectId: 'catataninfakdansedekah-9ab0c',
    storageBucket: 'catataninfakdansedekah-9ab0c.appspot.com',
    iosBundleId: 'com.example.catatanKeuangan.RunnerTests',
  );
}
