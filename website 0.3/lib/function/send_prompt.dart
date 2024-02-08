import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendMessageToFirestore(String uid, String text) async {
  // Access the 'users' collection
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // Access the user's document using the uid
  DocumentReference userDocRef = usersRef.doc(uid);

  // Access the 'discussions' collection inside the user's document
  CollectionReference discussionsRef = userDocRef.collection('discussions');

  // Check if "연습용토론계정" document already exists
  DocumentSnapshot practiceDiscussionDoc = await discussionsRef.doc('연습용토론계정').get();

  if (!practiceDiscussionDoc.exists) {
    // Create "연습용토론계정" document if it doesn't exist
    await discussionsRef.doc('연습용토론계정').set({
      // Add fields if needed
    });
  }

  // Get the reference to "연습용토론계정" document
  DocumentReference practiceDiscussionRef = discussionsRef.doc('연습용토론계정');

  // Access the 'messages' collection inside the "연습용토론계정" document
  CollectionReference messagesRef = practiceDiscussionRef.collection('messages');

  // Add a new message document to the 'messages' collection with auto-generated ID
  DocumentReference newMessageRef = await messagesRef.add({
    'prompt': text,
    // Add other fields if needed
  });

  print('Message sent to Firestore!');
  print('Discussion ID: 연습용토론계정');
  print('Message ID: ${newMessageRef.id}');
}


