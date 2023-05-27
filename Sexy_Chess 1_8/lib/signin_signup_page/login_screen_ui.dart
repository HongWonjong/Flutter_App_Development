import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:sexy_chess/waiting_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithEmailPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        final docSnapshot = await userRef.get();
        if (!docSnapshot.exists) {
          await userRef.set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
          });
        }

        // Add this part to get the appToken
         var appToken = await fetchAppCheckToken();

        // Navigate to the WaitingScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WaitingScreen(user: userCredential.user, appToken: appToken),
          ),
        );

        return userCredential;
      }

      return null;
    } catch (e) {
      if (e is FirebaseAuthException) {
        // the rest of your existing code...
      } else {
        print('Error occurred using Email/Password Sign-In: $e');
      }
      return null;
    }
  }
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

void showEmailSignIn(BuildContext context, VoidCallback handleSignUp) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 130), // Adjust the maxHeight value as needed
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true, // This will hide the password text
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              AuthService authService = AuthService();
              await authService.signInWithEmailPassword(
                emailController.text.trim(),
                passwordController.text,
                context,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text('로그인'),
          ),
          ElevatedButton(
            onPressed: () {
              handleSignUp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text('회원가입'),
          ),
        ],
      );
    },
  );
}


class VideoPlayerWidget extends StatefulWidget {
  final Future<void> initializeVideoPlayerFuture;
  final VideoPlayerController videoPlayerController;

  const VideoPlayerWidget({
    Key? key,
    required this.initializeVideoPlayerFuture,
    required this.videoPlayerController,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: widget.videoPlayerController.value.aspectRatio,
            child: VideoPlayer(widget.videoPlayerController),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class SignOutButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback handleSignOut;

  const SignOutButton({
    Key? key,
    required this.isLoading,
    required this.handleSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
              ),
              onPressed: handleSignOut,
              child: const Text(
                '수면위로 올라오다.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}

typedef EmailSignUpDialogCallback = void Function(BuildContext context, VoidCallback handleSignUp);

class EmailLoginButton extends StatelessWidget {
  final EmailSignUpDialogCallback showSignUpDialog;
  final VoidCallback handleSignUp;

  const EmailLoginButton({
    Key? key,
    required this.showSignUpDialog,
    required this.handleSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
        ),
        onPressed: () {
          showSignUpDialog(context, handleSignUp);
        },
        child: const Text(
          '이메일로 로그인',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback handleSignIn;

  const GoogleSignInButton({
    Key? key,
    required this.isLoading,
    required this.handleSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        onPressed: isLoading ? null : handleSignIn,
        icon: ClipOval(
          child: Image.asset(
            'assets/images/login_screen/cthulhu_eye.png',
            width: 48,
            height: 48,
          ),
        ),
        label: const Text(
          '구글 로그인',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Future<String?> fetchAppCheckToken() async {
  if (kDebugMode) {
    // 디버그 모드에서는 디버그용 앱 체크 토큰을 가져옵니다.
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(false);
    print('Debug mode: Enabling app check debug appToken');
  } else {
    // 출시 모드에서는 실제 앱 체크 토큰을 가져옵니다.
    await FirebaseAppCheck.instance.activate();
  }

  final appToken = await FirebaseAppCheck.instance.getToken();
  print('App Check Token: $appToken');

  return appToken;
}