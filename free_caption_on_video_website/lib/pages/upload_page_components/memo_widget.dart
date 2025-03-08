import 'package:flutter/material.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';

class MemoWidget extends StatelessWidget {
  const MemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveSizes.h3),
      margin: EdgeInsets.symmetric(vertical: ResponsiveSizes.h5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow[200]!, Colors.yellow[400]!], // 포스트잇 느낌의 밝은 노란색 그라디언트
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.black87,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(4, 4), // 포스트잇이 떠있는 느낌 강화
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(-2, -2), // 하이라이트 효과
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 (핀 느낌의 아이콘과 함께)
          Row(
            children: [
              Icon(
                Icons.push_pin,
                size: ResponsiveSizes.textSize(4),
                color: Colors.redAccent,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              SizedBox(width: ResponsiveSizes.h2),
              Text(
                'Developer\'s Note',
                style: TextStyle(
                  fontSize: ResponsiveSizes.textSize(4),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSizes.h2),
          // 메모 내용
          Text(
                '문의 있으시면 wonhong1996@gmail.com으로 연락 주세요.\n'
                '본 웹사이트는 동영상이나 자막 등을 따로 저장하지 않습니다.',
            style: TextStyle(
              fontSize: ResponsiveSizes.textSize(3),
              color: Colors.black87,
              height: 1.4, // 줄 간격 조정
              fontStyle: FontStyle.italic, // 손글씨 느낌
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveSizes.h2),
          // 서명 느낌의 추가 텍스트
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '- 사용자 여러분에게',
              style: TextStyle(
                fontSize: ResponsiveSizes.textSize(2.5),
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}