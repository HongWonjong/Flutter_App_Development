import 'package:flutter/material.dart';
import '../../models/app_theme.dart';

class MemoTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Color backgroundColor;
  final Color textColor;
  final String hintText;
  final VoidCallback? onChanged;

  const MemoTextField({
    Key? key,
    required this.controller,
    this.focusNode,
    required this.backgroundColor,
    required this.textColor,
    this.hintText = '메모를 입력하세요',
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
        ),
        style: TextStyle(color: textColor),
        maxLines: null,
        minLines: 15,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (text) {
          if (onChanged != null) {
            onChanged!();
          }
        },
      ),
    );
  }
}
