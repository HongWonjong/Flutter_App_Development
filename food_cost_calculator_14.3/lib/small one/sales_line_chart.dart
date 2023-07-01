import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/logic/report.dart';

class SalesBarChart extends StatelessWidget {
  final List<Report> reports;
  final String title;
  final double Function(Report) getY;
  final Color barColor;

  const SalesBarChart({
    Key? key,
    required this.reports,
    required this.title,
    required this.getY,
    required this.barColor,
  }) : super(key: key);

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    int index = value.toInt();
    if (index >= 0 && index < reports.length) {
      return Text(reports[index].period, style: style);
    } else {
      return const Text('', style: style);
    }
  }

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
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: reports.map(getY).reduce((a, b) => a > b ? a : b),
              gridData: FlGridData(
                show: false,
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: false
                    )
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: getTitles,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: reports.asMap().entries.map((entry) {
                int index = entry.key;
                Report report = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: getY(report),
                      color: barColor,
                      width: 22,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}






