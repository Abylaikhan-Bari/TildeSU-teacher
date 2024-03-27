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
    apiKey: 'AIzaSyCspjGTiiyGEvBkO_koBj_H_vcvrLS9Gi8',
    appId: '1:37665738009:web:707a5abd1d9c4b3e188988',
    messagingSenderId: '37665738009',
    projectId: 'tildesu-9a77e',
    authDomain: 'tildesu-9a77e.firebaseapp.com',
    databaseURL: 'https://tildesu-9a77e-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tildesu-9a77e.appspot.com',
    measurementId: 'G-DDQSE091YB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfRkDazTmEadd1rcwIOHypAAzuM0R5Bmo',
    appId: '1:37665738009:android:7551559f89c74562188988',
    messagingSenderId: '37665738009',
    projectId: 'tildesu-9a77e',
    databaseURL: 'https://tildesu-9a77e-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tildesu-9a77e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBe6y0WIWsNr_d9n5OidaAnopiNP96lDP0',
    appId: '1:37665738009:ios:e49a6c9479f2fbe3188988',
    messagingSenderId: '37665738009',
    projectId: 'tildesu-9a77e',
    databaseURL: 'https://tildesu-9a77e-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tildesu-9a77e.appspot.com',
    iosBundleId: 'com.ashimbari.tildesuTeacher',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBe6y0WIWsNr_d9n5OidaAnopiNP96lDP0',
    appId: '1:37665738009:ios:8688e48d44777369188988',
    messagingSenderId: '37665738009',
    projectId: 'tildesu-9a77e',
    databaseURL: 'https://tildesu-9a77e-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'tildesu-9a77e.appspot.com',
    iosBundleId: 'com.ashimbari.tildesuTeacher.RunnerTests',
  );
}