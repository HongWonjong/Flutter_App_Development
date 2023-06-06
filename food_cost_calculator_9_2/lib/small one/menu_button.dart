import 'package:flutter/material.dart';
import '../big one/sales_report_page.dart';
import '../big one/ai_analysis_page.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(  // Container 추가
        color: Colors.deepPurpleAccent,  // 배경색 설정
        child: ListView(
          children: [
            ListTile(
              title: const Text(
                '매출보고서',
                style: TextStyle(color: Colors.white),  // 텍스트 색상 변경
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalesReportPage()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'AI 분석',
                style: TextStyle(color: Colors.white),  // 텍스트 색상 변경
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIAnalysisPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



