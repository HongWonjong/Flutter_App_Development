import 'package:flutter/material.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading; // 로딩 상태 추가 (선택적)

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false, // 기본값 false
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), // 부드러운 전환 유지
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSizes.h2,
            vertical: ResponsiveSizes.h3,
          ), backgroundColor: Colors.transparent,
          textStyle: TextStyle(
            fontSize: ResponsiveSizes.textSize(4.5),
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ), // 기본 배경 제거
          elevation: 0, // 기본 그림자 제거
          // 페이지 흔들림 방지: 애니메이션 효과 최소화
          animationDuration: Duration.zero, // 애니메이션 제거
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.blueAccent.withOpacity(0.8); // 눌렀을 때 어두워짐
              }
              if (states.contains(MaterialState.hovered)) {
                return Colors.blue.withOpacity(0.9); // 호버 시 색상 변화 (웹용)
              }
              return Colors.blueAccent; // 기본 색상
            },
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSizes.h3,
            vertical: ResponsiveSizes.h2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent], // 그라디언트 효과
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4), // 부드러운 그림자
              ),
            ],
          ),
          child: isLoading
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: ResponsiveSizes.h2),
              Text(
                text,
                style: TextStyle(
                  fontSize: ResponsiveSizes.textSize(4.5),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
              : Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveSizes.textSize(4.5),
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}