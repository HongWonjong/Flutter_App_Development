import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AuthFunctions {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static Future<void> signInWithGoogle(WidgetRef ref) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 사용자가 로그인을 취소한 경우

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google 로그인 오류: $e');
      // 오류 처리 로직을 추가하세요 (예: 사용자에게 알림을 표시하거나 다른 조치를 취함)
    }
  }
  Future<void> signOut(WidgetRef ref) async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    // Update login state

  }
}







