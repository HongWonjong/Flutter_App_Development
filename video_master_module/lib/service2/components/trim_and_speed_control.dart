import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_master_module/mq_size.dart';

class TrimAndSpeedControls extends StatefulWidget {
  final double speedValue;
  final double startValue;
  final double endValue;
  final Widget Function(String, String, Widget) buildControlRow;
  final VideoPlayerController? controller;

  // 부모로 트리밍된 값을 전달하는 콜백 함수
  final Function(double, double) onTrimChanged;
  // 부모로 속도 변경된 값을 전달하는 콜백 함수
  final Function(double) onSpeedChanged;

  const TrimAndSpeedControls({
    required this.speedValue,
    required this.buildControlRow,
    required this.controller,
    required this.startValue,
    required this.endValue,
    required this.onTrimChanged,
    required this.onSpeedChanged, // 속도 콜백 추가
  });

  @override
  _TrimAndSpeedControlsState createState() => _TrimAndSpeedControlsState();
}

class _TrimAndSpeedControlsState extends State<TrimAndSpeedControls> {
  late double _speedValue;
  late double _trimmedStartValue; // 트리밍된 시작값
  late double _trimmedEndValue;   // 트리밍된 끝값
  double maxTrimDuration = 10.0;
  bool _isTrimInitialized = false;

  @override
  void initState() {
    super.initState();
    _speedValue = widget.speedValue;
    _trimmedStartValue = widget.startValue;
    _trimmedEndValue = widget.endValue;

    if (widget.controller != null && widget.controller!.value.isInitialized) {
      double videoDuration = widget.controller!.value.duration.inMilliseconds.toDouble() / 1000;
      maxTrimDuration = videoDuration > 0 ? videoDuration : 10.0;
      _trimmedEndValue = maxTrimDuration;
      _isTrimInitialized = true;
    } else {
      maxTrimDuration = widget.endValue;
    }
  }

  @override
  void didUpdateWidget(TrimAndSpeedControls oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isTrimInitialized && widget.controller != null && widget.controller!.value.isInitialized) {
      setState(() {
        maxTrimDuration = widget.controller!.value.duration.inMilliseconds.toDouble() / 1000;
        _trimmedEndValue = maxTrimDuration;
        _isTrimInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widthPercentage(context, 2)),
      child: Column(
        children: [
          // 자르기 슬라이더
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget.buildControlRow(
              '자르기',
              '${formatDuration(_trimmedStartValue)} - ${formatDuration(_trimmedEndValue)}',
              RangeSlider(
                values: RangeValues(
                  _trimmedStartValue.clamp(0.0, maxTrimDuration),
                  _trimmedEndValue.clamp(0.0, maxTrimDuration),
                ),
                min: 0.0,
                max: maxTrimDuration,
                onChanged: (RangeValues values) {
                  setState(() {
                    _trimmedStartValue = values.start.clamp(0.0, maxTrimDuration);
                    _trimmedEndValue = values.end.clamp(0.0, maxTrimDuration);
                  });
                  // 변경된 값을 부모로 전달
                  widget.onTrimChanged(_trimmedStartValue, _trimmedEndValue);
                },
              ),
            ),
          ),
          // 속도 슬라이더
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget.buildControlRow(
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
                  // 부모로 속도 값 전달
                  widget.onSpeedChanged(_speedValue);
                  if (widget.controller != null && widget.controller!.value.isInitialized) {
                    widget.controller!.setPlaybackSpeed(_speedValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 시간 표시 포맷
  String formatDuration(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$secs";
  }
}








