import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_cost_calculator_3_0/logic/user_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthFunctions {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   Future<void> signInWithGoogle(WidgetRef ref) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

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
    ref.invalidate(authStateProvider);
    ref.invalidate(userEmailProvider);
    ref.invalidate(userDisplayNameProvider);
    // Update login state

  }

  Future<void> deleteUser(WidgetRef ref) async {
    try {
      // Get the current user
      User? user = _firebaseAuth.currentUser;
      // Delete the user document from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      print("User Firestore document deleted successfully.");


      // Delete the user
      await user?.delete();
      await _googleSignIn.disconnect();
      ref.invalidate(authStateProvider);
      ref.invalidate(userEmailProvider);
      ref.invalidate(userDisplayNameProvider);

      print("User deleted successfully.");
    } on FirebaseAuthException catch (e) {
      // Handle errors, for example, show an error message
      // You might need to handle specific errors, such as requiring the user to reauthenticate
      throw Exception("Error deleting user: ${e.message}");
    }
  }
}







