import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

              // ignore: use_build_context_synchronously
              bool? shouldSend = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return WillPopScope(
                      onWillPop: () async => false, // Prevent dialog from closing on outside click
                      child: AlertDialog(
                        title: const Text('gpt에게 질문하고 싶은 부분은?'),
                        content: Container(
                          height: 150.0,
                          child: TextField(
                            controller: questionController,
                            decoration: const InputDecoration(
                              hintText: "여기에 질문을 입력하세요",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
                              ),
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('취소'),
                            style: TextButton.styleFrom(
                              primary: Colors.deepPurpleAccent,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('전송'),
                            style: TextButton.styleFrom(
                              primary: Colors.deepPurpleAccent,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      )
                    );
                  }
              );

              if (shouldSend == null || !shouldSend) {
                // If shouldSend is null or false, do not proceed with the report submission
                return;
              }

              String userQuestion = questionController.text;
              if (userQuestion.isNotEmpty) {
                prompt += "\n\n$userQuestion";
              }

              prompt += "\n\n 니가 자영업자에게 500자 이내로 매출분석을 해주는 회계사라고 생각해. 앞의 내용을 바탕으로 현재 가게 운영의 장점과 단점을 말해줘. 대답 시 한국말로 문단마다 띄어쓰기 해줘. 지금까지 기본 설정이었고, 이 다음 내용은 실제 사용자의 질문이니까 질문이 적힌 경우 장점과 단점은 생략하고 그걸 중점으로 답해줘.";

              final gptReplies = _firestore.collection('users').doc(user?.uid).collection('gpt_Replies');
              await gptReplies.add({
                'prompt': prompt,
                'reportName': reportName,
                'parentMessageId': '(Optional) Message ID coming from API to track conversations'
              });
              // ignore: use_build_context_synchronously
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
