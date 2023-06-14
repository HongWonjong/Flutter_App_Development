import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../logic/cost_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_cost_calculator_3_0/small one/custom_appbar.dart';
import 'package:flutter/services.dart';  // <- Required for input formatter

class UploadReportPage extends StatefulWidget {
  final Map<String, int> fixedCostByFoodType;
  final Map<String, int> variableCostByFoodType;
  final Map<String, List<CostItem>> costListByFoodType;
  final Map<String, int> totalRevenueByFoodType;
  final Map<String, int> profitByFoodType;
  final Map<String, double> costRateByFoodType; // <-- New property
  final double totalCostRate;
  final double totalRevenue;
  final int totalCost;

  const UploadReportPage({
    Key? key,
    required this.fixedCostByFoodType,
    required this.variableCostByFoodType,
    required this.costListByFoodType,
    required this.totalRevenueByFoodType,
    required this.profitByFoodType,
    required this.costRateByFoodType, // <-- New property
    required this.totalCostRate,
    required this.totalRevenue,
    required this.totalCost,
  }) : super(key: key);

  @override
  _UploadReportPageState createState() => _UploadReportPageState();
}


class _UploadReportPageState extends State<UploadReportPage> {
  final _reportNameController = TextEditingController();
  final _reportPeriodController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;

  void _saveReportToFirestore() async {
    final reportName = _reportNameController.text;
    final reportPeriod = int.tryParse(_reportPeriodController.text) ?? 0;  // <- Here we parse the period to an int

    // Convert each CostItem in costListByFoodType to a Map.
    final costListByFoodTypeMapped = widget.costListByFoodType.map((foodType, costList) => MapEntry(
      foodType,
      costList.map((costItem) => costItem.toMap()).toList(),
    ));

    final reportData = <String, dynamic>{
      'totalRevenueByFoodType': widget.totalRevenueByFoodType,
      'fixedCostByFoodType': widget.fixedCostByFoodType,
      'variableCostByFoodType': widget.variableCostByFoodType,
      'costListByFoodType': costListByFoodTypeMapped,
      'profitByFoodType': widget.profitByFoodType,
      'costRateByFoodType': widget.costRateByFoodType, // <-- New property
      'totalCostRate': widget.totalCostRate,
      'totalRevenue': widget.totalRevenue,
      'totalCost': widget.totalCost,
    };


    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        final documentReference = await _firestore.collection('users').doc(userId).collection('SalesReports').add({
          'name': reportName,
          'date': DateTime.now(),
          'period': reportPeriod,
          'data': reportData,
        });

        _reportNameController.clear();
        _reportPeriodController.clear();

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('보고서 저장'),
              content: const Text('보고서가 성공적으로 저장되었습니다. \n 메뉴버튼의 "매출보고서"에서 확인하실 수 있습니다.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('보고서 저장'),
              content: const Text('사용자 인증이 필요합니다.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('보고서 저장'),
            content: const Text('보고서 저장 중에 오류가 발생했습니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "보고서 작성"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _reportNameController,
              decoration: const InputDecoration(
                labelText: '보고서 이름',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _reportPeriodController,
              decoration: const InputDecoration(
                labelText: '보고서 기간 (월)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveReportToFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent, // primary sets the background color
              ),
              child: const Text('보고서로 저장'),
            ),
          ],
        ),
      ),
    );
  }
}




