import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../small one/custom_appbar.dart';
import './sales_report_detail.dart';
import 'package:food_cost_calculator_3_0/big one/period_sales_report_detail.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  List<String> checkedList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _deleteReports() async {
    final reports = _firestore.collection('users').doc(user?.uid).collection('SalesReports');

    for (String docId in checkedList) {
      await reports.doc(docId).delete();
    }

    checkedList = [];
  }

  Future<void> _confirmDelete() async {
    if (checkedList.isEmpty) {
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
                _deleteReports();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _loadBannerAd() {
    String adUnitId;

    if (kReleaseMode) {
      adUnitId = Platform.isAndroid
          ? 'ca-app-pub-2047502466332917/9516752899'
          : 'YOUR_IOS_BANNER_AD_UNIT_ID';
    } else {
      adUnitId = Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'YOUR_IOS_TEST_BANNER_AD_UNIT_ID';
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('BannerAd loaded.');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportStream = _firestore.collection('users').doc(user?.uid).collection('SalesReports').orderBy('date', descending: true).snapshots();

    return Scaffold(
      appBar: const MyAppBar(title: '매출보고서'),
      body: StreamBuilder<QuerySnapshot>(
        stream: reportStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('보고서 관련 기능을 위해서 먼저 로그인을 해주세요.', style: TextStyle(fontSize: 17),));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Widget> listItems = [];

          if (_bannerAd != null) {
            listItems.add(
              Container(
                alignment: Alignment.center,
                height: 72.0,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: AdWidget(ad: _bannerAd!),
              ),
            );
          }

          listItems.addAll(
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] as String? ?? '제목 없음';
              final date = (data['date'] as Timestamp).toDate();
              final period = data['period'] as String ?? 0 ;
              final formattedDate = DateFormat('yyyy-MM-dd').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                child: Row(
                  children: [
                    Expanded(
                      child: Checkbox(
                        value: checkedList.contains(doc.id),
                        onChanged: (value) {
                          setState(() {
                            if (value ?? false) {
                              checkedList.add(doc.id);
                            } else {
                              checkedList.remove(doc.id);
                            }
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("작성일자: $formattedDate", style: Theme.of(context).textTheme.titleSmall),
                            Text("기간: $period월", style: Theme.of(context).textTheme.titleSmall),  // 이 부분을 추가합니다.
                          ],
                        ),
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
            }).toList(),
          );

          return ListView(
            children: listItems,
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: MediaQuery.of(context).size.width / 2 - 170, // 28은 버튼의 반지름입니다.
              bottom: 0,
              child: FloatingActionButton(
                onPressed: _confirmDelete,
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 145, // 28은 버튼의 반지름입니다.
              bottom: 0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesAnalysisPage(),
                      settings: RouteSettings(
                        arguments: checkedList,  // 선택된 보고서들의 ID를 전달
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.analytics),
              ),
            ),
          ],
        ),
      ),
    );
  }
}








