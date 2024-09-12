import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

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
  double _brightnessValue = 0.1;
  double _contrastValue = 1.5;
  double _saturationValue = 1.2;
  String _selectedFilter = "eq=brightness=0.1";  // 초기값 설정
  String? _outputPath;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _endValue = _controller!.value.duration.inSeconds.toDouble();
        });
      });
  }

  // Duration을 시/분/초 형식으로 변환
  String formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$secs";
  }

  Future<void> _editVideo() async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/edited_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // FFmpeg 명령어 생성
    String command = '-i ${widget.videoPath} -ss $_startValue -to $_endValue '
        '-vf "$_selectedFilter" -filter:v "setpts=${1 / _speedValue}*PTS" $outputPath';

    // FFmpeg 명령어와 세션 로그 출력 추가
    print('Executing FFmpeg command: $command');

    // FFmpeg 명령어 실행 및 로그 확인
    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getOutput();
      print('FFmpeg logs: $logs');

      // Null 체크 후, ReturnCode.isSuccess()를 사용해 성공 여부 확인
      if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _outputPath = outputPath;
        });

        // 편집이 완료되면 VideoPlayerScreen으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoPath: outputPath),
          ),
        );
      } else {
        final failLog = await session.getFailStackTrace();
        print('편집 실패: $failLog');
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('동영상 에디팅')),
      body: Column(
        children: [
          _controller != null && _controller!.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
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
              _endValue > _controller!.value.duration.inSeconds ? _controller!.value.duration.inSeconds.toDouble() : _endValue,
            ),
            min: 0,
            max: (_controller != null && _controller!.value.isInitialized)
                ? _controller!.value.duration.inSeconds.toDouble()
                : 1,  // 동영상이 로드되기 전에 1로 설정
            onChanged: (RangeValues values) {
              if (values.end <= _controller!.value.duration.inSeconds.toDouble()) {
                setState(() {
                  _startValue = values.start;
                  _endValue = values.end;
                });
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
            divisions: 15, // 속도를 단계별로 설정
            label: "${_speedValue.toStringAsFixed(1)}x",
            onChanged: (value) {
              setState(() {
                _speedValue = value;
              });
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
            min: 0.0,
            max: 2.0,
            divisions: 20,
            label: "밝기: ${_brightnessValue.toStringAsFixed(2)}",
            onChanged: (value) {
              setState(() {
                _brightnessValue = value;
                _selectedFilter = "eq=brightness=$_brightnessValue:contrast=$_contrastValue:saturation=$_saturationValue";
              });
            },
          ),
          Slider(
            value: _contrastValue,
            min: 0.5,
            max: 3.0,
            divisions: 25,
            label: "대비: ${_contrastValue.toStringAsFixed(1)}",
            onChanged: (value) {
              setState(() {
                _contrastValue = value;
                _selectedFilter = "eq=brightness=$_brightnessValue:contrast=$_contrastValue:saturation=$_saturationValue";
              });
            },
          ),
          Slider(
            value: _saturationValue,
            min: 0.0,
            max: 3.0,
            divisions: 30,
            label: "채도: ${_saturationValue.toStringAsFixed(1)}",
            onChanged: (value) {
              setState(() {
                _saturationValue = value;
                _selectedFilter = "eq=brightness=$_brightnessValue:contrast=$_contrastValue:saturation=$_saturationValue";
              });
            },
          ),

          // 편집 실행 버튼
          ElevatedButton(
            onPressed: _editVideo,
            child: const Text('편집 실행'),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;

  const VideoPlayerScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = VideoPlayerController.file(File(videoPath));

    return Scaffold(
      appBar: AppBar(title: const Text('편집된 동영상 미리보기')),
      body: FutureBuilder(
        future: controller.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

