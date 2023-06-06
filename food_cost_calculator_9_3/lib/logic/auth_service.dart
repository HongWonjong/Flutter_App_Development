import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:food_cost_calculator_3_0/main.dart';

final authService = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final ProviderRef<AuthService> _ref;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService(this._ref);

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 로그인 처리 및 사용자 정보 가져오기
        _ref.read(loggedInUserProvider.notifier).state = user;  // Here
      } else {
        // 로그인 실패 처리
      }
    } catch (error) {
      // 로그인 실패 처리
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      // 로그아웃 처리
      _ref.read(loggedInUserProvider.notifier).state = null; // And here
    } catch (error) {
      // 로그아웃 실패 처리
    }
  }
}






