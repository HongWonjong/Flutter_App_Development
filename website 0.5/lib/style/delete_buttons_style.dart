import 'package:flutter/material.dart';
import 'media_query_custom.dart';

class DeleteButtonStyles {
  static ButtonStyle getDeleteButtonStyle(BuildContext context) {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // 원하는 모서리 반지름 설정
        ),
      ),
      iconSize: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return MQSize.getDetailHeight3(context) * 0.9; // 버튼이 눌렸을 때 크기
          } else {
            return MQSize.getDetailHeight3(context); // 기본 크기
          }
        },
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.red[200]!; // 버튼이 눌렸을 때 배경 색상
          } else {
            return Colors.red; // 기본 배경 색상
          }
        },
      ),
      iconColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          return Colors.white; // 아이콘 색상
        },
      ),
    );
  }
}



