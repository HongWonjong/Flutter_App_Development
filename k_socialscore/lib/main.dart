import 'package:flutter/material.dart';
import 'settings.dart'; // settings.dart 파일을 import 합니다.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Political Correctness Quiz',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // 설정 값을 사용합니다.
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                descriptionText, // 설정 값을 사용합니다.
                style: TextStyle(
                  color: textColor, // 설정 값을 사용합니다.
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // 설정 값을 사용합니다.
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizPage()),
                  );
                },
                child: Text(
                  '게임 시작',
                  style: TextStyle(
                    color: textColor, // 설정 값을 사용합니다.
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Page'),
      ),
      body: Center(
        child: Text('퀴즈 시작!'),
      ),
    );
  }
}
