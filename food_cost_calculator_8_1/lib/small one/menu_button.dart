import 'package:flutter/material.dart';
import '../big one/sales_report_page.dart';
import '../big one/ai_analysis_page.dart';

class CustomMenu extends StatelessWidget {
  const CustomMenu({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('몇 가지 기능을 추가 중입니다. 기다려주세요!'),
                duration: Duration(milliseconds: 700),
              ),
            );
          },
          icon: const Icon(Icons.menu),
        );
      },
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('매출보고서'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SalesReportPage()),
              );
            },
          ),
          ListTile(
            title: const Text('AI 분석'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIAnalysisPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}


