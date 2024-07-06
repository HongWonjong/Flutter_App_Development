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
      apiKey: "AIzaSyAxp_AFgrWCFtlpFod2Dm7y56IOqq3Dyok",
      authDomain: "k-socialscore-quiz.firebaseapp.com",
      projectId: "k-socialscore-quiz",
      storageBucket: "k-socialscore-quiz.appspot.com",
      messagingSenderId: "744632138577",
      appId: "1:744632138577:web:2b2bd41300eff721dcf170"
  );
}