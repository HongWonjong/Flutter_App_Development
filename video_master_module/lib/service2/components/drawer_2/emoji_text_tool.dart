import 'package:flutter/material.dart';
import 'text_input_bottom_sheet.dart';
import 'emoji_selection_bottom_sheet.dart';

typedef AddEmojiTextCallback = void Function(String content, double size);

class EmojiTextDrawer extends StatelessWidget {
  final AddEmojiTextCallback onAdd;

  const EmojiTextDrawer({Key? key, required this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // 텍스트 추가를 위한 바텀 시트 호출
            showModalBottomSheet(
              context: context,
              builder: (context) => TextInputBottomSheet(
                onTextAdd: (text, size) {
                  onAdd(text, size); // 텍스트 추가 (isEmoji = false)
                },
              ),
            );
          },
          child: const Text("텍스트 추가"),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // 이모티콘 추가를 위한 바텀 시트 호출
            showModalBottomSheet(
              context: context,
              builder: (context) => EmojiSelectionBottomSheet(
                onEmojiAdd: (emoji, size) {
                  onAdd(emoji, size); // 이모티콘 추가 (isEmoji = true)
                },
              ),
            );
          },
          child: const Text("이모티콘 추가"),
        ),
      ],
    );
  }
}




