import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/logic/chart_colors.dart';

List<PieChartSectionData> generateData(Map<String, dynamic> totalRevenueByFoodType, List<Color> colors) {
  List<PieChartSectionData> sections = [];
  int i = 0;

  totalRevenueByFoodType.forEach((foodName, totalRevenue) {
    sections.add(PieChartSectionData(
      color: getRandomColor(),
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
