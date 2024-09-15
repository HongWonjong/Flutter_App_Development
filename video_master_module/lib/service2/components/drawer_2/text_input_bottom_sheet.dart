import 'package:flutter/material.dart';

class TextInputBottomSheet extends StatefulWidget {
  final Function(String, double, bool) onTextAdd; // isEmoji를 추가

  const TextInputBottomSheet({Key? key, required this.onTextAdd}) : super(key: key);

  @override
  _TextInputBottomSheetState createState() => _TextInputBottomSheetState();
}

class _TextInputBottomSheetState extends State<TextInputBottomSheet> {
  TextEditingController _controller = TextEditingController();
  double selectedSize = 0.05; // 기본 사이즈

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("텍스트 입력", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "추가할 텍스트"),
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
            onPressed: () {
              String input = _controller.text.trim();
              if (input.isNotEmpty) {
                // 텍스트와 크기, isEmoji = false 전달
                widget.onTextAdd(input, selectedSize, false);
                Navigator.of(context).pop(); // 바텀 시트 닫기
              }
            },
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }
}



