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
import 'function/generate_text_emoji_overlay.dart';




class VideoEditingPage extends StatefulWidget {
  final String videoPath;

  const VideoEditingPage({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoEditingPageState createState() => _VideoEditingPageState();
}

class _VideoEditingPageState extends State<VideoEditingPage> {
  VideoPlayerController? _controller;
  final GlobalKey _videoPlayerKey = GlobalKey();
  
  bool _isPlaying = false;
  Offset? _videoEditorTopLeft;
  double _videoWidth = 0;
  double _videoHeight = 0;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateVideoEditorOffset(); // 오프셋 계산
    });
  }

  // 비디오 플레이어의 오프셋을 계산하는 함수
  void _calculateVideoEditorOffset() {
    RenderBox? videoBox = _videoPlayerKey.currentContext?.findRenderObject() as RenderBox?;
    if (videoBox != null) {
      setState(() {
        _videoEditorTopLeft = videoBox.localToGlobal(Offset.zero);
        _videoWidth = videoBox.size.width;
        _videoHeight = videoBox.size.height;
      });
      print('Video editor top left: $_videoEditorTopLeft, Width: $_videoWidth, Height: $_videoHeight');
    }
  }


  Future<void> _initializeController(String videoPath) async {
    _controller?.dispose();
    _controller = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {
          _endValue = _controller!.value.duration.inSeconds.toDouble();
        });

        // 비디오 상태 모니터링
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

    // 이모티콘 및 텍스트 필터 추가 (함수 호출)
    String overlayFilters = await generateTextEmojiOverlayFilters(_elements, _videoEditorTopLeft!, _videoWidth, _videoHeight);
    print('Generated overlayFilters: $overlayFilters');  // 생성된 필터 확인
    // 이모지 크기를 직접 로그로 출력 (필터 문자열에서 추출하거나 별도로 계산)
    for (var element in _elements) {
      if (element['isEmoji'] == true) {
        double size = element['size'] * 1920;  // 이모티콘 크기 계산 (기본 화면 높이 기준)
        print('Emoji size in pixels: $size');  // 이모티콘 크기 출력
      }
    }

    // 최종 FFmpeg 명령어
    String command = '-ss $_trimmedStartValue '
        '-i ${widget.videoPath} '
        '-to $_trimmedEndValue ';

    if (overlayFilters.isNotEmpty) {
      // 이모티콘이나 텍스트가 있을 때만 필터 적용
      command += '-vf "$colorMatrixFilter, $overlayFilters, setpts=${1 / _speedValue}*PTS" ';
    } else {
      // 필터가 없을 경우, 컬러 필터만 적용
      command += '-vf "$colorMatrixFilter, setpts=${1 / _speedValue}*PTS" ';
    }

    command += '-c:a copy "$outputPath"';




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
        setState(() {
          _isPlaying = false;
        });
      } else {
        _controller!.play();
        setState(() {
          _isPlaying = true;
        });
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
      // null 체크 후 안전하게 저장
      if (content.isNotEmpty) {
        _elements.add({
          'content': content,            // 텍스트나 이모티콘 내용
          'size': size,                  // 크기
          'isEmoji': isEmoji ?? false,   // 이모티콘 여부를 null 체크 후 기본값 false 설정
          'position': const Offset(100, 100),  // 처음 지정되는 기본 위치
        });
      } else {
        print("Invalid content or size. Element not added.");
      }
    });
  }
  // 이모티콘 또는 텍스트의 위치가 변경되었을 때 호출되는 함수 (새로 추가된 콜백 함수)
  void _updateElementPosition(int index, Offset newPosition) {
    setState(() {
      _elements[index]['position'] = newPosition;  // 새로운 위치로 업데이트
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // 비디오 플레이어의 실제 크기 계산
                      double videoAspectRatio = _controller!.value.aspectRatio;
                      double videoWidth = constraints.maxWidth;
                      double videoHeight = videoWidth / videoAspectRatio;

                      // 만약 높이가 최대 크기를 넘는다면, 다시 너비를 계산
                      if (videoHeight > constraints.maxHeight) {
                        videoHeight = constraints.maxHeight;
                        videoWidth = videoHeight * videoAspectRatio;
                      }

                      return Stack(
                        children: [
                          // 비디오 플레이어 영역
                          SizedBox(
                            key: _videoPlayerKey,
                            width: videoWidth,
                            height: videoHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2.0,
                                ),
                              ),
                              child: AspectRatio(
                                aspectRatio: videoAspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            width: videoWidth,
                            height: videoHeight,
                            child: VideoFilter(
                              brightness: _brightnessValue,
                              contrast: _contrastValue,
                              saturation: _saturationValue,
                              controller: _controller!,
                            ),
                          ),
                          // IconLayer에 비디오 플레이어의 크기 전달
                          Positioned(
                            left: 0,
                            top: 0,
                            width: videoWidth,
                            height: videoHeight,
                            child: IconLayer(
                              maxHeight: videoHeight,  // 비디오 플레이어의 실제 높이
                              maxWidth: videoWidth,    // 비디오 플레이어의 실제 너비
                              elements: _elements,
                              onPositionChanged: _updateElementPosition,  // 위치 변경 콜백 전달
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              )
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









