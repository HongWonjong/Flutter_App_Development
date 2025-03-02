import 'package:flutter/material.dart';
import 'ascii_animation.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isVisible;

  const LoadingOverlay({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return IgnorePointer(
      child: Container(
        color: Colors.black.withOpacity(0.2), // 반투명 배경
        width: double.infinity, // 전체 너비
        height: double.infinity, // 전체 높이
        child: Center( // 화면 정 중앙으로 변경
          child: const ASCIIAnimation(), // 크기 조정 없이 그대로 사용
        ),
      ),
    );
  }
}