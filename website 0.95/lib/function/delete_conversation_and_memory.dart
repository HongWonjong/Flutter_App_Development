import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteDiscussionMessages(String uid, String docId) async { // 그냥 대화 내역
  CollectionReference messagesRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('discussions').doc('GPT35_VTuber').collection('messages');
  QuerySnapshot querySnapshot = await messagesRef.get();

  for (var doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
}
Future<void> deleteProcessedResponses(String uid) async { // 장기기억
  CollectionReference responsesRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('processed_responses');
  QuerySnapshot querySnapshot = await responsesRef.get();

  for (var doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
}
