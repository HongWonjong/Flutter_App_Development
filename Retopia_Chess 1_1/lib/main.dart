import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chess_board.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
          color: Colors.black, // AppBar의 색상을 검은색으로 변경
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Just Chess'),
        ),
        body: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 55.0), // 왼쪽에 패딩 추가
              child: ChessBoard(),
            ),
            Expanded(child: SizedBox()), // 남은 공간을 차지하는 빈 공간
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
