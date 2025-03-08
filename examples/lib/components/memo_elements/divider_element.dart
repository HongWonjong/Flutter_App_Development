import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import 'draggable_element_widget.dart';

class DividerElementWidget extends StatelessWidget {
  final DividerElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Function(String) onRemove;
  final Function(String, Offset) onPositionChanged;
  final Function(String, double, double) onSizeChanged;
  final Function(String)? onEdit;

  const DividerElementWidget({
    Key? key,
    required this.element,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.textColor,
    required this.onRemove,
    required this.onPositionChanged,
    required this.onSizeChanged,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 구분선 색상 - 기본값은 검은색
    final dividerColor = element.color ?? Colors.black.withOpacity(0.8);

    return DraggableElementWidget(
      element: element,
      width: width,
      height: height,
      backgroundColor: Colors.transparent, // 완전히 투명한 배경
      textColor: textColor,
      onRemove: onRemove,
      onPositionChanged: onPositionChanged,
      onSizeChanged: onSizeChanged,
      onEdit: onEdit,
      // 순수한 직선만 표시 (터치 패딩 추가)
      child: Container(
        // 터치 영역을 위한 패딩 추가
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        color: Colors.transparent, // 패딩 영역은 투명
        child: Center(
          child: Container(
            // 방향에 따라 크기 설정
            width: element.isVertical ? element.thickness : double.infinity,
            height: element.isVertical ? double.infinity : element.thickness,
            color: dividerColor, // 선 색상
          ),
        ),
      ),
    );
  }
}
