import 'package:flutter/material.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveSizes.h3, vertical: ResponsiveSizes.h2),
        textStyle: TextStyle(fontSize: ResponsiveSizes.textSize(5)),
      ),
      child: Text(text),
    );
  }
}