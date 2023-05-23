import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chess_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'waiting_screen.dart';
import 'chess_board_logic.dart';

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: '그냥 체스',
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          color: Colors.black26,
        ),
        scaffoldBackgroundColor: Colors.blueGrey, // 배경색 설정
      ),
      home: Scaffold(
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1.0),
              child: ChessBoard(user: user),
            ),
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2.0),
          ),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.exit_to_app),
                          title: const Text('나가기'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('경고'),
                                  content: const Text('게임 중에 나가면 패배로 처리됩니다. 나가시겠습니까?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('아니오'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('예'),
                                      onPressed: () {
                                        pieces = initialPieces;
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => WaitingScreen(user: user),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.report),
                          title: const Text('신고하기'),
                          onTap: () {
                            // 신고하기 기능 구현
                            Navigator.of(context).pop(); // 메뉴가 닫힘
                          },
                        ),
                        // 다른 메뉴 아이템들 추가
                      ],
                    ),
                  );
                },
              );
            },
            backgroundColor: Colors.blueGrey,
            child: const Icon(Icons.settings),
          ),
        ),
      ),
    );
  }
}