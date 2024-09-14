import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../edited_video_screen.dart';
import 'package:video_master_module/mq_size.dart';
import 'components/brightness_contrast_saturation_control.dart';
import 'components/edit_button.dart';
import 'components/trim_and_speed_control.dart';

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

  // 드로어 열기/닫기 상태 (각 드로어가 화면 전체를 차지하도록 설정)
  bool _isFirstDrawerOpen = false; // 첫 번째 드로어 상태
  bool _isSecondDrawerOpen = false; // 두 번째 드로어 상태

  // 아이콘 표시 여부 상태
  bool _isFirstIconVisible = true;
  bool _isSecondIconVisible = true;

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
    // "인코딩 중..." 알림창 띄우기
    showDialog(
      context: context,
      barrierDismissible: false, // 변환 중엔 창을 닫지 못하도록 설정
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("인코딩 중..."),
            ],
          ),
        );
      },
    );

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
      Navigator.of(context).pop(); // 로딩창 닫기

      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _outputPath = outputPath;
        });
        _playEditedVideo();
      } else {
        // 인코딩 실패 시 에러 처리
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인코딩 실패. 다시 시도해주세요.')),
        );
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: widthPercentage(context, 100),  // 원하는 가로 크기
                        height: heightPercentage(context, 70), // 원하는 세로 크기
                        child: FittedBox(
                          fit: BoxFit.cover,  // 화면에 맞게 충분히 확대 (원본 비율 유지)
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      ),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EditButton(applyChangesAndSaveVideo: _applyChangesAndSaveVideo),
                    ],
                  ),
                ],
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

          // 첫 번째 드로어
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _isFirstDrawerOpen ? 0 : -widthPercentage(context, 80), // 왼쪽에서 열리도록 설정
            top: 0,
            height: MediaQuery.of(context).size.height, // 전체 화면 차지
            width: widthPercentage(context, 80),  // 드로어 너비
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && !_isFirstDrawerOpen) {
                  setState(() {
                    _isFirstDrawerOpen = true;
                    _isSecondIconVisible = false; // 첫 번째 드로어가 열리면 두 번째 아이콘 숨김
                  });
                } else if (details.delta.dx < 0 && _isFirstDrawerOpen) {
                  setState(() {
                    _isFirstDrawerOpen = false;
                    _isSecondIconVisible = true; // 첫 번째 드로어가 닫히면 두 번째 아이콘 표시
                  });
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 트림 및 속도 컨트롤
                    TrimAndSpeedControls(
                        speedValue: _speedValue,
                        buildControlRow: _buildControlRow,
                        controller: _controller,
                        startValue: _startValue,
                        endValue: _endValue),
                    // 밝기/대비/채도 컨트롤
                    BrightnessContrastSaturationControl(
                      selectedProperty: _selectedProperty,
                      brightnessValue: _brightnessValue,
                      contrastValue: _contrastValue,
                      saturationValue: _saturationValue,
                      onPropertyChanged: _onPropertyChanged,
                      onSliderChanged: _onSliderChanged,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 두 번째 드로어 (세로로 배치됨)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _isSecondDrawerOpen ? 0 : -widthPercentage(context, 80), // 첫 번째 드로어와 같은 왼쪽에서 열림
            top: 0, // 화면 상단부터 시작
            height: MediaQuery.of(context).size.height, // 전체 화면 차지
            width: widthPercentage(context, 80),  // 드로어 너비
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && !_isSecondDrawerOpen) {
                  setState(() {
                    _isSecondDrawerOpen = true;
                    _isFirstIconVisible = false; // 두 번째 드로어가 열리면 첫 번째 아이콘 숨김
                  });
                } else if (details.delta.dx < 0 && _isSecondDrawerOpen) {
                  setState(() {
                    _isSecondDrawerOpen = false;
                    _isFirstIconVisible = true; // 두 번째 드로어가 닫히면 첫 번째 아이콘 표시
                  });
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Text(
                    '추가 기능',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),

          // 첫 번째 드로어 토글 버튼
          if (_isFirstIconVisible) // 첫 번째 드로어가 닫혀있을 때만 표시
            Positioned(
              left: _isFirstDrawerOpen ? widthPercentage(context, 80) : widthPercentage(context, 2),
              top: heightPercentage(context, 5),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFirstDrawerOpen = !_isFirstDrawerOpen;
                    _isSecondIconVisible = !_isFirstDrawerOpen; // 첫 번째 드로어가 열리면 두 번째 아이콘 숨김
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isFirstDrawerOpen
                        ? Colors.transparent
                        : Colors.deepPurpleAccent.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(widthPercentage(context, 2)),
                  child: Icon(
                    _isFirstDrawerOpen ? Icons.arrow_back_ios : Icons.cut,
                    color: Colors.white,
                    size: widthPercentage(context, 8),
                  ),
                ),
              ),
            ),

          // 두 번째 드로어 토글 버튼
          if (_isSecondIconVisible) // 두 번째 드로어가 닫혀있을 때만 표시
            Positioned(
              left: _isSecondDrawerOpen
                  ? widthPercentage(context, 80)
                  : widthPercentage(context, 2), // 첫 번째 드로어와 같은 위치
              top: heightPercentage(context, 15), // 두 번째 드로어는 아래쪽에 배치
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSecondDrawerOpen = !_isSecondDrawerOpen;
                    _isFirstIconVisible = !_isSecondDrawerOpen; // 두 번째 드로어가 열리면 첫 번째 아이콘 숨김
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isSecondDrawerOpen
                        ? Colors.transparent
                        : Colors.deepPurpleAccent.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(widthPercentage(context, 2)),
                  child: Icon(
                    _isSecondDrawerOpen ? Icons.arrow_back_ios : Icons.text_fields,
                    color: Colors.white,
                    size: widthPercentage(context, 8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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








