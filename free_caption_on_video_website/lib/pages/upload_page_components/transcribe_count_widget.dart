import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/services/transcribe_count_service.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';
import 'package:free_caption_on_video_website/providers/transcribe_count_provider.dart';

class TranscribeCountWidget extends ConsumerWidget {
  const TranscribeCountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(transcribeCountProvider);
    final today = ref.watch(todayProvider);

    // 데이터가 null인지 확인
    if (data == null) {
      print('[TranscribeCountWidget] No data or document does not exist');
      return const SizedBox.shrink(); // 데이터 없으면 표시 안 함
    }

    final totalCount = data['total_count'] as int? ?? 0;
    final dailyCounts = data['daily_counts'] as Map<String, dynamic>? ?? {};
    final todayCount = dailyCounts[today] as int? ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(ResponsiveSizes.h2),
      margin: EdgeInsets.symmetric(vertical: ResponsiveSizes.h2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            'Transcription Stats',
            style: TextStyle(
              fontSize: ResponsiveSizes.textSize(4),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveSizes.h2),
          // 누적 사용횟수
          _buildCountRow(
            icon: Icons.all_inclusive,
            label: 'Total Uses',
            count: totalCount,
            color: Colors.white,
          ),
          SizedBox(height: ResponsiveSizes.h2),
          // 오늘 사용횟수
          _buildCountRow(
            icon: Icons.today,
            label: 'Today',
            count: todayCount,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  // 카운트 표시를 위한 재사용 위젯
  Widget _buildCountRow({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveSizes.textSize(4),
          color: color,
        ),
        SizedBox(width: ResponsiveSizes.h2),
        Expanded(
          child: Text(
            '$label: ',
            style: TextStyle(
              fontSize: ResponsiveSizes.textSize(3),
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AnimatedCount(
          count: count,
          duration: const Duration(milliseconds: 800),
          style: TextStyle(
            fontSize: ResponsiveSizes.textSize(3.5),
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '번',
          style: TextStyle(
            fontSize: ResponsiveSizes.textSize(3),
            color: color,
          ),
        ),
      ],
    );
  }
}

// 숫자 애니메이션 위젯
class AnimatedCount extends StatelessWidget {
  final int count;
  final Duration duration;
  final TextStyle style;

  const AnimatedCount({
    super.key,
    required this.count,
    required this.duration,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: IntTween(begin: 0, end: count),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          '$value',
          style: style,
        );
      },
    );
  }
}