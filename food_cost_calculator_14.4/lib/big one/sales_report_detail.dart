import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:food_cost_calculator_3_0/small one/custom_appbar.dart';
import 'package:food_cost_calculator_3_0/logic/pie_chart_logic.dart';
import 'package:food_cost_calculator_3_0/small one/pie_chart.dart';
import 'package:food_cost_calculator_3_0/logic/chart_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:food_cost_calculator_3_0/small one/cost_bar_graph.dart';

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
    final lang = AppLocalizations.of(context)!;
    final formatCurrency = NumberFormat('#,##0', 'en_US');

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
            final totalRevenueFormatted = formatCurrency.format(totalRevenue);
            final costListByFoodType = data['data']['costListByFoodType'] as Map<String, dynamic>? ?? {};
            final totalRevenueByFoodType = data['data']['totalRevenueByFoodType'] as Map<String, dynamic>? ?? {};
            final profitByFoodType = data['data']['profitByFoodType'] as Map<String, dynamic>? ?? {};
            final costRateByFoodType = data['data']['costRateByFoodType'] as Map<String, dynamic>? ?? {};

            final costItems = (data['data']['costListByFoodType'] as Map<String, dynamic>? ?? {}).entries.expand((entry) {
              return (entry.value as List<dynamic>).map((costItem) => MapEntry<String, double>(
                costItem['name'] as String,
                (costItem['unitCost'] as num).toDouble() * (costItem['isFixedCostPerUnit'] ?? false ? 1.0 : (costItem['quantity'] as num).toDouble() ?? 1.0),
              ));
            }).toList();


            costItems.sort((a, b) => b.value.compareTo(a.value));
            final top7CostItems = costItems.take(7).map((entry) => MapEntry(entry.key, entry.value.toDouble())).toList();

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
                            Text('작성일자', style: Theme.of(context).textTheme.titleMedium),
                            Text(DateFormat('yyyy-MM-dd').format(date), style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('대상 기간', style: Theme.of(context).textTheme.titleMedium),
                            Text("$period 월", style: Theme.of(context).textTheme.titleSmall),
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
                    subtitle: Text("$totalRevenueFormatted ${lang.calculationPage_name_of_currency}", style: Theme.of(context).textTheme.titleSmall),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // Aligns the children evenly in the row
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomPieChart(
                          title: "매출액 기여도",
                          sections: generateData(totalRevenueByFoodType, colors),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomPieChart(
                          title: "순이익 기여도",
                          sections: generateData(profitByFoodType, colors),
                        ),
                      ),
                    ),
                  ],
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CostBarChart(data: top7CostItems),
                  ),
                ),
                for (final entry in costListByFoodType.entries)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(entry.key, style: Theme.of(context).textTheme.titleLarge ),
                          const SizedBox(height: 8.0),
                          if ((entry.value as List<dynamic>).isNotEmpty)
                            Text('총 판매량: ${(entry.value as List<dynamic>)[0]['quantity'] ?? '정보 없음'} ${lang.calculationPage_name_of_unit}, 음식 가격: ${formatCurrency.format((entry.value as List<dynamic>)[0]['foodPrice'] as double? ?? 0.0)} ${lang.calculationPage_name_of_currency}', style: Theme.of(context).textTheme.bodyMedium),
                            Text('원가율: ${((costRateByFoodType[entry.key] as double? ?? 0.0)).toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodyMedium),

                          const SizedBox(height: 8.0),
                          ExpansionTile(
                            title: Text('원가항목:', style: Theme.of(context).textTheme.titleSmall),
                            children: [
                              for (var costItemMap in (entry.value as List<dynamic>))
                                ListTile(
                                  title: Text('항목명: ${costItemMap['name']}', style: TextStyle(color: (costItemMap['isFixedCostPerUnit'] ?? false) ? Colors.blue : Colors.red)),
                                  subtitle: Text('원가 금액: ${formatCurrency.format(costItemMap['unitCost'])} ${lang.calculationPage_name_of_currency}'),
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




