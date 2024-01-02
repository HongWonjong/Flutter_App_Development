// user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  Future<void> addUserToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('user').doc(user.uid);

      await userDoc.set({
        'user_auth': false,
        'user_email': user.email,
        'user_reliability': 0,
      });
    }
    else {
      print('유저 정보 추가 안됨');
    }
    }
}
