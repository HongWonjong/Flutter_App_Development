import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_player/video_player.dart';
import 'loading_donut.dart';
import 'waiting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'login_screen_function.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isLoading = false;
  bool showSignUpButton = false; // Add this line
  late AnimationController _animationController;
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  // Debug token
  final String debugToken = '71D3D03C-C5E2-42F6-B3F8-3BA7CFBB5F79';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _videoPlayerController = VideoPlayerController.asset(
      'assets/videos/login_cthulhu.mp4',
    );
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.play();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential? userCredential;
      for (int i = 0; i < 3; i++) {
        try {
          userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

          final user = userCredential.user;
          final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

          final docSnapshot = await userRef.get();
          if (!docSnapshot.exists) {
            await userRef.set({
              'uid': user.uid,
              'email': user.email,
              'displayName': user.displayName,
              'photoURL': user.photoURL,
            });
          }

          return userCredential;
        } catch (e) {
          print('Error occurred using Google Sign-In: $e');
        }
      }

      // 여기에 실패한 경우의 처리 로직을 추가하세요.
      print('Failed to sign in with Google after multiple attempts.');

      return null;
    } catch (e) {
      print('Error occurred using Google Sign-In: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
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
            'photoURL': user.photoURL,
          });
        }

        return userCredential;
      }

      return null;
    } catch (e) {
      print('Error occurred using Email/Password Sign-In: $e');
      return null;
    }
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

  void handleSignIn() async {
    setState(() {
      isLoading = true;
    });

    UserCredential? userCredential = await signInWithGoogle();
    if (userCredential != null) {
      // 앱 토큰 가져오기
      User? user = userCredential.user;
      String? appToken;

      // 디버그 모드와 프로덕션 모드에서 다르게 처리
      if (kDebugMode) {
        // 디버그 모드에서는 디버그 토큰을 사용
        appToken = debugToken;
      } else {
        // 실제 앱에서는 getIdToken()을 사용
        appToken = await user?.getIdToken();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WaitingScreen(user: userCredential.user, appToken: appToken),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSignUpButton() {
    setState(() {
      showSignUpButton = true;
    });
  }

  void handleSignUp() {
    // Implement the logic for user registration here
  }

  void handleSignInWithEmailPassword() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일과 비밀번호를 입력해주세요.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    UserCredential? userCredential =
    await signInWithEmailPassword(email, password);
    if (userCredential != null) {
      // 로그인 성공 시 처리 로직
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSignOut() async {
    // 로그아웃 처리 코드
  }

  @override
  Widget build(BuildContext context) {
    // 추가된 부분 시작
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 추가된 부분 끝

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.indigo,
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white38,
                  border: Border.all(width: 4, color: Colors.white),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '크툴루 체스',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
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
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('이메일로 로그인'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        onChanged: (value) {
                                          // 이메일 값 업데이트
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Email',
                                          border: OutlineInputBorder(),
                                        ),
                                        // TextField의 속성들 추가
                                      ),
                                      TextField(
                                        onChanged: (value) {
                                          // 비밀번호 값 업데이트
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Password',
                                          border: OutlineInputBorder(),
                                        ),
                                        // TextField의 속성들 추가
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // 로그인 로직 구현
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey, // Set the button background color to blueGrey
                                    ),
                                    child: const Text('로그인'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // 회원가입 로직 구현
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey, // Set the button background color to blueGrey
                                    ),
                                    child: const Text('회원가입'),
                                  ),
                                ],
                              );
                            },
                          );

                        },
                        child: const Text(
                          '이메일로 로그인',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (!isLoading)
                      Column(
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
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
























