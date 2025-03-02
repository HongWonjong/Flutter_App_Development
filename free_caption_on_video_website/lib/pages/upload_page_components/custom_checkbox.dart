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
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min, // 불필요한 여백 제거
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: isChecked ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: isChecked ? theme.primaryColor : Colors.grey[400]!,
              width: 2.0,
            ),
            boxShadow: [
              if (isChecked)
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 6.0,
                  spreadRadius: 1.0,
                ),
            ],
          ),
          child: isChecked
              ? const Icon(
            Icons.check,
            size: 18.0,
            color: Colors.white,
          )
              : null,
        ),
        SizedBox(width: ResponsiveSizes.h2),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: ResponsiveSizes.textSize(3),
            color: isChecked ? theme.primaryColor : Colors.grey[600],
            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}