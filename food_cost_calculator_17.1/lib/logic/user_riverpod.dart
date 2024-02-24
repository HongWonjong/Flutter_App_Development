import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final uidProvider = Provider<String>((ref) {
  String myuid = FirebaseAuth.instance.currentUser!.uid;
  return myuid;
}); // 유저의 uid를 가져와야 할 때


final userEmailProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['email'] ?? '';
    });
  } else {
    // 로그인되지 않은 경우, null 반환
    return Stream.value("");
  }
});

final userDisplayNameProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['userDisplayName'] ?? '';
    });
  } else {
    // 로그인되지 않은 경우, null 반환
    return Stream.value("");
  }
});

// 회원가입할 때 자동으로 이메일과 displayname을 저장하고, 먼저 가입한 사용자들의 경우 추후에 등록이 되도록 해야 함.