import 'package:flutter/material.dart';
import '../small one/custom_appbar.dart';

class AIAnalysisPage extends StatelessWidget {
  const AIAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(title: 'AI 분석'),
      body: Center(
        child: Text('AI Analysis Page'),
      ),
    );
  }
}
