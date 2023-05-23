import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'loading_donut.dart';
import 'waiting_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isLoading = false;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error occurred using Google Sign-In: $e');
    }

    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.disconnect(); // 이전 크레덴셜 제거
      await googleSignIn.signOut();
    } catch (e) {
      print('Error occurred during sign out: $e');
    }
  }

  void handleSignIn() {
    setState(() {
      isLoading = true;
    });

    signInWithGoogle().then((userCredential) {
      if (userCredential != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WaitingScreen(user: userCredential.user),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void handleSignOut() {
    signOut().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '로그인 페이지',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                onPressed: isLoading ? null : handleSignIn, // 버튼 비활성화 처리
                icon: Image.asset(
                  'assets/images/google_icon.png',
                  width: 24,
                  height: 24,
                ),
                label: const Text(
                  '구글 로그인',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: LoadingDonut(),
              ),
            const SizedBox(height: 20),
            if (!isLoading)
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: handleSignOut, // 로그아웃 버튼 클릭 시 로그아웃 처리
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}














