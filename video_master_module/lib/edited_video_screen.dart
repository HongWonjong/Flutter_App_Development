import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _controller.play(); // 자동 재생
          _isPlaying = true;  // 초기 상태를 재생 중으로 설정
        });
        _controller!.addListener(() {
          // 비디오가 끝났을 때 자동으로 처음으로 돌아가기
          if (_controller!.value.position >= _controller!.value.duration) {
            setState(() {
              _isPlaying = false;  // 재생 상태 업데이트
            });
            _controller!.seekTo(Duration.zero);  // 처음으로 되돌리기
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // 클릭 시 재생/정지 토글
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('저장된 비디오')),
      body: _controller.value.isInitialized
          ? GestureDetector(
        onTap: _togglePlayPause,  // 클릭 시 재생/정지
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      )
          : const Center(child: CircularProgressIndicator()),  // 비디오 로딩 중일 때
    );
  }
}
