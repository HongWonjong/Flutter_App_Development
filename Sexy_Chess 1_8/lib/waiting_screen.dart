import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'game_page/my_app.dart';
import 'dart:math';
import 'dart:convert';



class WaitingScreen extends StatefulWidget {
  final User? user;
  final String? appToken; // 앱 토큰 변수 추가

  const WaitingScreen({Key? key, this.user, this.appToken}) : super(key: key);

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  List<String> characterImages = [];
  Random random = Random();
  String randomImagePath = '';
  String displayName = ''; // 닉네임 변수 추가
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadCharacterImages().then((List<String> images) {
      setState(() {
        characterImages = images;
        randomImagePath = getRandomImagePath();
      });
    });
    initPlayer();
    fetchDisplayName(); // 닉네임 가져오기
  }

  Future<void> initPlayer() async {
    await player.setAsset('assets/sounds/waiting_screen_music.mp3');
    player.setLoopMode(LoopMode.all);
    player.play();
  }

  Future<void> fetchDisplayName() async {
    try {
      final user = widget.user;
      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        final snapshot = await userRef.get();
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          setState(() {
            displayName = data['displayName'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Failed to fetch display name: $e');
    }
  }


  Future<List<String>> loadCharacterImages() async {
    List<String> imagePaths = [];

    try {
      String manifestContent = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> manifestMap = json.decode(manifestContent);

      for (String key in manifestMap.keys) {
        if (key.startsWith('assets/images/characters/') && key.endsWith('.jpg')) {
          imagePaths.add(key);
        }
      }
    } catch (e) {
      print('Failed to load character images: $e');
    }

    return imagePaths;
  }

  String getRandomImagePath() {
    if (characterImages.isNotEmpty) {
      int randomIndex = random.nextInt(characterImages.length);
      return characterImages[randomIndex];
    }
    return '';
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          '유저 프로필',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '이름: $displayName',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Text(
                          '승/패: X / X', // 여기에 실제 승/패 횟수 표시
                          style: TextStyle(fontSize: 18),
                        ),
                        const Text(
                          '승률: X %', // 여기에 실제 승/패 횟수 표시
                          style: TextStyle(fontSize: 18),
                        ),
                        const Text(
                          '레이팅: X', // 여기에 실제 레이팅 표시
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(
                  color: Colors.white,
                  width: 1,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: screenwidth * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: randomImagePath.isNotEmpty
                            ? Image.asset(
                          randomImagePath,
                          fit: BoxFit.fill,
                          width: screenwidth * 0.6,
                        )
                            : Container(),
                      ),
                    )

                  ],
                ),
                const VerticalDivider(
                  color: Colors.white,
                  width: 1,
                ),
                Expanded(
                  child: Container(),
                ),
                const VerticalDivider(
                  color: Colors.white,
                  width: 1,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // 유저 정보 설정
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38,
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          '지휘관 프로파일',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 캐릭터 / 스킨 설정
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38,
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          '전투원 막사',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 상점
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38,
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          '보급창고',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MyApp(user: widget.user),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38,
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          '전투 시작',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Row(
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}











