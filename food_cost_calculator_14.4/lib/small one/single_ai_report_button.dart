import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class SingleReportAnalysisButton extends StatelessWidget {
  final ValueNotifier<List<String>> checkedList;
  final User? user;
  final FirebaseFirestore _firestore;

  SingleReportAnalysisButton({Key? key, required this.checkedList, required this.user, required FirebaseFirestore firestore}) : _firestore = firestore, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 250,
        height: 60,
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
              final reportDoc = await reports.doc(checkedList.value[0]).get();

              // Convert the report data into a single string
              Map<String, dynamic>? reportData = reportDoc.data();
              String prompt = "";
              String reportName = "";
              reportData?.forEach((key, value) {
                if (key == "name") {
                  reportName = value;
                }
                prompt += "$key: $value\n";
              });

              final TextEditingController questionController = TextEditingController();

              bool? shouldSend = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return WillPopScope(
                      onWillPop: () async => false, // Prevent dialog from closing on outside click
                      child: AlertDialog(
                        title: const Text('gpt에게 질문하고 싶은 부분은?'),
                        content: Container(
                          height: 150.0, // Adjust this to change the height of the TextField
                          child: TextField(
                            controller: questionController,
                            decoration: const InputDecoration(hintText: "여기에 질문을 입력하세요"),
                            maxLines: null, // null makes it auto-expand vertically, or set a specific number for maximum lines
                            keyboardType: TextInputType.multiline, // This makes the keyboard more suitable for multiline input
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('취소'),
                            onPressed: () {
                              Navigator.of(context).pop(false);  // Return false when 'Cancel' is clicked
                            },
                          ),
                          TextButton(
                            child: const Text('전송'),
                            onPressed: () {
                              Navigator.of(context).pop(true);  // Return true when 'Submit' is clicked
                            },
                          ),
                        ],
                      ),
                    );
                  }
              );

              if (shouldSend == null || !shouldSend) {
                // If shouldSend is null or false, do not proceed with the report submission
                return;
              }

              String userQuestion = questionController.text;
              if (userQuestion.isNotEmpty) {
                prompt += "\n\n" + userQuestion;
              }

              prompt += "\n\n내가 제공해 준 내용을 바탕으로, 이번 달의 가게 매출이 어떤지 분석해주고 추가로 가게 운영에 도움이 될 너의 조언을 세 줄 정도 적어줘. 대답 시에는 한국말로 문단마다 띄어쓰기 해줘.";

              final gptReplies = _firestore.collection('users').doc(user?.uid).collection('gpt_Replies');
              await gptReplies.add({
                'prompt': prompt,
                'reportName': reportName,
                'parentMessageId': '(Optional) Message ID coming from API to track conversations'
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('서버에 보고서를 전달했습니다. 잠시 후에 AI분석 내역에서 확인하실 수 있습니다.'),
                  duration: Duration(milliseconds: 5000),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
              ),
            ),
            overlayColor: MaterialStateProperty.all(Colors.deepPurpleAccent.withOpacity(0.1)),
          ),
          child: const Text(
            'AI에게 분석 요청(개별 보고서)',
            style: TextStyle(fontSize: 20.0, color: Colors.deepPurpleAccent),
          ),
        ),
      ),
    );
  }
}
