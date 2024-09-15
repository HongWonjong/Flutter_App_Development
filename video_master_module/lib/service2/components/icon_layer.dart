import 'package:flutter/material.dart';

class IconLayer extends StatefulWidget {
  final List<Map<String, dynamic>> elements; // 전달받은 이모티콘/텍스트 리스트
  final double maxWidth;  // 비디오 에디터의 최대 너비
  final double maxHeight; // 비디오 에디터의 최대 높이

  const IconLayer({
    Key? key,
    required this.elements,
    required this.maxWidth,
    required this.maxHeight,
  }) : super(key: key);

  @override
  _IconLayerState createState() => _IconLayerState();
}

class _IconLayerState extends State<IconLayer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.elements.map((element) {
        return Positioned(
          left: element['position'].dx,  // 요소의 위치
          top: element['position'].dy,   // 요소의 위치
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // 요소의 크기를 기반으로 경계값 설정
                double fontSize = widget.maxHeight * element['size']; // 이모티콘/텍스트 크기 계산
                double newX = element['position'].dx + details.delta.dx;
                double newY = element['position'].dy + details.delta.dy;

                // 경계값에 맞게 위치 제한 (왼쪽, 오른쪽, 위, 아래 경계 설정)
                if (newX < 0) {
                  newX = 0;
                } else if (newX + fontSize > widget.maxWidth) {
                  newX = widget.maxWidth - fontSize;
                }

                if (newY < 0) {
                  newY = 0;
                } else if (newY + fontSize > widget.maxHeight) {
                  newY = widget.maxHeight - fontSize;
                }

                // 위치 업데이트
                element['position'] = Offset(newX, newY);
              });
            },
            child: Text(
              element['content'],
              style: TextStyle(
                fontSize: widget.maxHeight * element['size'],  // 화면 높이에 비례한 크기
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}


