import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../edited_video_screen.dart';
import 'package:video_master_module/mq_size.dart';
import 'components/brightness_contrast_saturation_control.dart';

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
  bool _isDrawerOpen = false;

  // Add this
  String _selectedProperty = '밝기'; // Default selected property

  @override
  void initState() {
    super.initState();
    _initializeController(widget.videoPath);
  }

  Future<void> _initializeController(String videoPath) async {
    _controller?.dispose();
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

    String command = '-ss $_startValue -to $_endValue ' // 트림 적용
        '-i ${widget.videoPath} '
        '-vf "curves=all=\'0/0 0.5/${_contrastValue.toStringAsFixed(2)} 1/1\','
        'colorbalance=rs=${_brightnessValue.toStringAsFixed(2)}:gs=${_brightnessValue.toStringAsFixed(2)}:bs=${_brightnessValue.toStringAsFixed(2)},'
        'hue=s=${_saturationValue.toStringAsFixed(2)},'
        'setpts=${1 / _speedValue}*PTS" ' // 배속 적용
        '"$outputPath"';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _outputPath = outputPath;
        });
        _playEditedVideo();
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
  void _onPropertyChanged(String property) {
    setState(() {
      _selectedProperty = property;
    });
  }

  void _onSliderChanged(double value) {
    setState(() {
      if (_selectedProperty == '밝기') {
        _brightnessValue = value;
      } else if (_selectedProperty == '대조') {
        _contrastValue = value;
      } else {
        _saturationValue = value;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Video Editing',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSizePercentage(context, MQSize.fontSize6),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 비디오 플레이어 위치 설정
          Center(
            child: _controller != null && _controller!.value.isInitialized
                ? GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: widthPercentage(context, 100),  // 원하는 크기로 설정
                height: heightPercentage(context, 80), // 원하는 크기로 설정
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
                : Center(
              child: SizedBox(
                width: widthPercentage(context, 10),
                height: widthPercentage(context, 10),
                child: const CircularProgressIndicator(),
              ),
            ),
          ),

          // 슬라이딩 서랍을 위한 AnimatedPositioned 위젯
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _isDrawerOpen ? 0 : -widthPercentage(context, 80),
            top: 0,
            bottom: 0,
            width: widthPercentage(context, 80),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && !_isDrawerOpen) {
                  setState(() {
                    _isDrawerOpen = true;
                  });
                } else if (details.delta.dx < 0 && _isDrawerOpen) {
                  setState(() {
                    _isDrawerOpen = false;
                  });
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 트림 및 속도 컨트롤
                    _buildTrimAndSpeedControls(context),
                    // 밝기/대비/채도 컨트롤
                    BrightnessContrastSaturationControl(
                        selectedProperty: _selectedProperty,
                        brightnessValue: _brightnessValue,
                        contrastValue: _contrastValue,
                        saturationValue: _saturationValue,
                        onPropertyChanged: _onPropertyChanged,
                        onSliderChanged: _onSliderChanged,
                    ),
                    // 저장 버튼
                    _buildSaveButton(context),
                  ],
                ),
              ),
            ),
          ),

          // 드로어 토글 버튼
          Positioned(
            left: _isDrawerOpen ? widthPercentage(context, 80) : widthPercentage(context, 2),
            top: heightPercentage(context, 5),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDrawerOpen = !_isDrawerOpen;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isDrawerOpen
                      ? Colors.transparent // 화살표 아이콘일 때 투명색 배경
                      : Colors.deepPurpleAccent.withOpacity(0.4), // 편집 아이콘일 때 배경색 적용
                  shape: BoxShape.circle, // 원형 배경
                ),
                padding: EdgeInsets.all(widthPercentage(context, 2)), // 아이콘 주위에 패딩 추가
                child: Icon(
                  _isDrawerOpen ? Icons.arrow_back_ios : Icons.cut, // 서랍이 닫혀 있을 때 '편집' 아이콘 표시
                  color: Colors.white,
                  size: widthPercentage(context, 8), // 적응형 크기
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildTrimAndSpeedControls(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widthPercentage(context, 2)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildControlRow(
              '자르기',
              '${formatDuration(_startValue)} - ${formatDuration(_endValue)}',
              RangeSlider(
                values: RangeValues(_startValue, _endValue),
                min: 0,
                max: _controller?.value.duration.inSeconds.toDouble() ?? 1,
                onChanged: (RangeValues values) {
                  setState(() {
                    _startValue = values.start;
                    _endValue = values.end;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildControlRow(
              '속도',
              '${_speedValue.toStringAsFixed(1)}x',
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
                    _controller!.setPlaybackSpeed(_speedValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }






  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widthPercentage(context, 5)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(heightPercentage(context, 1)),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        onPressed: _applyChangesAndSaveVideo,
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

  @override
  void dispose() {
    _controller?.dispose();
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

  Widget _buildControlRow(String label, String value, Widget controlWidget) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: heightPercentage(context, 0.5)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: heightPercentage(context, 0.5),
          horizontal: widthPercentage(context, 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: fontSizePercentage(context, MQSize.fontSize5)),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: fontSizePercentage(context, MQSize.fontSize4)),
            ),
            const SizedBox(height: 2),
            controlWidget,
          ],
        ),
      ),
    );
  }
}





