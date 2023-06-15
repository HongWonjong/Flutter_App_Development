import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/logic/report.dart';

class SalesLineChart extends StatelessWidget {
  final List<Report> reports;
  final String title;

  const SalesLineChart({Key? key, required this.reports, required this.title}) : super(key: key);

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
                show: false, // Grid를 안보이게 설정하였습니다.
              ),
              titlesData: FlTitlesData(
                show: true, // 타이틀을 보이게 설정하였습니다.
              ),
              borderData: FlBorderData(
                show: false, // Border를 안보이게 설정하였습니다.
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: reports
                      .map(
                        (report) => FlSpot(
                      report.period.toDouble(), // x 축으로 쓸거임
                      report.totalSales, // y축이겠지?
                    ),
                  )
                      .toList(),
                  isCurved: true, // Line을 부드럽게 곡선으로 만들었습니다.
                  color: Colors.blue, // Line의 색상을 파란색으로 설정하였습니다.
                  barWidth: 4, // Line의 두께를 조절하였습니다.
                  isStrokeCapRound: true, // Line 끝을 둥글게 만들었습니다.
                  dotData: FlDotData(
                    show: true, // 각 데이터 포인트에 점을 보이게 설정하였습니다.
                  ),
                  belowBarData: BarAreaData(
                    show: false, // 바의 영역을 안보이게 설정하였습니다.
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



