import 'package:flutter/material.dart';
import 'text_style.dart';

class BigButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final TextStyle? textStyle;
  final Color? buttonColor; // 추가: 버튼 색상을 받을 변수

  const BigButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.textStyle,
    this.buttonColor, // 추가
  });

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double buttonWidth = deviceWidth * 0.95;
    double deviceHeight = MediaQuery.of(context).size.height;
    double buttonHeight = deviceHeight * 0.08;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(buttonColor ?? Colors.white), // 버튼 색상 지정, 없으면 기본값으로 blue 사용
        minimumSize: MaterialStateProperty.all(Size(buttonWidth, buttonHeight)),
        textStyle: MaterialStateProperty.all(AdaptiveText.titleTextStyle(context)),
      ),
      child: Text(buttonText, style: textStyle ?? AdaptiveText.mediumTextStyle(context)),
    );
  }
}
