// delete_functions.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> deleteMemo(String memoId) async {
  String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  await FirebaseFirestore.instance.collection('user').doc(uid).collection('memoes').doc(memoId).delete();
}
