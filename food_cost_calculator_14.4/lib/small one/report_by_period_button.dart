import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/big one/period_sales_report_detail.dart';

class PeriodReportButton extends StatelessWidget {
  final ValueNotifier<List<String>> checkedList;
  final User? user;
  final FirebaseFirestore _firestore;

  PeriodReportButton({Key? key, required this.checkedList, required this.user, required FirebaseFirestore firestore}) : _firestore = firestore, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 250,  // 원하는 너비로 변경
        height: 60,  // 원하는 높이로 변경
        child: ElevatedButton(
          onPressed: () async {
            if (checkedList.value.length < 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('적어도 두 개 이상의 보고서를 선택해주세요'),
                  duration: Duration(milliseconds: 1000),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              final reports = _firestore.collection('users').doc(user?.uid).collection('SalesReports');
              Map<String, DateTime> reportDates = {};
              for (String docId in checkedList.value) {
                final doc = await reports.doc(docId).get();
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['date'] as Timestamp).toDate();
                reportDates[docId] = date;
              }

              checkedList.value.sort((a, b) => reportDates[a]!.compareTo(reportDates[b]!));

              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesAnalysisPage(),
                  settings: RouteSettings(
                    arguments: checkedList.value,
                  ),
                ),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),  // Set background color to white
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),  // Increase width to create a thicker border
              ),
            ),
            overlayColor: MaterialStateProperty.all(Colors.deepPurpleAccent.withOpacity(0.1)),  // Add a overlay color to create a slight hover effect
          ),
          child: const Text(
            '여러 보고서 함께 보기',
            style: TextStyle(fontSize: 20.0, color: Colors.deepPurpleAccent),  // Set text color to deepPurpleAccent
          ),
        ),
      ),
    );
  }
}
