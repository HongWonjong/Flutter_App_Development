// body_page.dart
import 'package:flutter/material.dart';

class BodyPage extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final TextStyle textStyle;

  const BodyPage({
    Key? key,
    required this.text,
    required this.height,
    required this.width,
    this.backgroundColor = Colors.grey,
    this.borderRadius = 10.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
    this.textStyle = const TextStyle(fontSize: 20.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      margin: margin,
      padding: padding,
      height: height,
      width: width,
      child: Center(
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }
}
