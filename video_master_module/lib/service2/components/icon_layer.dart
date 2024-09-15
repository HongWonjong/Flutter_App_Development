import 'package:flutter/material.dart';

class IconLayer extends StatefulWidget {
  final List<Map<String, dynamic>> elements; // 이모티콘/텍스트 정보 리스트
  final double maxWidth;
  final double maxHeight;

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
  int? _selectedIndex; // 선택한 이모티콘의 인덱스 저장

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 아무 곳이나 터치했을 때 X 버튼을 사라지게 함
        setState(() {
          _selectedIndex = null;
        });
      },
      child: Stack(
        children: widget.elements.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> element = entry.value;

          return Positioned(
            left: element['position'].dx,
            top: element['position'].dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                // 이모티콘을 드래그해서 위치 이동
                setState(() {
                  element['position'] = Offset(
                    element['position'].dx + details.delta.dx,
                    element['position'].dy + details.delta.dy,
                  );
                });
              },
              onLongPress: () {
                // 길게 누르면 X 버튼이 나타나도록 설정
                setState(() {
                  _selectedIndex = index; // 선택한 이모티콘의 인덱스 저장
                });
              },
              child: Stack(
                clipBehavior: Clip.none, // X 버튼이 밖으로 나와도 잘리지 않도록 설정
                children: [
                  Text(
                    element['content'],
                    style: TextStyle(
                      fontSize: widget.maxHeight * element['size'], // 텍스트 또는 이모티콘 크기
                    ),
                  ),
                  // 선택된 이모티콘일 때만 X 버튼을 표시
                  if (_selectedIndex == index)
                    Positioned(
                      right: -10,
                      top: -10,
                      child: GestureDetector(
                        onTap: () {
                          // X 버튼을 눌러 삭제
                          setState(() {
                            widget.elements.removeAt(index);
                            _selectedIndex = null; // X 버튼이 사라지도록 초기화
                          });
                        },
                        child: Container(
                          width: 24,  // X 버튼의 고정된 너비
                          height: 24, // X 버튼의 고정된 높이
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}




