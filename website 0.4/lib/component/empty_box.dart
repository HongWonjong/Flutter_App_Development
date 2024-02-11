import 'package:flutter/material.dart';
import 'package:website/style/color.dart';
import 'package:website/style/language.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:website/function/send_prompt.dart';


class EmptyBox extends StatefulWidget {
  final String text;
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;

  const EmptyBox({
    Key? key,
    required this.text,
    required this.height,
    required this.width,
    this.backgroundColor = AppColors.bodyPageBackground,
    this.borderRadius = 10.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
    required this.child,
  }) : super(key: key);

  @override
  _EmptyBoxState createState() => _EmptyBoxState();
}

class _EmptyBoxState extends State<EmptyBox> {
  final TextEditingController _textController = TextEditingController();
  bool isTextEmpty = true;
  String selectedModel = MainPageLan.modelNameGemini; // 추가: 선택된 모델을 저장할 변수

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        isTextEmpty = _textController.text.isEmpty;
      });
    });
  }

  void sendPromptToModel() {
    if (!isTextEmpty) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      if (selectedModel == MainPageLan.modelNameGemini) {
        // Gemini Pro 선택 시
        sendGeminiPromptToFirestore(uid, _textController.text);
      } else if (selectedModel == MainPageLan.modelNameGpt35) {
        // GPT 3.5 선택 시
        sendGPT35PromptToFirestore(uid, _textController.text);
      }
      // 다른 모델 추가 가능
      // ...

      // Optionally, you can clear the text field after sending the message
      _textController.clear();
    }
  }

  // 추가: 드롭다운 값 변경 시 호출되는 함수
  void onDropdownChanged(String? newValue) {
    setState(() {
      selectedModel = newValue!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
            color: widget.borderColor, width: widget.borderWidth),
      ),
      margin: widget.margin,
      padding: widget.padding,
      height: widget.height,
      width: widget.width,
      child: SingleChildScrollView(
        child: widget.child, // 여기에 인자로 받은 다른 위젯을 넣어줍니다.
      ),
    );
  }
}
