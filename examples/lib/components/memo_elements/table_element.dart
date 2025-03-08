import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import 'draggable_element_widget.dart';

class TableElementWidget extends StatelessWidget {
  final TableElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Function(String) onRemove;
  final Function(String, Offset) onPositionChanged;
  final Function(String, double, double) onSizeChanged;
  final Function(String)? onEdit;

  const TableElementWidget({
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
    // 표 배경색
    final tableBackground =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.grey[800] // 다크 모드면 약간 밝은 회색
            : Colors.white; // 라이트 모드면 흰색

    final borderColor =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.grey[600] // 다크 모드면 약간 밝은 회색
            : Colors.grey[400]; // 라이트 모드면 어두운 회색

    return DraggableElementWidget(
      element: element,
      width: width,
      height: height,
      backgroundColor: tableBackground ?? backgroundColor,
      textColor: textColor,
      onRemove: onRemove,
      onPositionChanged: onPositionChanged,
      onSizeChanged: onSizeChanged,
      onEdit: onEdit,
      child: _buildTableContent(borderColor ?? Colors.grey),
    );
  }

  Widget _buildTableContent(Color borderColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                border: TableBorder.all(
                  color: borderColor,
                ),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: element.data.map((row) {
                  return TableRow(
                    children: row.map((cell) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          cell,
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
