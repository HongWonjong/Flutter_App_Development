import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_picker_widget/media_picker_widget.dart';

class MediaPickerService {
  Future<List<File>> pickMedia(BuildContext context) async {
    List<Media> mediaList = [];

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return MediaPicker(
          mediaList: mediaList,
          onPicked: (selectedList) {
            mediaList = selectedList;
            Navigator.pop(context); // 종료
          },
          onCancel: () => Navigator.pop(context),
          mediaCount: MediaCount.multiple,  // 여러 파일 선택 가능
          mediaType: MediaType.all,  // 이미지와 동영상 모두 선택
          decoration: PickerDecoration(),
        );
      },
    );

    return mediaList.map((media) => media.file).whereType<File>().toList();
  }
}
