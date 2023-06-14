// SalesAnalysisPage.dart
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/small one/custom_appbar.dart';
import 'package:food_cost_calculator_3_0/small one/sales_line_chart.dart';
import 'package:food_cost_calculator_3_0/logic/report.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<List<Report>> getFutureSalesDataList(List<String> checkedList) async {
  final user = FirebaseAuth.instance.currentUser;
  List<Report> reports = [];

  for (var reportId in checkedList) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('SalesReports')
        .doc(reportId)
        .get();

    if (doc.exists) {
      final totalSales = (doc.data()!['data']['totalRevenue'] as num?)?.toDouble() ?? 0;
      final totalCost = (doc.data()!['data']['totalCost'] as num?)?.toDouble() ?? 0;
      final period = doc.data()!['period'] as int ?? 0; // 이 필드를 추가해줍니다.
      final netProfit = totalSales - totalCost; // calculate netProfit here
      reports.add(Report(reportId, totalSales, period, netProfit));
    }
  }

  return reports;
}

class SalesAnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ModalRoute를 통해 전달받은 checkedList를 사용합니다.
    final checkedList = ModalRoute.of(context)!.settings.arguments as List<String>;

    return Scaffold(
      appBar: const MyAppBar(
        title: "기간별 매출분석",
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Report>>(
          future: getFutureSalesDataList(checkedList),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                children: [
                  SalesLineChart(reports: snapshot.data!, title: "매출 변화",),
                  SalesLineChart(reports: snapshot.data!, title: "순이익 변화",),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


