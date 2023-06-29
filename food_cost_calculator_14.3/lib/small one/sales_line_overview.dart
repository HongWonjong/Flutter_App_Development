import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/logic/report.dart';

class SalesLineOverview extends StatelessWidget {
  final List<Report> reports;
  final String title;
  final double Function(Report) getY1;
  final double Function(Report) getY2;
  final double Function(Report) getY3;

  const SalesLineOverview({
    Key? key,
    required this.reports,
    required this.title,
    required this.getY1,
    required this.getY2,
    required this.getY3,
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
                      getY1(report),
                    ),
                  )
                      .toList(),
                  isCurved: true,
                  color: Colors.deepPurpleAccent,
                  barWidth: 4,
                  isStrokeCapRound: false,
                  dotData: FlDotData(
                    show: true,
                  ),
                  belowBarData: BarAreaData(
                    show: false,
                  ),
                ),
                LineChartBarData(
                  spots: reports
                      .map(
                        (report) => FlSpot(
                      report.period.toDouble(),
                      getY2(report),
                    ),
                  )
                      .toList(),
                  isCurved: true,
                  color: Colors.orangeAccent,
                  barWidth: 4,
                  isStrokeCapRound: false,
                  dotData: FlDotData(
                    show: true,
                  ),
                  belowBarData: BarAreaData(
                    show: false,
                  ),
                ),
                LineChartBarData(
                  spots: reports
                      .map(
                        (report) => FlSpot(
                      report.period.toDouble(),
                      getY3(report),
                    ),
                  )
                      .toList(),
                  isCurved: true,
                  color: Colors.blueGrey,
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
