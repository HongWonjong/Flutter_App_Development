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


final userEmailProvider = StreamProvider<String>((ref) {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Firestore에서 해당 UID의 사용자 정보 가져오기 (실시간 업데이트를 위해 snap 상태 반환)
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
    // 사용자 정보에서 GeminiPoint 가져오기
    return snapshot.data()?['email'] ?? '';
  });
});

final userGPProvider = StreamProvider<String>((ref) {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Firestore에서 해당 UID의 사용자 정보 가져오기 (실시간 업데이트를 위해 snap 상태 반환)
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
    // 사용자 정보에서 GeminiPoint 가져오기
    return snapshot.data()?['GeminiPoint'] ?? '';
  });
});
