import 'package:flutter/material.dart';

class EmojiSelectionBottomSheet extends StatefulWidget {
  final Function(String, double, bool) onEmojiAdd;  // isEmoji를 추가

  const EmojiSelectionBottomSheet({Key? key, required this.onEmojiAdd}) : super(key: key);

  @override
  _EmojiSelectionBottomSheetState createState() => _EmojiSelectionBottomSheetState();
}

class _EmojiSelectionBottomSheetState extends State<EmojiSelectionBottomSheet> {
  List<String> emojis = ["😀", "😎", "😂", "😍", "😢", "😡", "🐶", "🐱", "🌟", "🍕"];
  String? selectedEmoji; // 선택된 이모티콘
  double selectedSize = 0.05; // 기본 사이즈

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("이모티콘 선택", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 이모티콘 5개씩 한 줄에 표시
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedEmoji == emojis[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEmoji = emojis[index]; // 선택한 이모티콘 업데이트
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple.withOpacity(0.3) : Colors.transparent, // 선택된 경우 투명 보라색 배경
                    borderRadius: BorderRadius.circular(8.0), // 약간의 테두리 둥글기
                  ),
                  child: Center(
                    child: Text(
                      emojis[index],
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("사이즈 선택: "),
              DropdownButton<double>(
                value: selectedSize,
                items: const [
                  DropdownMenuItem(value: 0.05, child: Text("작음 (5%)")),
                  DropdownMenuItem(value: 0.10, child: Text("중간 (10%)")),
                  DropdownMenuItem(value: 0.15, child: Text("큼 (15%)")),
                ],
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      selectedSize = value; // 선택된 크기 업데이트
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedEmoji != null
                ? () {
              // 이모티콘과 크기, isEmoji = true 전달
              widget.onEmojiAdd(selectedEmoji!, selectedSize, true);
              Navigator.of(context).pop(); // 바텀 시트 닫기
            }
                : null, // 이모티콘 선택하지 않았으면 비활성화
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }
}




