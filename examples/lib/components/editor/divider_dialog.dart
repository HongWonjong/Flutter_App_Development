import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';

class DividerDialog extends StatefulWidget {
  final AppTheme theme;
  final Function(DividerElement) onSave;
  final bool? initialIsVertical;
  final double? initialThickness;
  final Color? initialColor;

  const DividerDialog({
    Key? key,
    required this.theme,
    required this.onSave,
    this.initialIsVertical,
    this.initialThickness,
    this.initialColor,
  }) : super(key: key);

  @override
  State<DividerDialog> createState() => _DividerDialogState();
}

class _DividerDialogState extends State<DividerDialog> {
  bool isVertical = false;
  double thickness = 2.0;
  late Color color;

  @override
  void initState() {
    super.initState();

    // 초기값 설정
    if (widget.initialIsVertical != null) {
      isVertical = widget.initialIsVertical!;
    }
    if (widget.initialThickness != null) {
      thickness = widget.initialThickness!;
    }
    color = widget.initialColor ?? widget.theme.textColor;

    // 다이얼로그 표시 후 약간의 딜레이 뒤에 실제 레이아웃 크기 측정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureLayoutSize();
    });
  }

  // 실제 레이아웃 크기 측정
  void _measureLayoutSize() {
    setState(() {
      // 이미 측정된 값이 있다면 사용
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme.textColor;
    final backgroundColor = widget.theme.backgroundColor;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('구분선 추가', style: TextStyle(color: textColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('방향:', style: TextStyle(color: textColor)),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('가로'),
                selected: !isVertical,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      isVertical = false;
                    });
                  }
                },
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                  color: !isVertical ? Colors.white : textColor,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('세로'),
                selected: isVertical,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      isVertical = true;
                    });
                  }
                },
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                  color: isVertical ? Colors.white : textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('두께:', style: TextStyle(color: textColor)),
              Expanded(
                child: Slider(
                  value: thickness,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  label: thickness.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      thickness = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 300,
            height: 100,
            alignment: Alignment.center,
            // 미리보기 영역 - 테두리 없는 투명 배경
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: isVertical
                ? Container(
                    width: thickness, // 선 두께
                    height: 80, // 고정 높이
                    color: color.withOpacity(0.9), // 더 진한 색상으로 선 표시
                  )
                : Container(
                    width: 250, // 고정 너비
                    height: thickness, // 선 두께
                    color: color.withOpacity(0.9), // 더 진한 색상으로 선 표시
                  ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('취소', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            // 현재 화면 크기 계산
            final screenSize = MediaQuery.of(context).size;

            // 메모장 레이아웃에 맞는 최적의 크기 계산 (상단바, 여백 등 고려)
            // 실제 메모장 영역의 너비와 높이를 더 정확하게 측정
            final layoutWidth = screenSize.width - 32; // 양쪽 패딩 제외
            final layoutHeight = screenSize.height - 150; // 앱바, 요소 생성바 등 공간 제외

            // 구분선 요소 생성 시 측정된 레이아웃 크기 적용
            final dividerElement = DividerElement(
              id: const Uuid().v4(),
              isVertical: isVertical,
              thickness: thickness,
              color: color,
              xFactor: 0.1,
              yFactor: 0.3,
              // 방향에 따라 적절한 크기 지정
              width: isVertical ? 50 : layoutWidth, // 가로선이면 레이아웃 너비 사용
              height: isVertical ? layoutHeight : 50, // 세로선이면 레이아웃 높이 사용
            );

            widget.onSave(dividerElement);
            Navigator.pop(context);
          },
          child: Text('추가', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
