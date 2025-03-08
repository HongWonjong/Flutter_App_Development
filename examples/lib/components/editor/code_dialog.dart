import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';

class CodeDialog extends StatefulWidget {
  final AppTheme theme;
  final Function(CodeElement) onSave;
  final String? initialCode;
  final String? initialLanguage;

  const CodeDialog({
    Key? key,
    required this.theme,
    required this.onSave,
    this.initialCode,
    this.initialLanguage,
  }) : super(key: key);

  @override
  State<CodeDialog> createState() => _CodeDialogState();
}

class _CodeDialogState extends State<CodeDialog> {
  late TextEditingController codeController;
  late TextEditingController languageController;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(text: widget.initialCode ?? '');
    languageController =
        TextEditingController(text: widget.initialLanguage ?? '');
  }

  @override
  void dispose() {
    codeController.dispose();
    languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme.textColor;
    final backgroundColor = widget.theme.backgroundColor;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('코드', style: TextStyle(color: textColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: languageController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: '언어',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              hintText: 'javascript, python, dart 등',
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
            controller: codeController,
            style: TextStyle(color: textColor, fontFamily: 'monospace'),
            maxLines: 8,
            decoration: InputDecoration(
              labelText: '코드',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              hintText: '코드를 입력하세요',
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
            if (codeController.text.trim().isNotEmpty) {
              final codeElement = CodeElement(
                id: const Uuid().v4(),
                code: codeController.text.trim(),
                language: languageController.text.trim(),
                xFactor: 0.1,
                yFactor: 0.3,
                width: 400.0,
                height: 250.0,
              );

              widget.onSave(codeElement);
              Navigator.pop(context);
            }
          },
          child: Text('저장', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
