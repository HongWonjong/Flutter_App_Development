import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';
import 'draggable_element_widget.dart';

class CodeElementWidget extends StatelessWidget {
  final CodeElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Function(String) onRemove;
  final Function(String, Offset) onPositionChanged;
  final Function(String, double, double) onSizeChanged;
  final Function(String)? onEdit;

  const CodeElementWidget({
    Key? key,
    required this.element,
    this.width = 300.0,
    this.height = 200.0,
    required this.backgroundColor,
    required this.textColor,
    required this.onRemove,
    required this.onPositionChanged,
    required this.onSizeChanged,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 코드 블록은 약간 어두운 배경
    final codeBackground =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.grey[800] // 다크 모드면 약간 밝은 회색
            : Colors.grey[200]; // 라이트 모드면 약간 어두운 회색

    return DraggableElementWidget(
      element: element,
      width: width,
      height: height,
      backgroundColor: codeBackground ?? backgroundColor,
      textColor: textColor,
      onRemove: onRemove,
      onPositionChanged: onPositionChanged,
      onSizeChanged: onSizeChanged,
      onEdit: onEdit,
      child: _buildCodeContent(),
    );
  }

  Widget _buildCodeContent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (element.language.isNotEmpty &&
              element.language != 'text' &&
              element.language != 'plain')
            Text(
              element.language,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                element.code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
