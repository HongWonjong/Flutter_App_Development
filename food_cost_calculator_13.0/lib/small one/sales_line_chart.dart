import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/logic/report.dart';


class SalesLineChart extends StatelessWidget {
  final List<Report> reports;

  const SalesLineChart({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: reports
                .map(
                  (report) => FlSpot(
                report.period, // x 축으로 쓸거임
                report.totalSales, // y축이겠지?
              ),
            )
                .toList(),

            // 그래프 디자인 코드...
          ),
        ],
        // 그래프 디자인 코드...
      ),
    );
  }
}
