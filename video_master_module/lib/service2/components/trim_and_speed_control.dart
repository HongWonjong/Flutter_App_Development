import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_master_module/mq_size.dart';

class TrimAndSpeedControls extends StatefulWidget {
  final double speedValue;
  final double startValue;
  final double endValue;
  final Widget Function(String, String, Widget) buildControlRow;
  final VideoPlayerController? controller;

  const TrimAndSpeedControls({
    required this.speedValue,
    required this.buildControlRow,
    required this.controller,
    required this.startValue,
    required this.endValue,
  });

  @override
  _TrimAndSpeedControlsState createState() => _TrimAndSpeedControlsState();
}

class _TrimAndSpeedControlsState extends State<TrimAndSpeedControls> {
  late double _speedValue;
  late double _startValue;
  late double _endValue;

  @override
  void initState() {
    super.initState();
    _speedValue = widget.speedValue;
    _startValue = widget.startValue;
    _endValue = widget.endValue;

    // VideoPlayerController가 초기화된 후 setState를 통해 duration을 가져옴
    widget.controller?.addListener(() {
      if (widget.controller!.value.isInitialized) {
        setState(() {
          // 값을 업데이트해 max 값을 안전하게 가져옴
          double maxDuration = widget.controller?.value.duration.inSeconds.toDouble() ?? 1;
          _startValue = _startValue.clamp(0, maxDuration);
          _endValue = _endValue.clamp(0, maxDuration);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // VideoPlayerController가 초기화된 후 duration 값을 사용
    double maxDuration = widget.controller?.value.isInitialized == true
        ? widget.controller!.value.duration.inSeconds.toDouble()
        : 1;

    return Padding(
      padding: EdgeInsets.all(widthPercentage(context, 2)),
      child: Column(
        children: [
          // 자르기 슬라이더
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget.buildControlRow(
              '자르기',
              '${formatDuration(_startValue)} - ${formatDuration(_endValue)}',
              RangeSlider(
                values: RangeValues(_startValue, _endValue),
                min: 0,
                max: maxDuration, // 안전한 max 값 설정
                onChanged: (RangeValues values) {
                  setState(() {
                    _startValue = values.start;
                    _endValue = values.end;
                  });
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

  // formatDuration 함수는 그대로 사용
  String formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$secs";
  }
}


