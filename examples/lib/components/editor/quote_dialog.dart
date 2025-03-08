import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';

class QuoteDialog extends StatefulWidget {
  final AppTheme theme;
  final Function(QuoteElement) onSave;
  final String? initialText;
  final String? initialSource;

  const QuoteDialog({
    Key? key,
    required this.theme,
    required this.onSave,
    this.initialText,
    this.initialSource,
  }) : super(key: key);

  @override
  State<QuoteDialog> createState() => _QuoteDialogState();
}

class _QuoteDialogState extends State<QuoteDialog> {
  late TextEditingController textController;
  late TextEditingController sourceController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initialText ?? '');
    sourceController = TextEditingController(text: widget.initialSource ?? '');
  }

  @override
  void dispose() {
    textController.dispose();
    sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme.textColor;
    final backgroundColor = widget.theme.backgroundColor;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('인용구', style: TextStyle(color: textColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textController,
            style: TextStyle(color: textColor),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: '인용 내용',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              hintText: '인용할 내용을 입력하세요',
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: textColor.withOpacity(0.3)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: textColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: sourceController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: '출처',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              hintText: '출처를 입력하세요',
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: textColor.withOpacity(0.3)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: textColor),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            if (textController.text.trim().isNotEmpty) {
              final quoteElement = QuoteElement(
                id: const Uuid().v4(),
                text: textController.text.trim(),
                source: sourceController.text.trim(),
                xFactor: 0.1,
                yFactor: 0.3,
                width: 300.0,
                height: 150.0,
              );

              widget.onSave(quoteElement);
              Navigator.pop(context);
            }
          },
          child: Text('저장', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
