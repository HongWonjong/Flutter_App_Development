import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_master_module/edited_video_screen.dart';
import 'package:video_master_module/mq_size.dart';
import 'brightness_contrast_saturation_control.dart';

class EditButton extends StatelessWidget {

  final VoidCallback applyChangesAndSaveVideo;  // _applyChangesAndSaveVideo를 받는 콜백

  // 생성자에서 콜백 함수(onPressed) 받아오기
  EditButton({required this.applyChangesAndSaveVideo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widthPercentage(context, 5)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(heightPercentage(context, 1)),
          backgroundColor: Colors.deepPurpleAccent.withOpacity(0.4),
        ),
        onPressed: applyChangesAndSaveVideo,
        child: Container(
          padding: const EdgeInsets.all(8.0),  // 아이콘 주위에 패딩 추가
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.4),  // 투명한 빨간색 배경
            shape: BoxShape.circle,  // 배경을 원형으로 설정
          ),
          child: Icon(
            Icons.movie_filter,  // 클랩보드 아이콘
            size: fontSizePercentage(context, MQSize.fontSize15),  // 아이콘 크기 설정
            color: Colors.white,  // 아이콘 색상 설정
          ),
        ),
      ),
    );
  }
}


