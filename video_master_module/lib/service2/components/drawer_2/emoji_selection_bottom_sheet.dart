import 'package:flutter/material.dart';
import 'package:video_master_module/service2/utils/emoji_list.dart';

class EmojiSelectionBottomSheet extends StatefulWidget {
  final Function(String, double) onEmojiAdd;

  const EmojiSelectionBottomSheet({Key? key, required this.onEmojiAdd}) : super(key: key);

  @override
  _EmojiSelectionBottomSheetState createState() => _EmojiSelectionBottomSheetState();
}

class _EmojiSelectionBottomSheetState extends State<EmojiSelectionBottomSheet> {
  List<String> availableEmojis = emojisList; // emoji_list.dart에서 가져온 emojis 리스트 사용
  String? selectedEmoji;
  double selectedSize = 0.05;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 화면 크기에 맞게 최소 크기로 맞춤
        children: [
          const Text("이모티콘 선택", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          // Flexible을 사용하여 스크롤 가능하게 만듦
          Flexible(
            child: GridView.builder(
              shrinkWrap: true, // GridView가 필요로 하는 높이만 차지하도록 설정
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, // 이모티콘 한 줄에 6개씩
              ),
              itemCount: availableEmojis.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedEmoji == availableEmojis[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEmoji = availableEmojis[index];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple.withOpacity(0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        availableEmojis[index],
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                );
              },
            ),
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
                      selectedSize = value;
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
              widget.onEmojiAdd(selectedEmoji!, selectedSize);
              Navigator.of(context).pop(); // 바텀 시트 닫기
            }
                : null, // 선택되지 않으면 비활성화
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }
}





