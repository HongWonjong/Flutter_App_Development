import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Merong's catchmind helper",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.deepPurple, fontFamily: 'NotoSansKR'),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.deepPurple, fontFamily: 'NotoSansKR'),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}


