import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'riverpod_setting.dart';

class AuthFunctions {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Method to check if the user is logged in
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  Future<UserCredential> signInWithGoogle(WidgetRef ref) async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com',
    });

    // Once signed in, return the UserCredential
    UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
    // Update login state
    ref.read(authStateProvider.notifier).state = true;
    return userCredential;

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  Future<void> signOut(WidgetRef ref) async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    // Update login state
    ref.read(authStateProvider.notifier).state = false;
  }
}


