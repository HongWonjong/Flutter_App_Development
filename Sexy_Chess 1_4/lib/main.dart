import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chess_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
  import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MaterialApp(home: LoginScreen()));
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
      ),
    );
  }
}






