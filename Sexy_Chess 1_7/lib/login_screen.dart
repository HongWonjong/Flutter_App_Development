import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 추가된 라이브러리
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_player/video_player.dart';
import 'loading_donut.dart';
import 'waiting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  late AnimationController _animationController;
  late Animation<double> _animation;
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

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
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

      final docSnapshot = await userRef.get();
      if(!docSnapshot.exists) {
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
  void handleSignIn() async {
    setState(() {
      isLoading = true;
    });

    UserCredential? userCredential = await signInWithGoogle();
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
  }

  void handleSignOut() async {
    await signOut();
    setState(() {
      isLoading = false;
    });
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
      backgroundColor: Colors.indigo, // 배경색을 붉은 색으로 변경
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16), // 가장자리의 여백을 추가
              child: Container(
                padding: const EdgeInsets.all(16), // 로그인 영역의 여백을 추가
                decoration: BoxDecoration(
                  color: Colors.white38, // 로그인 영역 배경색을 흰색으로 설정
                  border: Border.all(width: 4, color: Colors.white), // 경계선 스타일 설정
                  borderRadius: BorderRadius.circular(16), // 로그인 영역의 모서리를 둥글게 설정
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    const Text(
                      "크툴루 체스",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.normal),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: isLoading ? null : handleSignIn, // 버튼 비활성화 처리
                        icon: ClipOval(
                          child: Image.asset(
                            'assets/images/login_screen/cthulhu_eye.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                        label: const Text(
                          '미지 조우',
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
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white54),
                          onPressed: handleSignOut, // 로그아웃 버튼 클릭 시 로그아웃 처리
                          child: const Text(
                            '수면위로 올라오다.',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16), // 오른쪽에 패딩 추가
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black, // 배경색을 검정색으로 설정
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



















