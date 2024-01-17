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
                  contentPadding: EdgeInsets.all(screenHeight * 0.02),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Memo $index',
                        style: TextStyle(fontSize: screenHeight * 0.03, color: AppColors.mainPageButtonTextColor),
                      ),
                      IconButton(
                        icon:  Icon(
                          size: screenHeight * 0.03,
                          Icons.share,
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
                Divider(
                  height: screenHeight * 0.02,
                  color: AppColors.memoDividerColor, // 검은색 배경과 구분선을 위한 회색 선
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


