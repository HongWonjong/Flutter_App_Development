import 'package:flutter/material.dart';

class SelectableFormattedTextWidget extends StatelessWidget { // Gemini Pro의 스타일을 교정한다.
  final String text;

  SelectableFormattedTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _buildFormattedText(text),
    );
  }

  TextSpan _buildFormattedText(String text) {
    List<TextSpan> spans = [];
    bool isBold = false; // 텍스트가 볼드 처리되어야 하는지 추적합니다.
    StringBuffer tempText = StringBuffer();

    for (int i = 0; i < text.length;) {
      if (text.startsWith('**', i)) {
        if (isBold) {
          // 볼드 처리를 종료합니다.
          spans.add(TextSpan(
              text: tempText.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
          tempText.clear();
        } else {
          // 볼드 처리가 시작되기 전의 텍스트를 추가합니다.
          spans.add(TextSpan(text: tempText.toString()));
          tempText.clear();
        }
        isBold = !isBold; // 볼드 상태를 토글합니다.
        i += 2; // '**' 문자를 건너뜁니다.
      } else {
        tempText.write(text[i]);
        i++;
      }
    }

    // 마지막 텍스트 조각을 추가합니다.
    spans.add(TextSpan(
        text: tempText.toString(),
        style: isBold
            ? TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
            : null));

    return TextSpan(children: spans, style: TextStyle(fontSize: 16, color: Colors.black));
  }
}

