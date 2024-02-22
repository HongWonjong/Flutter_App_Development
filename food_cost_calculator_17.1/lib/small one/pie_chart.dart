import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomPieChart extends StatelessWidget {
  final String title;
  final List<PieChartSectionData> sections;

  const CustomPieChart({
    required this.title,
    required this.sections,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalValue = 0;
    sections.forEach((section) => totalValue += section.value);

    final percentageSections = sections.map((section) {
      final percentage = (section.value / totalValue) * 100;
      return section.copyWith(title: '${section.title} (${percentage.toStringAsFixed(1)}%)');
    }).toList();

    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: percentageSections,
                pieTouchData: PieTouchData(touchCallback: (pieTouchResponse, flTouchEvent) {
                  // Update your state depending on `pieTouchResponse` and `flTouchEvent`
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

