import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/logic/chart_colors.dart';

String formatCurrency(int amount) {
  return (amount / 10000).toStringAsFixed(0);
}


class CostBarChart extends StatelessWidget {
  final List<MapEntry<String, double>> data;

  const CostBarChart({Key? key, required this.data}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "주요 원가(단위: 만원)",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              maxY: data.fold(0.0, (previousValue, element) => element.value.toDouble() > previousValue! ? element.value.toDouble() : previousValue),
              barTouchData: barTouchData,
              titlesData: titlesData,
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
              gridData: FlGridData(show: false),
              alignment: BarChartAlignment.spaceAround,
            ),
          ),
        ),
        ...legendItems, // 범례 아이템들을 추가합니다.
      ],
    );
  }

  // 각 데이터 항목에 대해 색상과 이름을 표시하는 범례 아이템들을 만듭니다.
  List<Widget> get legendItems => data.asMap().entries.map((e) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 16,
            height: 16,
            color: getSettledColor(e.key), // 데이터에 맞는 색상
          ),
          const SizedBox(width: 8),
          Text(e.value.key), // 데이터 이름
        ],
      ),
    );
  }).toList();

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
          ) {
        return BarTooltipItem(
          formatCurrency(rod.toY.round()),
          const TextStyle(
            color: Colors.blue, // replace with your color
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
  );

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: false,
        reservedSize: 30,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );

  List<BarChartGroupData> get barGroups => data.asMap().entries.map((e) {
    return BarChartGroupData(
      x: e.key,
      barRods: [
        BarChartRodData(
          toY: e.value.value.toDouble(), // double로 형변환
          color: getSettledColor(e.key), // 인덱스에 맞는 색상
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();
}







