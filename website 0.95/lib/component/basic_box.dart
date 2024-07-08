import 'package:flutter/material.dart';
import 'package:website/style/color.dart';

class BasicBox extends StatefulWidget {
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget? child;
  final String title;


  const BasicBox({
    Key? key,
    required this.height,
    required this.width,
    this.backgroundColor = AppColors.bodyPageBackground,
    this.borderRadius = 10.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
    this.child,
    required this.title,
  }) : super(key: key);

  @override
  _BasicBoxState createState() => _BasicBoxState();
}

class _BasicBoxState extends State<BasicBox> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      margin: widget.margin,
      padding: widget.padding,
      height: widget.height,
      width: widget.width,
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}


