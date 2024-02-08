import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignInProvider = StreamProvider<bool>((ref) async* {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

  yield googleUser != null;

  await for (final _ in _googleSignIn.onCurrentUserChanged) {
    yield _googleSignIn.currentUser != null;
  }
});


final userEmailProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['email'] ?? '';
    });
  } else {
    // 로그인되지 않은 경우, null 반환
    return Stream.value(null);
  }
});

final userGPProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['GeminiPoint'] ?? '';
    });
  } else {
    // 로그인되지 않은 경우, null 반환
    return Stream.value(null);
  }
});
