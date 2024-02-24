// SalesAnalysisPage.dart
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/small one/custom_appbar.dart';
import 'package:food_cost_calculator_3_0/small one/sales_line_chart.dart';
import 'package:food_cost_calculator_3_0/logic/report.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_cost_calculator_3_0/small one/sales_line_overview.dart';
import 'package:food_cost_calculator_3_0/small one/sales_analysis_table.dart';

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
      final period = doc.data()!['period'] as String; // 이 필드를 추가해줍니다.
      // '2023-01' 같은 문자열을 DateTime 객체로 변환하고, 이를 milliseconds 단위의 timestamp로 변환
      final netProfit = totalSales - totalCost; // calculate netProfit here
      reports.add(Report(reportId, totalSales, period, netProfit, totalCost));
    }
  }

  return reports;
}


class SalesAnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SalesBarChart(reports: snapshot.data!, title: "매출 변화 (단위: 만원)", getY: (report) => report.totalSales / 10000, barColor: Colors.deepPurpleAccent),// 만원 단위로 표시하자
                    SalesBarChart(reports: snapshot.data!, title: "순이익 변화 (단위: 만원)", getY: (report) => report.netProfit / 10000, barColor: Colors.orangeAccent,),
                    SalesBarChart(reports: snapshot.data!, title: "총 원가 변화 (단위: 만원)", getY: (report) => report.totalCost / 10000, barColor: Colors.greenAccent,),
                    SalesBarOverview(reports: snapshot.data!, title: "매출-순이익-총 원가 변화", getY1: (report) => report.totalSales / 10000, getY2: (report) => report.netProfit / 10000, getY3: (report) => report.totalCost / 10000),
                    SalesAnalysisTable(checkedList: checkedList),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}



