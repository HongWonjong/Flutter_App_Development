import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authService = Provider((ref) => AuthService(ref.read));

class AuthService {
  final Reader _read;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService(this._read);

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
        _read(loggedInUserProvider).state = user;
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
      _read(loggedInUserProvider).state = null;
    } catch (error) {
      // 로그아웃 실패 처리
    }
  }
}

