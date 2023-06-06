import 'package:flutter/material.dart';
import '../small one/custom_appbar.dart';

class SalesReportPage extends StatelessWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(title: '매출보고서'),
      body: Center(
        child: Text('Sales Report Page'),
      ),
    );
  }
}
