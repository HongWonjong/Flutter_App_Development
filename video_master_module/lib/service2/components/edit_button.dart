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
        child: Text(
          '편집 & 저장',
          style: TextStyle(
            fontSize: fontSizePercentage(context, MQSize.fontSize6),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


