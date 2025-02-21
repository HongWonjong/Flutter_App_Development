import 'package:flutter/material.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';

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
        SizedBox(width: ResponsiveSizes.h2),
        Text(
          text,
          style: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
        ),
      ],
    );
  }
}