import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/logic/report.dart';

class SalesLineChart extends StatelessWidget {
  final List<Report> reports;
  final String title;
  final double Function(Report) getY;
  final Color lineColor;

  const SalesLineChart({
    Key? key,
    required this.reports,
    required this.title,
    required this.getY,
    required this.lineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: false,
              ),
              titlesData: FlTitlesData(
                show: true,
              ),
              borderData: FlBorderData(
                show: false,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: reports
                      .map(
                        (report) => FlSpot(
                      report.period.toDouble(),
                      getY(report),
                    ),
                  )
                      .toList(),
                  isCurved: true,
                  color: lineColor,
                  barWidth: 4,
                  isStrokeCapRound: false,
                  dotData: FlDotData(
                    show: true,
                  ),
                  belowBarData: BarAreaData(
                    show: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}




