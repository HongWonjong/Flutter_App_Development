import 'package:flutter/material.dart';

class LoadingDonut extends StatelessWidget {
  final double size;
  final Color color;
  final Color backgroundColor;

  const LoadingDonut({
    Key? key,
    this.size = 100,
    this.color = Colors.white70,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 8,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
