import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../small one/custom_appbar.dart';
import './analysis_detail_page.dart';  // Assuming you have a detail page for each analysis result

class AIAnalysisPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  AIAnalysisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(user == null) {
      return const Scaffold(
        appBar: MyAppBar(title: 'AI 분석 내역'),
        body: Center(child: Text('보고서 관련 기능을 위해서 먼저 로그인을 해주세요.', style: TextStyle(fontSize: 17),))
      );
    } else {
      return Scaffold(
        appBar: const MyAppBar(title: 'AI 분석 내역'),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').doc(user?.uid).collection('gpt_Replies').orderBy('status.created_at', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final String createdAt = (doc['status']['created_at'] as Timestamp).toDate().toIso8601String().substring(0, 10);
                  final String reportName = doc['reportName']; // Get the report name

                  // Updated ListTile to a Card for better visual
                  return Card(
                    elevation: 2,  // Elevation for shadow effect
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),  // Rounded border
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),  // Margin for better layout
                    child: ListTile(
                      leading: Icon(Icons.analytics, color: Theme.of(context).primaryColor),  // Icon for visual effect
                      title: Text("대상 보고서: $reportName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),  // Updated style
                      subtitle: Text("작성일자: ${createdAt.toString()}", style: const TextStyle(fontSize: 14)),  // Updated style
                      onTap: () {
                        // Navigate to the detail page and pass the replyData as argument
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AnalysisDetailPage(replyData: doc),
                        ));
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      );
    }
  }
}





