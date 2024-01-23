import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedomcompass/page/edit_memo_page.dart';
import 'package:intl/intl.dart';
import 'share_dialog.dart';
import 'delete_dialog.dart';

class MemoListWidget extends StatefulWidget {
  const MemoListWidget({Key? key}) : super(key: key);

  @override
  _MemoListWidgetState createState() => _MemoListWidgetState();
}

class _MemoListWidgetState extends State<MemoListWidget> {
  late Future<List<DocumentSnapshot>> memoListFuture;

  @override
  void initState() {
    super.initState();
    memoListFuture = _getMemoList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: FutureBuilder(
        future: memoListFuture,
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          List<DocumentSnapshot> memoList = snapshot.data ?? [];

          memoList.sort((a, b) {
            var timeA = (a.data() as Map<String, dynamic>)['lastEditedTime'] as Timestamp?;
            var timeB = (b.data() as Map<String, dynamic>)['lastEditedTime'] as Timestamp?;
            timeA ??= (a.data() as Map<String, dynamic>)['createdTime'] as Timestamp;
            timeB ??= (b.data() as Map<String, dynamic>)['createdTime'] as Timestamp;

            return timeB.compareTo(timeA);
          });

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
                var memoId = memoList[index].id;
                var createdTime = memoData['createdTime'] as Timestamp;
                var editedTime = memoData['lastEditedTime'] as Timestamp?;

                var truncatedContent = memoContent.length <= 13 ? memoContent : '${memoContent.substring(0, 13)}...';

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMemoPage(memoId: memoId),
                          ),
                        ).then((_) {
                          // 메모가 수정된 경우 다시 불러오기
                          setState(() {
                            memoListFuture = _getMemoList();
                          });
                        });
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
                                    Icons.delete,
                                    size: screenHeight * 0.04,
                                    color: AppColors.mainPageButtonTextColor,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) => DeleteDialog(memoId: memoId),
                                    ).then((_) {
                                      // 메모가 삭제된 경우 다시 불러오기
                                      setState(() {
                                        memoListFuture = _getMemoList();
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                            Text(
                              '${mainpage_lan.createdTime}: ${DateFormat('yyyy-MM-dd HH:mm').format(createdTime.toDate())}',
                              style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.white),
                            ),
                            Text(
                              '${mainpage_lan.lastEditedTime}: ${editedTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(editedTime.toDate()) : mainpage_lan.notEditedYet}',
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

  Future<List<DocumentSnapshot>> _getMemoList() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('user').doc(uid).collection('memoes').get();
    return querySnapshot.docs;
  }
}





