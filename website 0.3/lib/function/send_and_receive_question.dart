import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendMessageToFirestore(String uid, String text) async {
  CollectionReference discussions = FirebaseFirestore.instance.collection('users').doc(uid).collection('discussions');

  // Add a new discussion document to the 'discussions' collection with auto-generated ID
  DocumentReference newDiscussionRef = await discussions.add({
    // Add fields if needed
  });

  // Get the auto-generated ID of the new discussion
  String discussionId = newDiscussionRef.id;

  // Access the 'messages' collection inside the new discussion
  CollectionReference messagesRef = newDiscussionRef.collection('messages');

  // Add a new message document to the 'messages' collection with auto-generated ID
  DocumentReference newMessageRef = await messagesRef.add({
    'prompt': text,
    // Add other fields if needed
  });

  print('Message sent to Firestore!');
  print('Discussion ID: $discussionId');
  print('Message ID: ${newMessageRef.id}');
}
