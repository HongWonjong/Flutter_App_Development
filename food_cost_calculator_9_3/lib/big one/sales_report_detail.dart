import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:food_cost_calculator_3_0/small one/custom_appbar.dart';

class SalesReportDetailPage extends StatefulWidget {
  final String reportId;

  const SalesReportDetailPage({required this.reportId, Key? key}) : super(key: key);

  @override
  _SalesReportDetailPageState createState() => _SalesReportDetailPageState();
}

class _SalesReportDetailPageState extends State<SalesReportDetailPage> {
  late Future<DocumentSnapshot> futureReport;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    futureReport = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('SalesReports')
        .doc(widget.reportId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "보고서 상세"),
      body: FutureBuilder<DocumentSnapshot>(
        future: futureReport,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            final name = data['name'] as String? ?? '제목 없음';
            final date = (data['date'] as Timestamp).toDate();
            final period = data['period'] as String? ?? '기간 정보 없음';
            final totalRevenue = data['data']['totalRevenue'] as double? ?? 0.0;
            final costListByFoodType = data['data']['costListByFoodType'] as Map<String, dynamic>? ?? {};

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Card(
                  child: ListTile(
                    title: Text('이름', style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(name, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ),
                const SizedBox(height: 8.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('날짜', style: Theme.of(context).textTheme.titleMedium),
                            Text(DateFormat('yyyy-MM-dd').format(date), style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('기간', style: Theme.of(context).textTheme.titleMedium),
                            Text(period, style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Card(
                  child: ListTile(
                    title: Text('총 수익', style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text('$totalRevenue', style: Theme.of(context).textTheme.titleSmall),
                  ),
                ),
                const SizedBox(height: 16.0),
                for (final entry in costListByFoodType.entries)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8.0),
                          if ((entry.value as List<dynamic>).isNotEmpty)
                            Text('총 판매량: ${(entry.value as List<dynamic>)[0]['quantity'] ?? '정보 없음'}, 음식 가격: ${(entry.value as List<dynamic>)[0]['foodPrice'] ?? '정보 없음'}', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8.0),
                          ExpansionTile(
                            title: Text('원가항목:', style: Theme.of(context).textTheme.titleSmall),
                            children: [
                              for (var costItemMap in (entry.value as List<dynamic>))
                                ListTile(
                                  title: Text('항목명: ${costItemMap['name']}', style: TextStyle(color: (costItemMap['isFixedCostPerUnit'] ?? false) ? Colors.blue : Colors.red)),
                                  subtitle: Text('원가 금액: ${costItemMap['unitCost']}'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(child: Text('데이터가 없습니다.'));
          }
        },
      ),
    );
  }
}


