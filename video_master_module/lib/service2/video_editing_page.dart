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
import 'components/video_filter.dart';
import 'function/calculate_color_matrix.dart';
import 'components/icon_layer.dart';
import 'components/drawer_2/emoji_text_tool.dart';



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
  double _contrastValue = 0.0;
  double _saturationValue = 0.0;
  String? _outputPath;
  String _selectedProperty = '밝기'; // Default selected property
  // 트리밍된 값
  double _trimmedStartValue = 0.0;
  double _trimmedEndValue = 10.0;
  final List<Map<String, dynamic>> _elements = [];  // 이모티콘과 텍스트 저장 리스트

  // 드로어와 아이콘 상태를 한꺼번에 관리하는 Map
  Map<String, bool> drawerState = {
    'isFirstDrawerOpen': false,
    'isSecondDrawerOpen': false,
    'isFirstIconVisible': true,
    'isSecondIconVisible': true,
  };


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



  // 트리밍된 값 콜백 처리
  void _onTrimChanged(double start, double end) {
    setState(() {
      _trimmedStartValue = start;
      _trimmedEndValue = end;
    });
  }
  // 속도 변경된 값 콜백 처리
  void _onSpeedChanged(double speed) {
    setState(() {
      _speedValue = speed;
    });
  }

  Future<void> _applyChangesAndSaveVideo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
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

    // 컬러 매트릭스 계산
    List<double> colorMatrix = calculateColorMatrix(_brightnessValue, _contrastValue, _saturationValue);

    // FFmpeg에서 사용할 수 있는 필터로 변환
    String colorMatrixFilter = convertMatrixToFFmpegFilter(colorMatrix);

    // 트리밍 값 사용
    String command = '-ss $_trimmedStartValue '
        '-i ${widget.videoPath} '
        '-to $_trimmedEndValue '
        '-vf "$colorMatrixFilter, setpts=${1 / _speedValue}*PTS" '
        '-c:a copy "$outputPath"';


    print('Running FFmpeg command: $command');

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      Navigator.of(context).pop();

      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _outputPath = outputPath;
        });
        _playEditedVideo();
      } else {
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
      } else if (_selectedProperty == '대비') {
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

  void _toggleFirstDrawer() {
    setState(() {
      drawerState['isFirstDrawerOpen'] = !(drawerState['isFirstDrawerOpen']!);
      drawerState['isSecondIconVisible'] = !drawerState['isFirstDrawerOpen']!;
      if (drawerState['isFirstDrawerOpen']!) {
        drawerState['isSecondDrawerOpen'] = false;
      }
    });
  }

  void _toggleSecondDrawer() {
    setState(() {
      drawerState['isSecondDrawerOpen'] = !(drawerState['isSecondDrawerOpen']!);
      drawerState['isFirstIconVisible'] = !drawerState['isSecondDrawerOpen']!;
      if (drawerState['isSecondDrawerOpen']!) {
        drawerState['isFirstDrawerOpen'] = false;
      }
    });
  }
  void _addEmojiOrText(String content, bool isEmoji, double size) {
    setState(() {
      // 기본 위치는 화면 중앙, 나중에 사용자에게 위치 지정 가능
      _elements.add({
        'content': content,
        'position': Offset(100, 100),  // 기본 위치
        'size': size,  // 크기 정보 추가
      });
    });
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
          // 비디오 플레이어 영역
          Center(
            child: _controller != null && _controller!.value.isInitialized
                ? GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                children: [
                  SizedBox(
                    width: widthPercentage(context, 100),
                    height: heightPercentage(context, 80),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2.0,
                        ),
                      ),
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                  // 필터 적용
                  VideoFilter(
                    brightness: _brightnessValue,
                    contrast: _contrastValue,
                    saturation: _saturationValue,
                    controller: _controller!,
                  ),
                  Positioned.fill(
                    child: IconLayer(
                      maxHeight: heightPercentage(context, 80),
                      maxWidth: widthPercentage(context, 100),
                      elements: _elements,
                    ),
                  ),
                ],
              ),
            )
                : const CircularProgressIndicator(),
          ),

          // 버튼 영역 (비디오 플레이어 위에 Stack으로 추가)
          Positioned(
            bottom: heightPercentage(context, 5),  // 하단에서 5% 위에 위치
            left: 0,
            right: 0,
            child: Center(
              child: EditButton(applyChangesAndSaveVideo: _applyChangesAndSaveVideo),
            ),
          ),

          // 첫 번째 드로어
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: drawerState['isFirstDrawerOpen']! ? 0 : -widthPercentage(context, 80),
            top: 0,
            height: MediaQuery.of(context).size.height,
            width: widthPercentage(context, 80),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && !drawerState['isFirstDrawerOpen']!) {
                  _toggleFirstDrawer();
                } else if (details.delta.dx < 0 && drawerState['isFirstDrawerOpen']!) {
                  _toggleFirstDrawer();
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrimAndSpeedControls(
                      speedValue: _speedValue,
                      buildControlRow: _buildControlRow,
                      controller: _controller,
                      startValue: _startValue,
                      endValue: _endValue,
                      onTrimChanged: _onTrimChanged,
                      onSpeedChanged: _onSpeedChanged, // 속도 값 전달 콜백
                    ),
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

          // 두 번째 드로어
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: drawerState['isSecondDrawerOpen']! ? 0 : -widthPercentage(context, 80),
            top: 0,
            height: MediaQuery.of(context).size.height,
            width: widthPercentage(context, 80),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && !drawerState['isSecondDrawerOpen']!) {
                  _toggleSecondDrawer();
                } else if (details.delta.dx < 0 && drawerState['isSecondDrawerOpen']!) {
                  _toggleSecondDrawer();
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child:  Center(
                  child: EmojiTextDrawer(onAdd: _addEmojiOrText),
                ),
              ),
            ),
          ),

          // 첫 번째 드로어 토글 버튼
          if (drawerState['isFirstIconVisible']!)
            Positioned(
              left: drawerState['isFirstDrawerOpen']! ? widthPercentage(context, 80) : widthPercentage(context, 2),
              top: heightPercentage(context, 5),
              child: GestureDetector(
                onTap: _toggleFirstDrawer,
                child: Container(
                  decoration: BoxDecoration(
                    color: drawerState['isFirstDrawerOpen']!
                        ? Colors.transparent
                        : Colors.deepPurpleAccent.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(widthPercentage(context, 2)),
                  child: Icon(
                    drawerState['isFirstDrawerOpen']! ? Icons.arrow_back_ios : Icons.cut,
                    color: Colors.white,
                    size: widthPercentage(context, 8),
                  ),
                ),
              ),
            ),

          // 두 번째 드로어 토글 버튼
          if (drawerState['isSecondIconVisible']!)
            Positioned(
              left: drawerState['isSecondDrawerOpen']! ? widthPercentage(context, 80) : widthPercentage(context, 2),
              top: heightPercentage(context, 15),
              child: GestureDetector(
                onTap: _toggleSecondDrawer,
                child: Container(
                  decoration: BoxDecoration(
                    color: drawerState['isSecondDrawerOpen']!
                        ? Colors.transparent
                        : Colors.deepPurpleAccent.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(widthPercentage(context, 2)),
                  child: Icon(
                    drawerState['isSecondDrawerOpen']! ? Icons.arrow_back_ios : Icons.text_fields,
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









