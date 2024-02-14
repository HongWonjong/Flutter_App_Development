import 'package:flutter/material.dart';
import 'package:website/style/color.dart';
import 'package:website/style/language.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:website/function/send_prompt.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:website/function/delete_chat_log.dart';
import 'package:website/component/button/delete_buttons_style.dart';

class ChatLogBox extends StatefulWidget {
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget? child;
  final String title;
  final String deleteDocArg;


  const ChatLogBox({
    Key? key,
    required this.height,
    required this.width,
    this.backgroundColor = AppColors.bodyPageBackground,
    this.borderRadius = 10.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
    this.child,
    required this.title,
    required this.deleteDocArg,
  }) : super(key: key);

  @override
  _ChatLogBoxState createState() => _ChatLogBoxState();
}

class _ChatLogBoxState extends State<ChatLogBox> {
  final TextEditingController _textController = TextEditingController();
  bool isTextEmpty = true;
  String selectedModel = MainPageLan.modelNameGemini;


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
        sendGeminiPromptToFirestore(uid, _textController.text);
      } else if (selectedModel == MainPageLan.modelNameGpt35) {
        sendGPT35PromptToFirestore(uid, _textController.text);
      }
      _textController.clear();
    }
  }

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
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      margin: widget.margin,
      padding: widget.padding,
      height: widget.height,
      width: widget.width,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style:  TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MQSize.getDetailHeight11(context),
                ),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                style: DeleteButtonStyles.getDeleteButtonStyle(context),
                onPressed: () {
                  // "GeminiDoc 삭제" 버튼 클릭 시 확인 다이얼로그 표시
                  showDeleteConfirmationDialog(context, widget.deleteDocArg);
                },
                child: Text(
                  '기록 삭제',
                  style: TextStyle(
                    color: AppColors.whiteTextColor,
                    fontSize: MQSize.getDetailHeight11(context),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}


