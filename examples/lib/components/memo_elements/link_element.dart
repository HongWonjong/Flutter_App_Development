import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import 'draggable_element_widget.dart';

class LinkElementWidget extends StatelessWidget {
  final LinkElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Function(String) onRemove;
  final Function(String, Offset) onPositionChanged;
  final Function(String, double, double) onSizeChanged;
  final Function(String)? onEdit;

  const LinkElementWidget({
    Key? key,
    required this.element,
    this.width = 300.0,
    this.height = 120.0,
    required this.backgroundColor,
    required this.textColor,
    required this.onRemove,
    required this.onPositionChanged,
    required this.onSizeChanged,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final linkColor = Colors.blue.shade700; // 링크는 파란색 유지
    final linkBackground =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.blue.shade900.withOpacity(0.2) // 다크 모드
            : Colors.blue.shade50; // 라이트 모드

    return DraggableElementWidget(
      element: element,
      width: width,
      height: height,
      backgroundColor: linkBackground,
      textColor: textColor,
      onRemove: onRemove,
      onPositionChanged: onPositionChanged,
      onSizeChanged: onSizeChanged,
      onEdit: onEdit,
      child: _buildLinkContent(linkColor),
    );
  }

  Widget _buildLinkContent(Color linkColor) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '링크',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            element.title,
            style: TextStyle(
              color: linkColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              element.url,
              style: TextStyle(color: linkColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
