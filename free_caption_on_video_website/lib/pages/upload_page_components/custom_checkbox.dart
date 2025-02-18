import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final String text;

  const CustomCheckbox({
    super.key,
    required this.isChecked,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: null, // 비활성화
          checkColor: Colors.white,
          activeColor: Colors.green,
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}