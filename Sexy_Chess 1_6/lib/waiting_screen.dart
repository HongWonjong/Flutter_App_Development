import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'my_app.dart';
import 'dart:math';
import 'dart:convert';


class WaitingScreen extends StatefulWidget {
  final User? user;

  const WaitingScreen({Key? key, this.user}) : super(key: key);

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  List<String> characterImages = [];
  Random random = Random();
  String randomImagePath = '';
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
  }

  Future<void> initPlayer() async {
    await player.setAsset('assets/sounds/waiting_screen_music.mp3');
    player.setLoopMode(LoopMode.all);
    player.play();
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
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.user?.photoURL ?? ''),
                          radius: 50,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '유저 프로필',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '이름: ${widget.user?.displayName ?? ''}',
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











