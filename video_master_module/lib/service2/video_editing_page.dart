import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../edited_video_screen.dart';

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
  String? _previewImagePath;

  @override
  void initState() {
    super.initState();
    _initializeController(widget.videoPath);
    _generatePreview();
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

  Future<void> _generatePreview() async {
    final tempDir = await getTemporaryDirectory();
    final previewImagePath = '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.jpg';

    String command = '-i ${widget.videoPath} -ss $_startValue '
        '-vf "curves=all=\'0/0 0.5/${_contrastValue.toStringAsFixed(2)} 1/1\','
        'colorbalance=rs=${_brightnessValue.toStringAsFixed(2)}:gs=${_brightnessValue.toStringAsFixed(2)}:bs=${_brightnessValue.toStringAsFixed(2)},'
        'hue=s=${_saturationValue.toStringAsFixed(2)}" '
        '-vframes 1 "$previewImagePath"';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          _previewImagePath = previewImagePath;
        });
      } else {
        print('Failed to generate preview.');
      }
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

  Future<void> _refreshPreview() async {
    await _generatePreview();
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
        title: const Text('Video Editing', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video thumbnail or player
            _controller != null && _controller!.value.isInitialized
                ? GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: _previewImagePath != null
                        ? Image.file(File(_previewImagePath!), fit: BoxFit.cover)
                        : VideoPlayer(_controller!),
                  ),
                  if (!_controller!.value.isPlaying)
                    const Icon(Icons.play_circle_outline, size: 80, color: Colors.white),
                ],
              ),
            )
                : const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 15), // Reduced spacing

            // Trim and Speed in one row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduced padding
              child: Row(
                children: [
                  Expanded(
                    child: _buildControlRow(
                      'Trim',
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
                          _refreshPreview();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildControlRow(
                      'Speed',
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
            ),

            // Brightness, Contrast, and Saturation in one row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduced padding
              child: Row(
                children: [
                  Expanded(
                    child: _buildControlRow(
                      'Brightness',
                      _brightnessValue.toStringAsFixed(2),
                      Slider(
                        value: _brightnessValue,
                        min: -1.0,
                        max: 1.0,
                        divisions: 20,
                        label: "${_brightnessValue.toStringAsFixed(2)}",
                        onChanged: (value) {
                          setState(() {
                            _brightnessValue = value;
                          });
                          _refreshPreview();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildControlRow(
                      'Contrast',
                      _contrastValue.toStringAsFixed(1),
                      Slider(
                        value: _contrastValue,
                        min: 0.0,
                        max: 1.0,
                        divisions: 25,
                        label: "${_contrastValue.toStringAsFixed(1)}",
                        onChanged: (value) {
                          setState(() {
                            _contrastValue = value;
                          });
                          _refreshPreview();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildControlRow(
                      'Saturation',
                      _saturationValue.toStringAsFixed(1),
                      Slider(
                        value: _saturationValue,
                        min: 0.0,
                        max: 2.0,
                        divisions: 20,
                        label: "${_saturationValue.toStringAsFixed(1)}",
                        onChanged: (value) {
                          setState(() {
                            _saturationValue = value;
                          });
                          _refreshPreview();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15), // Reduced spacing
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlRow(String label, String value, Widget controlWidget) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 4), // Reduced vertical margin
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6), // Reduced padding inside card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label and value on separate lines
            Text(
              label,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,  // Ensure long text is truncated
            ),
            const SizedBox(height: 2), // Reduced spacing between label and value
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,  // Ensure long text is truncated
            ),
            const SizedBox(height: 2), // Reduced spacing between value and control widget
            controlWidget,  // Slider or RangeSlider
          ],
        ),
      ),
    );
  }




  Widget _buildColorControlRow() {
    return Column(
      children: [
        _buildControlRow(
          'Brightness',
          _brightnessValue.toStringAsFixed(2),
          Slider(
            value: _brightnessValue,
            min: -1.0,
            max: 1.0,
            divisions: 20,
            label: "${_brightnessValue.toStringAsFixed(2)}",
            onChanged: (value) {
              setState(() {
                _brightnessValue = value;
              });
              _refreshPreview();
            },
          ),
        ),
        _buildControlRow(
          'Contrast',
          _contrastValue.toStringAsFixed(1),
          Slider(
            value: _contrastValue,
            min: 0.0,
            max: 1.0,
            divisions: 25,
            label: "${_contrastValue.toStringAsFixed(1)}",
            onChanged: (value) {
              setState(() {
                _contrastValue = value;
              });
              _refreshPreview();
            },
          ),
        ),
        _buildControlRow(
          'Saturation',
          _saturationValue.toStringAsFixed(1),
          Slider(
            value: _saturationValue,
            min: 0.0,
            max: 2.0,
            divisions: 20,
            label: "${_saturationValue.toStringAsFixed(1)}",
            onChanged: (value) {
              setState(() {
                _saturationValue = value;
              });
              _refreshPreview();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        onPressed: _applyChangesAndSaveVideo,
        child: const Text('Apply & Save', style: TextStyle(fontSize: 18, color: Colors.white)),
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
}



