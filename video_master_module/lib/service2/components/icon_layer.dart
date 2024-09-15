import 'package:flutter/material.dart';

class IconLayer extends StatefulWidget {
  final List<Map<String, dynamic>> elements; // 이모티콘/텍스트 정보 리스트
  final double maxWidth;
  final double maxHeight;
  final Function(int, Offset) onPositionChanged; // 위치 변경 콜백

  const IconLayer({
    Key? key,
    required this.elements,
    required this.maxWidth,
    required this.maxHeight,
    required this.onPositionChanged,  // 콜백 추가
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
        // 아무 곳이나 터치했을 때 선택 해제
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
                // 새로운 좌표 계산
                double newX = element['position'].dx + details.delta.dx;
                double newY = element['position'].dy + details.delta.dy;

                // 좌표가 비디오 크기를 넘지 않도록 제한 (clamp)
                newX = newX.clamp(0.0, widget.maxWidth - (widget.maxHeight * element['size']));
                newY = newY.clamp(0.0, widget.maxHeight - (widget.maxHeight * element['size']));

                Offset newPosition = Offset(newX, newY);

                // 콜백을 호출해서 상위 위젯에서 위치를 업데이트
                widget.onPositionChanged(index, newPosition);

                setState(() {
                  // 선택한 이모티콘의 위치를 업데이트 (로컬 상태)
                  widget.elements[index]['position'] = newPosition;
                });
              },
              onLongPress: () {
                // 길게 누르면 선택된 상태로 X 버튼 나타남
                setState(() {
                  _selectedIndex = index;
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
                      right: widget.maxHeight * element['size'] * 0.7,
                      top: -10,
                      child: GestureDetector(
                        onTap: () {
                          // X 버튼을 눌러 삭제
                          setState(() {
                            widget.elements.removeAt(index); // 이모티콘 삭제
                            _selectedIndex = null; // X 버튼이 사라지도록 초기화
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.8),
                          ),
                          padding: const EdgeInsets.all(4),
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







