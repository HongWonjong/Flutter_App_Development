// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// Firebase 설정 정보를 담은 객체
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAm_w7ZauWUmgHyVlwYxr5-hJBdwLBy6P8",
    authDomain: "merongcatchmind.firebaseapp.com",
    projectId: "merongcatchmind",
    storageBucket: "merongcatchmind.appspot.com",
    messagingSenderId: "426832924426",
    appId: "1:426832924426:web:1a5665a1e6ba52019cf4f3",
  );
}
