import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chess_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'waiting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( const MaterialApp(home: LoginScreen()));
}

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
                          leading: Icon(Icons.exit_to_app),
                          title: Text('나가기'),
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => WaitingScreen(user: user),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.report),
                          title: Text('신고하기'),
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







