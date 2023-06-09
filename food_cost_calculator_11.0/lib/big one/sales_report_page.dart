import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../small one/custom_appbar.dart';
import './sales_report_detail.dart'; // SalesReportDetailPage가 있는 경로를 입력하세요.

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  List<bool> checkedList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _deleteReports(QuerySnapshot snapshot) async {
    final reports = _firestore
        .collection('users')
        .doc(user?.uid)
        .collection('SalesReports');

    for (int i = 0; i < checkedList.length; i++) {
      if (checkedList[i]) {
        await reports.doc(snapshot.docs[i].id).delete();
      }
    }

    setState(() {
      checkedList = List.filled(snapshot.docs.length, false);
    });
  }

  Future<void> _confirmDelete(QuerySnapshot snapshot) async {
    // Check if any checkboxes are selected
    if (!checkedList.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('삭제할 보고서를 선택해주세요'),
          duration: Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('매출보고서 삭제'),
          content: const Text('선택한 매출보고서를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('예'),
              onPressed: () {
                _deleteReports(snapshot);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteReports() async {
    final reportSnapshot = await _firestore
        .collection('users')
        .doc(user?.uid)
        .collection('SalesReports')
        .get();

    _confirmDelete(reportSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    final reportStream = _firestore
        .collection('users')
        .doc(user?.uid)
        .collection('SalesReports')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: const MyAppBar(title: '매출보고서'),
      body: StreamBuilder<QuerySnapshot>(
        stream: reportStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          checkedList = List.filled(snapshot.data?.docs.length ?? 0, false);

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] as String? ?? '제목 없음';
              final date = (data['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('yyyy-MM-dd').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                child: Row(
                  children: [
                    Expanded(
                      child: Checkbox(
                        value: checkedList[index],
                        onChanged: (value) {
                          setState(() {
                            checkedList[index] = value ?? false;
                          });
                        },
                      ),
                    ),
                    const VerticalDivider(
                      width: 2,
                      thickness: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    Expanded(
                      flex: 5,
                      child: ListTile(
                        title: Text(name, style: Theme.of(context).textTheme.titleLarge),
                        subtitle: Text(formattedDate, style: Theme.of(context).textTheme.titleSmall),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SalesReportDetailPage(reportId: doc.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmDeleteReports,
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),
    );
  }
}






