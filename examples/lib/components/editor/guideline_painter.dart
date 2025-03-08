import 'package:flutter/material.dart';

// 가이드라인 페인터 클래스
class GuidelinePainter extends CustomPainter {
  final Color color;
  final double spacing;

  GuidelinePainter({
    required this.color,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // 세로선
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 가로선
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GuidelinePainter oldDelegate) =>
      color != oldDelegate.color || spacing != oldDelegate.spacing;
}

class GuidelineBackground extends StatelessWidget {
  final Color color;
  final double spacing;
  final Widget child;

  const GuidelineBackground({
    Key? key,
    required this.color,
    required this.spacing,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GuidelinePainter(
        color: color,
        spacing: spacing,
      ),
      child: child,
    );
  }
}
