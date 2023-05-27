import 'package:flutter/material.dart';
import 'package:sexy_chess/waiting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NicknameSettingScreen extends StatefulWidget {
  final User? user;

  const NicknameSettingScreen({Key? key, this.user}) : super(key: key);

  @override
  _NicknameSettingScreenState createState() => _NicknameSettingScreenState();
}

class _NicknameSettingScreenState extends State<NicknameSettingScreen> {
  final TextEditingController nicknameController = TextEditingController();

  void handleNicknameSubmit() {
    final String nickname = nicknameController.text.trim();

    // Check if the nickname is empty
    if (nickname.isEmpty) {
      // Show an error message or handle the case when the nickname is empty
      return;
    }

    // Set the nickname, email, and UID in Firebase
    try {
      final user = widget.user;
      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        userRef.get().then((snapshot) {
          if (snapshot.exists) {
            // Update the existing document
            userRef.update({
              'displayName': nickname,
              'email': user.email,
              'uid': user.uid,
            }).then((_) {
              // Navigate to the WaitingScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WaitingScreen(user: user),
                ),
              );
            }).catchError((error) {
              // Show an error message or handle the error when setting the nickname, email, and UID
            });
          } else {
            // Create a new document
            userRef.set({
              'displayName': nickname,
              'email': user.email,
              'uid': user.uid,
            }).then((_) {
              // Navigate to the WaitingScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WaitingScreen(user: user),
                ),
              );
            }).catchError((error) {
              // Show an error message or handle the error when setting the nickname, email, and UID
            });
          }
        }).catchError((error) {
          // Show an error message or handle the error when getting the document
        });
      }
    } catch (e) {
      // Show an error message or handle the error when setting the nickname, email, and UID
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              ),
            ),
            TextField(
              controller: nicknameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '닉네임',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[700],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleNicknameSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '닉네임 설정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
