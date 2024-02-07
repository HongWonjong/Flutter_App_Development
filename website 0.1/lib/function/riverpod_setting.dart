import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final uidProvider = Provider<String>((ref) {
  String myuid = FirebaseAuth.instance.currentUser!.uid;
  return myuid;
}); // 유저의 uid를 가져와야 할 때

final userEmailProvider = FutureProvider.autoDispose<String>((ref) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Firestore에서 해당 UID의 사용자 정보 가져오기
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

  // 사용자 정보에서 이메일 가져오기
  final userEmail = userDoc.data()?['email'] ?? ''; // 예외 처리를 통한 안전한 접근

  return userEmail;

});

final userGPProvider = StreamProvider<String>((ref) {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Firestore에서 해당 UID의 사용자 정보 가져오기 (실시간 업데이트를 위해 snap 상태 반환)
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
    // 사용자 정보에서 GeminiPoint 가져오기
    return snapshot.data()?['GeminiPoint'] ?? '';
  });
});
