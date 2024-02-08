import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserDataUpload {


  Future<void> addUserToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.set({
        'userUid': user.uid,
        'email': user.email,
        "GeminiPoint": 10,
      });
    }
    else {
      print('유저 정보 추가 안됨');
    }
  }

  Future<void> checkAndAddDefaultUserData() async { //// 유저가 처음 가입할 때, 기본적인 유저 정보를 데이터베이스에 세팅합니다.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // 유저 정보가 데이터베이스에 없으면 추가
        await UserDataUpload().addUserToFirestore();
      }
    }
  }
}
