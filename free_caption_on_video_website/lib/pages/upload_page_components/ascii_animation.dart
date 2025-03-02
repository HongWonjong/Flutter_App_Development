import 'dart:async';
import 'package:flutter/material.dart';

class ASCIIAnimation extends StatefulWidget {
  const ASCIIAnimation({super.key});

  @override
  _ASCIIAnimationState createState() => _ASCIIAnimationState();
}

class _ASCIIAnimationState extends State<ASCIIAnimation> {
  int _frameIndex = 0;
  Timer? _timer;

  final List<List<String>> frames = [
    [
      '　　(/ΩΩ/)',
      '　　 / •• /',
      '　　(＿ノ |  캐시 삭제 해보실래요?',
      '　　　 |　|',
      '　　　 |　|',
      '　　 __|　|＿',
      '　　/ヘ　　/ )',
      '　　Lニニコ/',
      '　　 |￣￣￣|',
      '　　 |　　　|――≦彡',
      '　　 |　∩　|',
      '　　 |　||　|',
      '　　 |　||　|',
      '　　 |二||二|',
    ],
    [
      '　　(/ΩΩ/)',
      '　　 / •• /',
      '　　(＿ノ |    캐시 지워보셨어요?',
      '　　　 |　|',
      '　　　 |　|',
      '　　 __|　|＿',
      '　　/ヘ　　/ )',
      '　　Lニニコ/',
      '　　 |￣￣￣|',
      '　　 |　　　|――≦彡',
      '　　 |　∩　|',
      '　　 |　||　|',
      '　　 |　||　|',
      '　　 |二||二|',
    ],
    [
      '　　(/ΩΩ/)',
      '　　 /^ ^/',
      '　　(＿ノ |     아님 말구요 ㅎㅎ',
      '　　　 |　|',
      '　　　 |　|',
      '　　 __|　|＿',
      '　　/ヘ　　/ )',
      '　　Lニニコ/',
      '　　 |￣￣￣|',
      '　　 |　　　|――≦彡',
      '　　 |　∩　|',
      '　　 |　||　|',
      '　　 |　||　|',
      '　　 |二||二|',
    ],
    [
      '　 ∧_∧　',
      '　(´ﾞﾟωﾟ\')',
      '＿(_つ/￣￣￣/＿     .......',
      '　 ＼/　　　/',
      '　　　￣￣￣',
    ],
    [
      '　 ∧_∧　！',
      '　(;ﾞﾟωﾟ\')',
      '＿(_つ__ミ　            ...?',
      '　＼￣￣￣＼ミ',
      '　　￣￣￣￣',
    ],
    [
      '　 .:∧_∧:',
      '＿:(;ﾞﾟωﾟ\'):  서버 에러잖아!',
      '　＼￣￣￣＼',
      '　　￣￣￣￣',
    ],
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) { // 2초로 변경
      setState(() {
        _frameIndex = (_frameIndex + 1) % frames.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: ASCIICustomPainter(frames[_frameIndex]),
        size: const Size(400, 600), // 캔버스 크기 증가
      ),
    );
  }
}

class ASCIICustomPainter extends CustomPainter {
  final List<String> frame;

  ASCIICustomPainter(this.frame);

  @override
  void paint(Canvas canvas, Size size) {
    const textStyle = TextStyle(
      fontFamily: 'monospace',
      color: Colors.white,
      fontSize: 16, // 텍스트 크기 증가
    );
    const lineHeight = 1.2 * 16; // fontSize에 맞춰 조정

    // 프레임의 전체 높이와 너비 계산
    final totalHeight = frame.length * lineHeight;
    final maxWidth = frame.map((line) => line.length * 16).reduce((a, b) => a > b ? a : b).toDouble();

    // 캔버스 중앙에 배치하기 위한 오프셋 계산
    final offsetX = (size.width - maxWidth) / 2;
    final offsetY = (size.height - totalHeight) / 2;

    // 각 줄을 캔버스에 그림
    for (int i = 0; i < frame.length; i++) {
      final textSpan = TextSpan(
        text: frame[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // 각 줄의 위치를 중앙에 맞춤
      final lineOffset = Offset(offsetX, offsetY + i * lineHeight);
      textPainter.paint(canvas, lineOffset);
    }
  }

  @override
  bool shouldRepaint(covariant ASCIICustomPainter oldDelegate) {
    return frame != oldDelegate.frame; // 프레임이 바뀔 때만 다시 그림
  }
}