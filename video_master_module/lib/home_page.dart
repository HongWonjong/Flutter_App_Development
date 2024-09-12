import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'service/media_service.dart';
import 'service2/video_editing_page.dart'; // 에디팅 페이지 import

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MediaService _mediaService = MediaService();
  List<File> _mediaFiles = [];
  VideoPlayerController? _videoController;

  // 미디어 선택
  Future<void> _pickMedia() async {
    List<File> media = await _mediaService.pickMedia(context); // File 형식으로 반환
    setState(() {
      _mediaFiles = media;
    });
  }

  // 미디어 병합 및 비디오 재생
  Future<void> _mergeMedia() async {
    String? outputFilePath = await _mediaService.mergeMedia(_mediaFiles); // File을 mergeMedia에 전달
    if (outputFilePath != null) {
      _videoController = VideoPlayerController.file(File(outputFilePath))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  // 이미지 변환 및 에디팅 페이지로 이동
  Future<void> _convertAndGoToEditingPage() async {
    if (_mediaFiles.isEmpty) return;

    // "이미지 변환 중..." 알림창 띄우기
    showDialog(
      context: context,
      barrierDismissible: false, // 변환 중엔 창을 닫지 못하도록 설정
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("이미지를 비디오로 변환 중..."),
            ],
          ),
        );
      },
    );

    // 이미지 -> 동영상 변환
    String? outputFilePath = await _mediaService.mergeMedia(_mediaFiles); // 이미지를 동영상으로 변환
    Navigator.pop(context); // 변환이 완료되면 로딩 알림창 닫기

    if (outputFilePath != null) {
      // 동영상 에디팅 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoEditingPage(videoPath: outputFilePath),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Media Picker & Merger"),
      ),
      body: Column(
        children: [
          _mediaFiles.isNotEmpty
              ? Expanded(
            child: ListView.builder(
              itemCount: _mediaFiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_mediaFiles[index].path.split('/').last),
                  subtitle: Text(_mediaFiles[index].path),
                );
              },
            ),
          )
              : const Text("No media selected."),
          _videoController != null && _videoController!.value.isInitialized
              ? AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          )
              : const SizedBox(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickMedia,
            child: const Text("Pick Media"),
          ),
          ElevatedButton(
            onPressed: _mergeMedia,
            child: const Text("Merge & Preview"),
          ),
          ElevatedButton(
            onPressed: _convertAndGoToEditingPage,
            child: const Text("Convert & Go to Editing Page"),
          ), // 새로운 버튼 추가
        ],
      ),
    );
  }
}




