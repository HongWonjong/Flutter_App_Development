// 새로운 파일: memo_list.dart
import 'package:flutter/material.dart';
import 'package:freedomcompass/style/color.dart';

class MemoListWidget extends StatelessWidget {
  const MemoListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenHeight * 0.02, // 디바이스 높이의 5%
        ),
        padding: EdgeInsets.all(screenHeight * 0.02),
        color: AppColors.listViewBackgroundColor,
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  tileColor: Colors.black, // 검은색 배경
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    'Memo $index',
                    style: TextStyle(fontSize: 60, color: Colors.white),
                  ),
                ),
                Divider(
                  height: screenHeight * 0.02,
                  color: Colors.black, // 검은색 배경과 구분선을 위한 회색 선
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

