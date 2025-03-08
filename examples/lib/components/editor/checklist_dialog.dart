import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';

class ChecklistDialog extends StatefulWidget {
  final AppTheme theme;
  final Function(ChecklistElement) onSave;
  final List<Map<String, dynamic>>? initialItems;

  const ChecklistDialog({
    Key? key,
    required this.theme,
    required this.onSave,
    this.initialItems,
  }) : super(key: key);

  @override
  State<ChecklistDialog> createState() => _ChecklistDialogState();
}

class _ChecklistDialogState extends State<ChecklistDialog> {
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    // 초기값이 있으면 사용하고, 없으면 빈 항목 하나로 시작
    items = widget.initialItems != null
        ? List<Map<String, dynamic>>.from(
            widget.initialItems!.map((item) => Map<String, dynamic>.from(item)),
          )
        : [
            {'text': '', 'checked': false}
          ];
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme.textColor;
    final backgroundColor = widget.theme.backgroundColor;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('체크리스트', style: TextStyle(color: textColor)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Checkbox(
                        value: items[index]['checked'] as bool,
                        onChanged: (value) {
                          setState(() {
                            items[index]['checked'] = value ?? false;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                              text: items[index]['text'] as String)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(
                                  offset:
                                      (items[index]['text'] as String).length),
                            ),
                          style: TextStyle(color: textColor),
                          onChanged: (value) {
                            items[index]['text'] = value;
                          },
                          decoration: InputDecoration(
                            hintText: '항목 ${index + 1}',
                            hintStyle:
                                TextStyle(color: textColor.withOpacity(0.5)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.redAccent),
                        onPressed: items.length > 1
                            ? () {
                                setState(() {
                                  items.removeAt(index);
                                });
                              }
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.add, color: Colors.blue),
              label: Text('항목 추가', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                setState(() {
                  items.add({'text': '', 'checked': false});
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            // 비어있지 않은 항목만 필터링
            final nonEmptyItems = items
                .where((item) => (item['text'] as String).isNotEmpty)
                .toList();

            if (nonEmptyItems.isNotEmpty) {
              final checklistElement = ChecklistElement(
                id: const Uuid().v4(),
                items: nonEmptyItems,
                xFactor: 0.1,
                yFactor: 0.3,
                width: 300.0,
                height: 200.0,
              );

              widget.onSave(checklistElement);
              Navigator.pop(context);
            }
          },
          child: Text('저장', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
