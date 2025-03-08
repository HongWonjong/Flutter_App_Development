import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import 'draggable_element_widget.dart';

class ChecklistElementWidget extends StatefulWidget {
  final ChecklistElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Function(String) onRemove;
  final Function(String, Offset) onPositionChanged;
  final Function(String, double, double) onSizeChanged;
  final Function(String)? onEdit;
  final Function(ChecklistElement)? onItemsChanged;

  const ChecklistElementWidget({
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
    this.onItemsChanged,
  }) : super(key: key);

  @override
  State<ChecklistElementWidget> createState() => _ChecklistElementWidgetState();
}

class _ChecklistElementWidgetState extends State<ChecklistElementWidget> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, dynamic>>.from(
      widget.element.items.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  @override
  void didUpdateWidget(ChecklistElementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element != widget.element) {
      _items = List<Map<String, dynamic>>.from(
        widget.element.items.map((item) => Map<String, dynamic>.from(item)),
      );
    }
  }

  void _toggleCheckbox(int index) {
    setState(() {
      _items[index]['checked'] = !_items[index]['checked'];
    });

    final updatedElement = ChecklistElement(
      id: widget.element.id,
      items: _items,
      xFactor: widget.element.xFactor,
      yFactor: widget.element.yFactor,
      width: widget.element.width,
      height: widget.element.height,
    );

    if (widget.onItemsChanged != null) {
      widget.onItemsChanged!(updatedElement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableElementWidget(
      element: widget.element,
      width: widget.width,
      height: widget.height,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      onRemove: widget.onRemove,
      onPositionChanged: widget.onPositionChanged,
      onSizeChanged: widget.onSizeChanged,
      onEdit: widget.onEdit,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
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
                  Icons.checklist,
                  color: widget.textColor.withOpacity(0.7),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '체크리스트',
                  style: TextStyle(
                    color: widget.textColor.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _toggleCheckbox(index),
                          child: Icon(
                            item['checked']
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: item['checked']
                                ? Colors.green
                                : widget.textColor.withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['text'],
                            style: TextStyle(
                              color: widget.textColor,
                              decoration: item['checked']
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: Colors.grey,
                            ),
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
