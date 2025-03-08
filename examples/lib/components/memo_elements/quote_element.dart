import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import 'draggable_element_widget.dart';

class QuoteElementWidget extends StatelessWidget {
  final QuoteElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Function(String) onRemove;
  final Function(String, Offset) onPositionChanged;
  final Function(String, double, double) onSizeChanged;
  final Function(String)? onEdit;

  const QuoteElementWidget({
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
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1.0,
          ),
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
                  Icons.format_quote,
                  color: textColor.withOpacity(0.7),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '인용구',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.blue.withOpacity(0.7),
                      width: 3.0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          element.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    if (element.source != null && element.source!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          '- ${element.source}',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
