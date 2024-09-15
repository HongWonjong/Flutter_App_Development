import 'package:flutter/material.dart';
import 'package:video_master_module/mq_size.dart';
import 'package:video_master_module/service2/function/calculate_color_matrix.dart'; // 매트릭스 계산 함수 임포트
import 'package:video_player/video_player.dart';

class VideoFilter extends StatelessWidget {
  final double brightness;
  final double contrast;
  final double saturation;
  final VideoPlayerController controller;  // 비디오 플레이어 컨트롤러 추가

  const VideoFilter({
    Key? key,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.controller,  // 컨트롤러를 필수로 받도록 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: widthPercentage(context, 100),
        height: heightPercentage(context, 70),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(
            calculateColorMatrix(brightness, contrast, saturation),  // 밝기, 대비, 채도 값 적용
          ),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,  // 비디오 플레이어의 종횡비 유지
            child: VideoPlayer(controller),  // 실제 비디오 플레이어에 필터 적용
          ),
        ),
      ),
    );
  }
}


