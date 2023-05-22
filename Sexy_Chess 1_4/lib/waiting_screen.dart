import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class WaitingScreen extends StatelessWidget {
  final User? user;

  const WaitingScreen({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user?.photoURL ?? ''),
                    radius: 50,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '유저 프로필',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '이름: ${user?.displayName ?? ''}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Text(
                    '승/패: X / X', // 여기에 실제 승/패 횟수 표시
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
          VerticalDivider(
            color: Colors.white,
            width: 1,
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 유저 정보 설정
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white38,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    '유저 정보 설정',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 캐릭터 / 스킨 설정
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white38,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    '캐릭터 / 스킨 설정',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 상점
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white38,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    '상점',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(
            color: Colors.white,
            width: 1,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MyApp(user: user),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white38,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '게임시작',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








