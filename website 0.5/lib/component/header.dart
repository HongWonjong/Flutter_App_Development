// header_page.dart
import 'package:flutter/material.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:website/style/color.dart';

class HeaderPage extends StatefulWidget {
  final List<String> imagePaths;
  final String textYouWant;
  final double imageHeight;
  final double imageWidth;
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const HeaderPage({
    Key? key,
    required this.imagePaths,
    required this.textYouWant,
    required this.imageHeight,
    required this.imageWidth,
    required this.height,
    required this.width,
    this.backgroundColor = AppColors.bodyPageBackground,
    this.borderRadius = 10.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  _HeaderPageState createState() => _HeaderPageState();
}

class _HeaderPageState extends State<HeaderPage> {
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
      child: Row(
        children: [
          for (String imagePath in widget.imagePaths)
            SizedBox(
              child: Image.asset(
                imagePath,
                height: widget.imageHeight,
                width: widget.imageWidth,
              ),
            ),
          Expanded(
            child: Text(
              widget.textYouWant,
              style: TextStyle(
                fontSize: MQSize.getDetailHeight11(context),
                // Adjust the fontSize according to your preference
              ),
            ),
          ),
        ],
      ),
    );
  }
}

