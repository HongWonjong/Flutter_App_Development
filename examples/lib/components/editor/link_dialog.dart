import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';

class LinkDialog extends StatefulWidget {
  final AppTheme theme;
  final Function(LinkElement) onSave;
  final String? initialUrl;
  final String? initialTitle;

  const LinkDialog({
    Key? key,
    required this.theme,
    required this.onSave,
    this.initialUrl,
    this.initialTitle,
  }) : super(key: key);

  @override
  State<LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<LinkDialog> {
  late TextEditingController urlController;
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(text: widget.initialUrl ?? '');
    titleController = TextEditingController(text: widget.initialTitle ?? '');
  }

  @override
  void dispose() {
    urlController.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme.textColor;
    final backgroundColor = widget.theme.backgroundColor;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('링크', style: TextStyle(color: textColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: urlController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'URL',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              hintText: 'https://',
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
            controller: titleController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: '제목',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              hintText: '링크 제목을 입력하세요',
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
            final url = urlController.text.trim();
            if (url.isNotEmpty) {
              final linkElement = LinkElement(
                id: const Uuid().v4(),
                url: url,
                title: titleController.text.trim(),
                xFactor: 0.1,
                yFactor: 0.3,
                width: 300.0,
                height: 100.0,
              );

              widget.onSave(linkElement);
              Navigator.pop(context);
            }
          },
          child: Text('저장', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
