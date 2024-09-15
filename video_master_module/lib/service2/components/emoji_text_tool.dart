import 'package:flutter/material.dart';

typedef AddEmojiTextCallback = void Function(String content, bool isEmoji, double size);

class EmojiTextDrawer extends StatelessWidget {
  final AddEmojiTextCallback onAdd;

  const EmojiTextDrawer({Key? key, required this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "추가할 텍스트나 이모티콘을 선택하세요",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        // 텍스트 추가 버튼
        ElevatedButton(
          onPressed: () {
            // 사용자 지정 텍스트 추가
            _showTextInputDialog(context, false);
          },
          child: const Text("텍스트 추가"),
        ),
        const SizedBox(height: 10),
        // 이모티콘 추가 버튼
        ElevatedButton(
          onPressed: () {
            // 이모티콘 추가
            _showTextInputDialog(context, true);
          },
          child: const Text("이모티콘 추가"),
        ),
      ],
    );
  }

  // 텍스트나 이모티콘 입력 받는 다이얼로그 표시
  void _showTextInputDialog(BuildContext context, bool isEmoji) {
    TextEditingController _controller = TextEditingController();
    double selectedSize = 0.05; // 기본 사이즈는 화면 높이의 5%

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isEmoji ? "이모티콘 입력" : "텍스트 입력"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 텍스트/이모티콘 입력 필드
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: isEmoji ? "😀, 😎, 🐶 등" : "추가할 텍스트",
                ),
              ),
              const SizedBox(height: 20),
              // 사이즈 선택 드롭다운
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("사이즈 선택: "),
                  DropdownButton<double>(
                    value: selectedSize,
                    items: const [
                      DropdownMenuItem(
                        value: 0.05,
                        child: Text("작음 (5%)"), // 화면 높이의 5%
                      ),
                      DropdownMenuItem(
                        value: 0.10,
                        child: Text("중간 (10%)"), // 화면 높이의 10%
                      ),
                      DropdownMenuItem(
                        value: 0.15,
                        child: Text("큼 (15%)"), // 화면 높이의 15%
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedSize = value;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String input = _controller.text.trim();
                if (input.isNotEmpty) {
                  // 입력한 이모티콘이나 텍스트와 선택한 사이즈 전달
                  onAdd(input, isEmoji, selectedSize);
                  Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                }
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }
}
