import 'package:flutter/material.dart';
import 'package:website/style/media_query_custom.dart';

class BodyPage extends StatefulWidget {
  final String text;
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets margin;
  final EdgeInsets padding;

  BodyPage({
    Key? key,
    required this.text,
    required this.height,
    required this.width,
    this.backgroundColor = Colors.tealAccent,
    this.borderRadius = 10.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  late TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _textStyle = TextStyle(fontSize: MQSize.getDetailHeight2(context));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor, width: widget.borderWidth),
      ),
      margin: widget.margin,
      padding: widget.padding,
      height: widget.height,
      width: widget.width,
      child: Center(
        child: Text(
          widget.text,
          style: _textStyle,
        ),
      ),
    );
  }
}
