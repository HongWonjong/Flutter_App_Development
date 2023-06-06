import 'package:flutter/material.dart';
import '../big one/sales_report_page.dart';
import '../big one/ai_analysis_page.dart';

class CustomMenu extends StatelessWidget {
  const CustomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
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


