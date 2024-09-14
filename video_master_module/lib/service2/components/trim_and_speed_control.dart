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
          // 값을 업데이트해 max 값을 안전하게 가져옴 (밀리초 단위로 변환)
          double maxDuration = widget.controller!.value.duration.inMilliseconds.toDouble() / 1000 ?? 1.0;
          _startValue = _startValue.clamp(0.0, maxDuration);
          _endValue = _endValue.clamp(0.0, maxDuration);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // VideoPlayerController가 초기화된 후 duration 값을 사용 (밀리초 단위로 초로 변환)
    double maxDuration = widget.controller?.value.isInitialized == true
        ? widget.controller!.value.duration.inMilliseconds.toDouble() / 1000
        : 1.0;

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
                values: RangeValues(
                  _startValue.clamp(0.0, maxDuration), // _startValue를 0과 maxDuration 사이로 제한
                  _endValue.clamp(0.0, maxDuration),   // _endValue를 0과 maxDuration 사이로 제한
                ),
                min: 0.0,
                max: maxDuration, // maxDuration은 동영상의 총 길이
                onChanged: (RangeValues values) {
                  setState(() {
                    // 클램핑을 통해 항상 min과 max 범위 내에 있도록 조정
                    _startValue = values.start.clamp(0.0, maxDuration);
                    _endValue = values.end.clamp(0.0, maxDuration);
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

  // 시간 표시 포맷 (밀리초 단위를 사용하더라도 포맷은 초 단위로 표시)
  String formatDuration(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).toInt()); // 밀리초 단위로 변환
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$secs";
  }
}


