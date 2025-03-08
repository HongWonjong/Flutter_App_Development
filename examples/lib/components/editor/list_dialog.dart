import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';

class ListDialog extends StatefulWidget {
  final AppTheme theme;
  final Function(ListElement) onSave;
  final List<String>? initialItems;
  final bool? initialIsOrdered;

  const ListDialog({
    Key? key,
    required this.theme,
    required this.onSave,
    this.initialItems,
    this.initialIsOrdered,
  }) : super(key: key);

  @override
  State<ListDialog> createState() => _ListDialogState();
}

class _ListDialogState extends State<ListDialog> {
  late bool isOrdered;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    isOrdered = widget.initialIsOrdered ?? false;

    // 초기값이 있으면 사용하고, 없으면 빈 항목 하나로 시작
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      controllers = widget.initialItems!
          .map((item) => TextEditingController(text: item))
          .toList();
    } else {
      controllers = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme.textColor;
    final backgroundColor = widget.theme.backgroundColor;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('목록', style: TextStyle(color: textColor)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('기본 목록'),
                  selected: !isOrdered,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        isOrdered = false;
                      });
                    }
                  },
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: !isOrdered ? Colors.white : textColor,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('순서 있는 목록'),
                  selected: isOrdered,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        isOrdered = true;
                      });
                    }
                  },
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: isOrdered ? Colors.white : textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          isOrdered ? '${index + 1}.' : '•',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controllers[index],
                          style: TextStyle(color: textColor),
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
                        onPressed: controllers.length > 1
                            ? () {
                                setState(() {
                                  controllers[index].dispose();
                                  controllers.removeAt(index);
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
                  controllers.add(TextEditingController());
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
            final nonEmptyItems = controllers
                .map((controller) => controller.text.trim())
                .where((text) => text.isNotEmpty)
                .toList();

            if (nonEmptyItems.isNotEmpty) {
              final listElement = ListElement(
                id: const Uuid().v4(),
                items: nonEmptyItems,
                isOrdered: isOrdered,
                xFactor: 0.1,
                yFactor: 0.3,
                width: 300.0,
                height: 200.0,
              );

              widget.onSave(listElement);
              Navigator.pop(context);
            }
          },
          child: Text('저장', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
