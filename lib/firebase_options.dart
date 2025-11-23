import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAEKzg_pWlek4o37ApxU22lJjamevcjEl0',
    appId: '1:553776362728:web:008a6000fc26bd82e5c55d',
    messagingSenderId: '553776362728',
    projectId: 'clothes-remote-control',
    authDomain: 'clothes-remote-control.firebaseapp.com',
    databaseURL: 'https://clothes-remote-control-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'clothes-remote-control.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEKzg_pWlek4o37ApxU22lJjamevcjEl0',
    appId: '1:553776362728:android:008a6000fc26bd82e5c55d',
    messagingSenderId: '553776362728',
    projectId: 'clothes-remote-control',
    databaseURL: 'https://clothes-remote-control-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'clothes-remote-control.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAEKzg_pWlek4o37ApxU22lJjamevcjEl0',
    appId: '1:553776362728:ios:008a6000fc26bd82e5c55d',
    messagingSenderId: '553776362728',
    projectId: 'clothes-remote-control',
    databaseURL: 'https://clothes-remote-control-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'clothes-remote-control.firebasestorage.app',
    iosBundleId: 'com.example.clothesRemoteControl',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAEKzg_pWlek4o37ApxU22lJjamevcjEl0',
    appId: '1:553776362728:macos:008a6000fc26bd82e5c55d',
    messagingSenderId: '553776362728',
    projectId: 'clothes-remote-control',
    databaseURL: 'https://clothes-remote-control-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'clothes-remote-control.firebasestorage.app',
    iosBundleId: 'com.example.clothesRemoteControl',
  );
}
