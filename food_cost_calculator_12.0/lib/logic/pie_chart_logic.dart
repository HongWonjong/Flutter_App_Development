import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<PieChartSectionData> generateData(Map<String, dynamic> totalRevenueByFoodType, List<Color> colors) {
  List<PieChartSectionData> sections = [];
  int i = 0;

  totalRevenueByFoodType.forEach((foodName, totalRevenue) {
    sections.add(PieChartSectionData(
      color: colors[i % colors.length],
      value: totalRevenue.toDouble(),
      title: foodName,
      radius: 35,
      showTitle: true,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    ));
    i++;
  });

  return sections;
}
