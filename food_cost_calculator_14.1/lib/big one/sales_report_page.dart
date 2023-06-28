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
  ValueNotifier<List<String>> checkedList = ValueNotifier([]);
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

    for (String docId in checkedList.value) {
      await reports.doc(docId).delete();
    }

    checkedList.value = [];
  }

  Future<void> _confirmDelete() async {
    if (checkedList.value.isEmpty) {
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

          listItems.add(
            Padding(
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
                    '보고서 기간별로 보기',
                    style: TextStyle(fontSize: 20.0, color: Colors.deepPurpleAccent),  // Set text color to deepPurpleAccent
                  ),
                ),
              ),
            ),
          );
          listItems.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 250,  // 원하는 너비로 변경
                height: 60,  // 원하는 높이로 변경
                child: ElevatedButton(
                  onPressed: () async {
                    if (checkedList.value.length != 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('한 개의 보고서만 선택해주세요. 현재 보고서는 개별적으로만 분석 가능합니다.'),
                          duration: Duration(milliseconds: 1000),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      final reports = _firestore.collection('users').doc(user?.uid).collection('SalesReports');
                      final reportDoc = await reports.doc(checkedList.value[0]).get();  // Assume checkedList.value[0] is document ID of selected report

                      final gptReplies = _firestore.collection('users').doc(user?.uid).collection('gpt_Replies');
                      await gptReplies.add({
                        'prompt': reportDoc.data(),  // Use report data as the prompt
                        'parentMessageId': '(Optional) Message ID coming from API to track conversations'
                      });
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
                    'AI에게 분석 요청(개별 보고서)',
                    style: TextStyle(fontSize: 20.0, color: Colors.deepPurpleAccent),  // Set text color to deepPurpleAccent
                  ),
                ),
              ),
            ),
          );

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
              final period = data['period'] as int ?? 0 ;
              final formattedDate = DateFormat('yyyy-MM-dd').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                child: Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                          valueListenable: checkedList,
                          builder: (context, List<String> checkedListValue, _) {
                            return Checkbox(
                              value: checkedListValue.contains(doc.id),
                              onChanged: (value) {
                                if (value ?? false) {
                                  checkedListValue.add(doc.id);
                                } else {
                                  checkedListValue.remove(doc.id);
                                }
                                checkedList.value = List.from(checkedListValue);
                              },
                            );
                          }
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text('$formattedDate ($period 월)'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SalesReportDetailPage(reportId: doc.id),
                              settings: RouteSettings(
                                arguments: doc.id,
                              ),
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
            padding: const EdgeInsets.only(bottom: 72),
            children: listItems,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmDelete,
        child: const Icon(Icons.delete),
      ),
    );
  }
}










