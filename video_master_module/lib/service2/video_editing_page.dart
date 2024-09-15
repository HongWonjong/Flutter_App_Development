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
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';




class VideoEditingPage extends StatefulWidget {
  final String videoPath;

  const VideoEditingPage({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoEditingPageState createState() => _VideoEditingPageState();
}

class _VideoEditingPageState extends State<VideoEditingPage> {
  VideoPlayerController? _controller;
  final GlobalKey _filterKey = GlobalKey();
  
  bool _isPlaying = false;
  double? _calculatedVideoWidth;
  double? _calculatedVideoHeight;
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
    });
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

// 최종적으로 변경 사항을 적용하고 비디오를 저장하는 함수
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

    // 임시 디렉토리에서 출력 경로 설정
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // 컬러 매트릭스 계산
    List<double> colorMatrix = calculateColorMatrix(_brightnessValue, _contrastValue, _saturationValue);

    // FFmpeg에서 사용할 수 있는 필터로 변환
    String colorMatrixFilter = convertMatrixToFFmpegFilter(colorMatrix);

    // 이모티콘 및 텍스트 필터 추가 (함수 호출)
    var result = await generateTextEmojiOverlayFilters(_elements, _calculatedVideoWidth!, _calculatedVideoHeight!);
    String overlayInputs = result['inputs'] ?? '';  // 이모티콘 또는 이미지 경로
    String overlayFilters = result['filters'] ?? '';  // 필터 체인

    // 최종 FFmpeg 명령어
    String command = '-ss $_trimmedStartValue '
        '-i "${widget.videoPath}" '  // 비디오 경로
        '-to $_trimmedEndValue ';

    if (overlayFilters.isNotEmpty) {
      FFmpegKitConfig.enableLogCallback((log) {
        print(log.getMessage());
      });

      // 이모티콘이나 텍스트가 있을 때만 필터 적용
      print("Overlay Inputs: $overlayInputs");
      print("Overlay Filters: $overlayFilters");

      // 이모티콘 이미지 입력 추가
      command += '$overlayInputs ';

      // 필터 적용 -filter_complex 사용 (여러 이모티콘이 있을 경우)
      command += '-filter_complex "[0:v]$colorMatrixFilter[v0]; $overlayFilters; [v${_elements.length}]setpts=${1 / _speedValue}*PTS" ';
    } else {
      // 필터가 없을 경우 기본 비디오 인코딩 설정만 적용
      command += '-vf "$colorMatrixFilter,setpts=${1 / _speedValue}*PTS" ';
    }
    //**,**는 같은 입력 스트림에서 연속적인 필터 적용.
    // **;**는 새로운 입력 스트림 또는 독립적인 필터 체인을 구분할 때.

    //앞 필터의 출력을 입력으로 참조하여 받는 것이 체인 필터이지, 동일한 필터가 체인필터는 아님.
    // 체인필터만 넘길 때 숫자가 증가한다. 그리고 출력을 넘겨준다면 동일한 기호 예: [v0]=> [v0]으로 이동한다. 체인 필터라면 반대.

    // 오디오 복사 및 출력 파일 설정
    command += '-c:v h264_videotoolbox -c:a copy "$outputPath" ';
    command += '-loglevel verbose ';  // 추가 로그 출력

    print('Running FFmpeg command: $command');

    // FFmpeg 명령어 실행
    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      Navigator.of(context).pop(); // Progress dialog 닫기

      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _outputPath = outputPath;
        });
        _playEditedVideo();  // 편집된 비디오 재생
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
  void _addEmojiOrText(String content, double size) {
    setState(() {
      // null 체크 후 안전하게 저장
      if (content.isNotEmpty) {
        _elements.add({
          'content': content,            // 텍스트나 이모티콘 내용
          'size': size,                  // 크기//
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
      _elements[index]['position'] = newPosition;
      print("$index 번 이모티콘의 새로운 위치 $newPosition");// 새로운 위치로 업데이트
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
                      // 비디오 크기가 아직 계산되지 않은 경우에만 계산
                      if (_calculatedVideoWidth == null || _calculatedVideoHeight == null) {
                        double videoAspectRatio = _controller!.value.aspectRatio;

                        double maxWidth = constraints.maxWidth;
                        double maxHeight = constraints.maxHeight;

                        double videoWidth = maxWidth;
                        double videoHeight = videoWidth / videoAspectRatio;

                        // 높이가 최대 크기를 넘는다면 다시 너비 계산
                        if (videoHeight > maxHeight) {
                          videoHeight = maxHeight;
                          videoWidth = videoHeight * videoAspectRatio;
                        }

                        // 계산된 크기를 빌드 완료 후에 저장
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _calculatedVideoWidth = videoWidth;
                            _calculatedVideoHeight = videoHeight;
                          });
                        });

                        // 계산된 크기 로그로 출력
                        print("Video Size: Width = $videoWidth, Height = $videoHeight");
                      }

                      return Stack(
                        children: [
                          // 비디오 플레이어
                          if (_calculatedVideoWidth != null && _calculatedVideoHeight != null)
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: _calculatedVideoWidth,
                                height: _calculatedVideoHeight,
                                child: AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: VideoPlayer(_controller!),
                                ),
                              ),
                            ),
                          // 비디오 필터
                          if (_calculatedVideoWidth != null && _calculatedVideoHeight != null)
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: _calculatedVideoWidth,
                                height: _calculatedVideoHeight,
                                child: Container(
                                  key: _filterKey,
                                  color: Colors.transparent,
                                  child: VideoFilter(
                                    brightness: _brightnessValue,
                                    contrast: _contrastValue,
                                    saturation: _saturationValue,
                                    controller: _controller!,
                                  ),
                                ),
                              ),
                            ),
                          // 아이콘 레이어
                          if (_calculatedVideoWidth != null && _calculatedVideoHeight != null)
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: _calculatedVideoWidth,
                                height: _calculatedVideoHeight,
                                child: IconLayer(
                                  maxHeight: _calculatedVideoHeight!,
                                  maxWidth: _calculatedVideoWidth!,
                                  elements: _elements,
                                  onPositionChanged: _updateElementPosition,
                                ),
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
            bottom: heightPercentage(context, 1),  // 하단에서 5% 위에 위치
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









