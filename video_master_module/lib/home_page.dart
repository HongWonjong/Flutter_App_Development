import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'service/media_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MediaService _mediaService = MediaService();
  List<File> _mediaFiles = []; // XFile에서 File로 변경
  VideoPlayerController? _videoController;

  // 미디어 선택 및 변환
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
                  title: Text(_mediaFiles[index].path.split('/').last), // 파일 이름만 표시
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
        ],
      ),
    );
  }
}



