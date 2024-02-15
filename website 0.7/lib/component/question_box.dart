import 'package:flutter/material.dart';
import 'package:website/style/color.dart';
import 'package:website/style/language.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:website/function/send_prompt.dart';
import 'model_choice_dropdown.dart';

class QBox extends StatefulWidget {
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const QBox({
    Key? key,
    required this.height,
    required this.width,
    this.backgroundColor = AppColors.bodyPageBackground,
    this.borderRadius = 10.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  _QBoxState createState() => _QBoxState();
}

class _QBoxState extends State<QBox> {
  final TextEditingController _textController = TextEditingController();
  bool isTextEmpty = true;
  String selectedModel = MainPageLan.modelNameGemini; // 추가: 선택된 모델을 저장할 변수
  bool showAIPreparingMessage = false; // AI 답변 준비 메시지를 보여줄지 결정하는 상태 변수


  @override
  void initState() {
    super.initState();
    _textController.text = ""; // 초기 상태에서 텍스트 컨트롤러를 빈 문자열로 설정
    _textController.addListener(() {
      setState(() {
        isTextEmpty = _textController.text.isEmpty;
      });
    });
  }


  void sendPromptToModel() {
    if (!isTextEmpty) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String promptText = _textController.text; // 메시지 내용을 변수에 저장

      setState(() {
        showAIPreparingMessage = true; // AI 준비 메시지 활성화
        isTextEmpty = true;
      });

      if (selectedModel == MainPageLan.modelNameGemini) {
        // Gemini Pro 선택 시
        sendPromptToFirestore(
            uid: uid,
            text: _textController.text,
            pointCost: 1,
            docId: FunctionLan.geminiDoc,
            messageFieldName: 'prompt',
            titleLength: 15
        );
      } else if (selectedModel == MainPageLan.modelNameGpt35) {
        // GPT 3.5 선택 시
        sendPromptToFirestore(
            uid: uid,
            text: _textController.text,
            pointCost: 2,
            docId: FunctionLan.gpt35Doc,
            messageFieldName: 'gpt35_prompt',
            titleLength: 15
        );
      } else if (selectedModel == MainPageLan.modelNameGpt4) {
        // GPT 4 선택 시
        sendPromptToFirestore(
            uid: uid,
            text: _textController.text,
            pointCost: 10,
            docId: FunctionLan.gpt4Doc,
            messageFieldName: 'gpt4_prompt',
            titleLength: 15
        );
      }
      else if (selectedModel == MainPageLan.modelNamePalm) {
        // GPT 4 선택 시
        sendPromptToFirestore(
            uid: uid,
            text: _textController.text,
            pointCost: 1,
            docId: FunctionLan.palmDoc,
            messageFieldName: 'palm_prompt',
            titleLength: 15
        );
      }

      // Optionally, you can clear the text field after sending the message
      _textController.clear();
      Future.delayed(const Duration(seconds: 4), () {
        setState(() {
          showAIPreparingMessage = false; // AI 준비 메시지 비활성화
        });
      });
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
        border: Border.all(color: widget.borderColor, width: widget.borderWidth),
      ),
      margin: widget.margin,
      padding: widget.padding,
      height: widget.height,
      width: widget.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 수정: 드롭다운 메뉴를 위젯으로 분리하여 사용
            Row(
              children: [
                CustomDropdown(
                  selectedModel: selectedModel,
                  onChanged: onDropdownChanged,
                ),
              ],
            ),

            // 기존 코드는 그대로 유지
            Row(
              children: [
                Expanded(
                  flex: 95,
                  child: TextFormField(
                    minLines: null,
                    maxLines: null,
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: MainPageLan.hintText,
                      border: OutlineInputBorder(),
                      fillColor: Colors.white, // 흰색 배경색 추가
                      filled: true, // 배경색 채우기 활성화
                    ),
                  ),
                ),
                SizedBox(width: MQSize.getDetailWidth01(context)),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return isTextEmpty ? Colors.white24 : Colors.white;
                      },
                    ),
                  ),
                  onPressed: isTextEmpty
                      ? null // 버튼 비활성화 상태
                      : () {
                    sendPromptToModel();
                    setState(() {
                      isTextEmpty = true; // 상태를 갱신하여 버튼이 다시 비활성화되도록 함
                    });
                    _textController.clear();
                  },
                  child: const Text(MainPageLan.sendMessage, style: TextStyle(color: AppColors.textColor)),
                ),
              ],
            ),
            Row(
              children: [
                if (showAIPreparingMessage) // 조건부 위젯 렌더링
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("AI가 답변을 하는 중입니다.. 아래의 대답 내역에 곧 생성됩니다."),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




