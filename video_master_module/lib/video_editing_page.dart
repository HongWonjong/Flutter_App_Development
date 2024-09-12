import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'edited_video_screen.dart';

class VideoEditingPage extends StatefulWidget {
  final String videoPath;

  const VideoEditingPage({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoEditingPageState createState() => _VideoEditingPageState();
}

class _VideoEditingPageState extends State<VideoEditingPage> {
  VideoPlayerController? _controller;
  double _startValue = 0;
  double _endValue = 10;
  double _speedValue = 1.0;
  double _brightnessValue = 0.0;
  double _contrastValue = 1.0;
  double _saturationValue = 1.0;
  String? _outputPath;

  @override
  void initState() {
    super.initState();
    _initializeController(widget.videoPath);
  }

  Future<void> _initializeController(String videoPath) async {
    _controller?.dispose(); // 기존 컨트롤러 제거
    _controller = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {
          _endValue = _controller!.value.duration.inSeconds.toDouble();
        });
      });
  }

  Future<void> _applyChangesAndSaveVideo() async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';



    String command = '-i ${widget.videoPath} -ss $_startValue -to $_endValue '
        '-vf "curves=all=\'0/0 0.5/${_contrastValue.toStringAsFixed(2)} 1/1\','
        'colorbalance=rs=${_brightnessValue.toStringAsFixed(2)}:gs=${_brightnessValue.toStringAsFixed(2)}:bs=${_brightnessValue.toStringAsFixed(2)},'
        'hue=s=${_saturationValue.toStringAsFixed(2)},'
        'setpts=${1 / _speedValue}*PTS" '
        '"$outputPath"';











    print('Executing FFmpeg command: $command');

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      // FFmpeg의 실행 로그 출력
      final logs = await session.getAllLogs();
      print('FFmpeg logs:');
      for (var log in logs) {
        print(log.getMessage());
      }

      if (ReturnCode.isSuccess(returnCode)) {
        print('Video saved at: $outputPath');
        setState(() {
          _outputPath = outputPath;
        });
        _playEditedVideo(); // 저장된 비디오를 재생하는 함수 호출
      } else {
        // 실패 시 오류 로그 출력
        final failStackTrace = await session.getFailStackTrace();
        print('Failed to save video. Error: $failStackTrace');
      }
    });
  }





  void _playEditedVideo() {
    if (_outputPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoPath: _outputPath!),
        ),
      );
    }
  }

  Future<void> _refreshPreview() async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.seekTo(Duration(seconds: _startValue.toInt()));
      _controller?.play(); // 동영상 재생
    }
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  ColorFilter _createColorFilter() {
    return ColorFilter.matrix(<double>[
      _contrastValue, 0, 0, 0, _brightnessValue * 255,
      0, _contrastValue, 0, 0, _brightnessValue * 255,
      0, 0, _contrastValue, 0, _brightnessValue * 255,
      0, 0, 0, _saturationValue, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('동영상 에디팅')),
      body: SingleChildScrollView( // 스크롤 가능하도록 추가
        child: Column(
          children: [
            _controller != null && _controller!.value.isInitialized
                ? GestureDetector(
              onTap: _togglePlayPause,
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: ColorFiltered(
                  colorFilter: _createColorFilter(),
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),

            // 시작 시간과 끝 시간을 동시에 설정할 수 있는 RangeSlider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("시작: ${formatDuration(_startValue)}"),
                Text("끝: ${formatDuration(_endValue)}"),
              ],
            ),
            RangeSlider(
              values: RangeValues(
                _startValue,
                _endValue > _controller!.value.duration.inSeconds
                    ? _controller!.value.duration.inSeconds.toDouble()
                    : _endValue,
              ),
              min: 0,
              max: (_controller != null && _controller!.value.isInitialized)
                  ? _controller!.value.duration.inSeconds.toDouble()
                  : 1,
              onChanged: (RangeValues values) {
                if (values.end <=
                    _controller!.value.duration.inSeconds.toDouble()) {
                  setState(() {
                    _startValue = values.start;
                    _endValue = values.end;
                  });
                  _refreshPreview(); // 설정이 변경되면 미리보기 업데이트
                }
              },
            ),

            // 속도 설정 슬라이더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("속도: ${_speedValue.toStringAsFixed(1)}x"),
              ],
            ),
            Slider(
              value: _speedValue,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: "${_speedValue.toStringAsFixed(1)}x",
              onChanged: (value) {
                setState(() {
                  _speedValue = value;
                });
                if (_controller != null && _controller!.value.isInitialized) {
                  _controller!.setPlaybackSpeed(_speedValue); // 재생 속도 설정
                }
              },
            ),

            // 밝기, 대비, 채도 조절 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("밝기: ${_brightnessValue.toStringAsFixed(2)}"),
                Text("대비: ${_contrastValue.toStringAsFixed(1)}"),
                Text("채도: ${_saturationValue.toStringAsFixed(1)}"),
              ],
            ),
            Slider(
              value: _brightnessValue,
              min: -1.0,
              max: 1.0,
              divisions: 20,
              label: "밝기: ${_brightnessValue.toStringAsFixed(2)}",
              onChanged: (value) {
                setState(() {
                  _brightnessValue = value;
                });
              },
            ),
            Slider(
              value: _contrastValue,
              min: 0.0,
              max: 1.0,
              divisions: 5,
              label: "대비: ${_contrastValue.toStringAsFixed(1)}",
              onChanged: (value) {
                setState(() {
                  _contrastValue = value;
                });
              },
            ),
            Slider(
              value: _saturationValue,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              label: "채도: ${_saturationValue.toStringAsFixed(1)}",
              onChanged: (value) {
                setState(() {
                  _saturationValue = value;
                });
              },
            ),

            // 최종 적용 및 저장 버튼
            ElevatedButton(
              onPressed: _applyChangesAndSaveVideo,
              child: const Text('편집 적용 후 저장'),
            ),

            // 저장된 비디오 확인 버튼
            if (_outputPath != null)
              ElevatedButton(
                onPressed: _playEditedVideo,
                child: const Text('저장된 비디오 확인'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  String formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$secs";
  }
}


