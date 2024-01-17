import 'package:flutter/material.dart';

class ChatInputWidget extends StatefulWidget {
  const ChatInputWidget({Key? key}) : super(key: key);

  @override
  _ChatInputWidgetState createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double inputHeight = deviceHeight * 0.1; // 디바이스 높이의 10%

    return Container(
      height: inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // 메시지 전송 로직 추가
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  // TODO: 실제 메시지 전송 로직을 구현하세요.
  void _sendMessage() {
    String message = _messageController.text;
    // 메시지 전송 로직을 여기에 추가하세요.
    // 예: 채팅방에 메시지 추가 또는 서버로 메시지 전송
    print('전송된 메시지: $message');

    // 메시지 전송 후 텍스트 필드 초기화
    _messageController.clear();
  }
}

