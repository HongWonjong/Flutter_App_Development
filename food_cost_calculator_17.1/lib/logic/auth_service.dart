import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:food_cost_calculator_3_0/main.dart';

class AuthService {
  final ProviderRef<AuthService> _ref;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService(this._ref);

  static Future<void> signInWithGoogle() async {
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

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      // 로그아웃 처리
      _ref.read(loggedInUserProvider.notifier).state = null;
    } catch (error) {
      // 로그아웃 실패 처리
      rethrow;
    }
  }
}







