import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:website/style/language.dart';

Future<void> sendGeminiPromptToFirestore(String uid, String text) async {
  // Access the 'users' collection
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // Access the user's document using the uid
  DocumentReference userDocRef = usersRef.doc(uid);

  // Check if user has enough GeminiPoints
  DocumentSnapshot userDoc = await userDocRef.get();
  int geminiPoints = userDoc['GeminiPoint'] ?? 0;

  if (geminiPoints <= 0) {
    print('포인트가 부족합니다.');
    return;
  }

  // Access the 'discussions' collection inside the user's document
  CollectionReference discussionsRef = userDocRef.collection('discussions');

  // Check if "GeminiPro" document already exists
  DocumentSnapshot practiceDiscussionDoc = await discussionsRef.doc(FunctionLan.geminiDoc).get();

  if (!practiceDiscussionDoc.exists) {
    // Create "GeminiPro" document if it doesn't exist
    await discussionsRef.doc(FunctionLan.geminiDoc).set({
      // Add fields if needed
    });
  }

  // Get the reference to "GeminiPro" document
  DocumentReference practiceDiscussionRef = discussionsRef.doc(FunctionLan.geminiDoc);

  // Access the 'messages' collection inside the "GeminiPro" document
  CollectionReference messagesRef = practiceDiscussionRef.collection('messages');

  // Add a new message document to the 'messages' collection with auto-generated ID
  await messagesRef.add({
    'prompt': text,
    // Add other fields if needed
  });

// Update GeminiPoints in the user's document
  await userDocRef.update({'GeminiPoint': FieldValue.increment(-1)});



  print('Message sent to Firestore!');
  print('Discussion ID: GeminiPro');
}

Future<void> sendGPT35PromptToFirestore(String uid, String text) async {
  // Access the 'users' collection
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // Access the user's document using the uid
  DocumentReference userDocRef = usersRef.doc(uid);

  // Check if user has enough GeminiPoints
  DocumentSnapshot userDoc = await userDocRef.get();
  int geminiPoints = userDoc['GeminiPoint'] ?? 0;

  if (geminiPoints < 2) {
    print('포인트가 부족합니다.');
    return;
  }

  // Access the 'discussions' collection inside the user's document
  CollectionReference discussionsRef = userDocRef.collection('discussions');

  // Check if "GPT35" document already exists
  DocumentSnapshot gpt35DiscussionDoc = await discussionsRef.doc(FunctionLan.gpt35Doc).get();

  if (!gpt35DiscussionDoc.exists) {
    // Create "GPT35" document if it doesn't exist
    await discussionsRef.doc(FunctionLan.gpt35Doc).set({
      // Add fields if needed
    });
  }

  // Get the reference to "GPT35" document
  DocumentReference gpt35DiscussionRef = discussionsRef.doc(FunctionLan.gpt35Doc);

  // Access the 'messages' collection inside the "GPT35" document
  CollectionReference messagesRef = gpt35DiscussionRef.collection('messages');

  // Add a new message document to the 'messages' collection with auto-generated ID
  await messagesRef.add({
    'gpt35_prompt': text,
    // Add other fields if needed
  });

  // Update GeminiPoints in the user's document
  await userDocRef.update({'GeminiPoint': FieldValue.increment(-2)});

  print('GPT 3.5 Prompt sent to Firestore!');
  print('Discussion ID: GPT35');
}

Future<void> sendGPT4PromptToFirestore(String uid, String text) async {
  // Access the 'users' collection
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // Access the user's document using the uid
  DocumentReference userDocRef = usersRef.doc(uid);

  // Check if user has enough GeminiPoints
  DocumentSnapshot userDoc = await userDocRef.get();
  int geminiPoints = userDoc['GeminiPoint'] ?? 0;

  if (geminiPoints < 5) {
    print('포인트가 부족합니다.');
    return;
  }

  // Access the 'discussions' collection inside the user's document
  CollectionReference discussionsRef = userDocRef.collection('discussions');

  // Check if "GPT35" document already exists
  DocumentSnapshot gpt35DiscussionDoc = await discussionsRef.doc(FunctionLan.gpt4Doc).get();

  if (!gpt35DiscussionDoc.exists) {
    // Create "GPT35" document if it doesn't exist
    await discussionsRef.doc(FunctionLan.gpt4Doc).set({
      // Add fields if needed
    });
  }

  // Get the reference to "GPT35" document
  DocumentReference gpt35DiscussionRef = discussionsRef.doc(FunctionLan.gpt4Doc);

  // Access the 'messages' collection inside the "GPT35" document
  CollectionReference messagesRef = gpt35DiscussionRef.collection('messages');

  // Add a new message document to the 'messages' collection with auto-generated ID
  await messagesRef.add({
    'gpt4_prompt': text,
    // Add other fields if needed
  });

  // Update GeminiPoints in the user's document
  await userDocRef.update({'GeminiPoint': FieldValue.increment(-4)});

  print('GPT 4 Prompt sent to Firestore!');
  print('Discussion ID: GPT4');
}


