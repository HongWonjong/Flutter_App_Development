import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedomcompass/page/edit_memo_page.dart';
import 'package:intl/intl.dart';
import 'share_dialog.dart';

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
                  var createdTime = memoData['createdTime'] as Timestamp; // 메모 생성 시간
                  var editedTime = memoData['lastEditedTime'] as Timestamp?; // 메모 변경 시간

                  // 처음 10글자만 노출
                  var truncatedContent = memoContent.length <= 13 ? memoContent : '${memoContent.substring(0, 13)}...';

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // 클릭 시 해당 메모의 고유번호를 전달하고 editmemo 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute (
                              builder: (context) => EditMemoPage(memoId: memoId),
                            ),
                          );
                        },
                        child: ListTile(
                          tileColor: Colors.black,
                          contentPadding: EdgeInsets.all(screenHeight * 0.01),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    truncatedContent,
                                    style: TextStyle(fontSize: screenHeight * 0.03, color: AppColors.mainPageButtonTextColor),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.share,
                                      size: screenHeight * 0.04,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ShareDialog();
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                'Created at: ${DateFormat('yyyy-MM-dd HH:mm').format(createdTime.toDate())}', // 시간 표시 포맷 설정
                                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.white),
                              ),
                              Text(
                                'Last Edited: ${editedTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(editedTime.toDate()) : 'Not edited yet'}',
                                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.white),
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



