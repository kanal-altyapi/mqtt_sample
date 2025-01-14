// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAaMFFrpGwt-575QlKok0S32XOS-VMQ-E',
    appId: '1:399821163985:web:cf000aab98c019cb5e64f0',
    messagingSenderId: '399821163985',
    projectId: 'mozaik-mobilemessaging-tst',
    authDomain: 'mozaik-mobilemessaging-tst.firebaseapp.com',
    storageBucket: 'mozaik-mobilemessaging-tst.appspot.com',
    measurementId: 'G-2T7HVJ952W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBM28Dc1Tg45IOBc4RJ-KIXZFNRbEusM18',
    appId: '1:399821163985:android:391fd38ffb30e7fb5e64f0',
    messagingSenderId: '399821163985',
    projectId: 'mozaik-mobilemessaging-tst',
    storageBucket: 'mozaik-mobilemessaging-tst.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9HGTAHlyYw-N91aBh0H67dPMdytY0mc4',
    appId: '1:399821163985:ios:a2cbfb8b4002112f5e64f0',
    messagingSenderId: '399821163985',
    projectId: 'mozaik-mobilemessaging-tst',
    storageBucket: 'mozaik-mobilemessaging-tst.appspot.com',
    iosClientId: '399821163985-mh13stsg4mkle5b3cn8aslude619qoap.apps.googleusercontent.com',
    iosBundleId: 'com.mozaik.mobilemessaging.tst',
  );
}
