import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedomcompass/page/edit_memo_page.dart';

class MemoListWidget extends StatelessWidget {
  const MemoListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: FutureBuilder(
        // Firestore에서 메모 목록을 가져오는 비동기 작업
        future: _getMemoList(),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // 로딩 중일 때 표시할 위젯
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // 에러 발생 시 표시할 위젯
          } else {
            // 메모 목록을 받아온 경우
            List<DocumentSnapshot> memoList = snapshot.data ?? [];

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenHeight * 0.02,
              ),
              padding: EdgeInsets.all(screenHeight * 0.02),
              color: AppColors.listViewBackgroundColor,
              child: ListView.builder(
                itemCount: memoList.length,
                itemBuilder: (context, index) {
                  var memoData = memoList[index].data() as Map<String, dynamic>;
                  var memoContent = memoData['contents'] as String;
                  var memoId = memoList[index].id; // 메모의 고유번호

                  // 처음 10글자만 노출
                  var truncatedContent = memoContent.length <= 10 ? memoContent : '${memoContent.substring(0, 10)}...';

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // 클릭 시 해당 메모의 고유번호를 전달하고 editmemo 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMemoPage(memoId: memoId),
                            ),
                          );
                        },
                        child: ListTile(
                          tileColor: Colors.black,
                          contentPadding: EdgeInsets.all(screenHeight * 0.02),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                truncatedContent,
                                style: TextStyle(fontSize: screenHeight * 0.03, color: AppColors.mainPageButtonTextColor),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.share,
                                  size: screenHeight * 0.03,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // 공유 기능 추가
                                  // 예: Share memo at index
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: screenHeight * 0.02,
                        color: AppColors.memoDividerColor,
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  // Firestore에서 메모 목록을 가져오는 비동기 함수
  Future<List<DocumentSnapshot>> _getMemoList() async {
    // 현재 로그인한 사용자의 UID 가져오기
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    // Firestore에서 메모 목록 가져오기
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('user').doc(uid).collection('memoes').get();
    return querySnapshot.docs;
  }
}



