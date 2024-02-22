import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/logic/report.dart';


class SalesAnalysisTable extends StatelessWidget {
  final List<String> checkedList;

  const SalesAnalysisTable({super.key, required this.checkedList});




  List<DataColumn> getColumns(List<Report> reports) {
    return const <DataColumn>[
      DataColumn(label: Text('보고서 ID')),
      DataColumn(label: Text('총 매출')),
      DataColumn(label: Text('총 원가')),
      DataColumn(label: Text('순이익')),
    ];
  }

  List<DataRow> getRows(List<Report> reports) {
    return reports.map((report) {
      return DataRow(cells: [
        DataCell(Text(report.totalSales.toString())),
        DataCell(Text(report.totalCost.toString())),
        DataCell(Text(report.netProfit.toString())),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Report> reports = []; // reports 리스트는 어떻게 가져오는지 명확하지 않아 임의로 빈 리스트를 생성합니다.

    return Column(
      children: [
        DataTable(
          columns: getColumns(reports),
          rows: getRows(reports),
        ),
      ],
    );
  }
}



