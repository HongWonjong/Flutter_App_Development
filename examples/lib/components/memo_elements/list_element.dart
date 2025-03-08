import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import 'draggable_element_widget.dart';

class ListElementWidget extends StatelessWidget {
  final ListElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Function(String) onRemove;
  final Function(String, Offset) onPositionChanged;
  final Function(String, double, double) onSizeChanged;
  final Function(String)? onEdit;

  const ListElementWidget({
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
    return DraggableElementWidget(
      element: element,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onRemove: onRemove,
      onPositionChanged: onPositionChanged,
      onSizeChanged: onSizeChanged,
      onEdit: onEdit,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  element.isOrdered
                      ? Icons.format_list_numbered
                      : Icons.format_list_bulleted,
                  color: textColor.withOpacity(0.7),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  element.isOrdered ? '순서 있는 목록' : '기본 목록',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: element.items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            element.isOrdered ? '${index + 1}.' : '•',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            element.items[index],
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
