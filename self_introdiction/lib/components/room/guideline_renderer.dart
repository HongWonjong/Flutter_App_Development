import 'package:flutter/material.dart';

Widget buildGuideline(
    BuildContext context,
    Map<String, dynamic> guidelineData,
    double screenWidth,
    double screenHeight,
    bool isEditMode,
    VoidCallback startDragging,
    Function(DragUpdateDetails) updateGuidelinePosition,
    Function(Map<String, dynamic>) stopDragging,
    Function(BuildContext, Map<String, dynamic>, double, double, Function(Map<String, dynamic>), Function(Map<String, dynamic>)) showGuidelineOptionsFunc,
    Function(Map<String, dynamic>) onUpdateGuideline,
    Function(Map<String, dynamic>) onRemoveGuideline) {
  final type = guidelineData['type'] as String;
  final positionFactor = (guidelineData['position'] as double?) ?? 0.5;
  final color = Color(int.parse((guidelineData['color'] as String).replaceAll('#', '0xff')));

  const visibleWidth = 5.0; // 기준선 두께
  const visibleHeight = 5.0;
  const touchPadding = 30.0; // 터치 패딩 크기

  final top = type == 'horizontal' ? positionFactor * screenHeight : 0.0;
  final left = type == 'vertical' ? positionFactor * screenWidth : 0.0;

  return Positioned(
    top: top,
    left: left,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent, // 터치 감도 개선
      onTap: isEditMode ? () => showGuidelineOptionsFunc(context, guidelineData, screenWidth, screenHeight, onUpdateGuideline, onRemoveGuideline) : null,
      onPanStart: isEditMode ? (_) => startDragging() : null,
      onPanUpdate: isEditMode ? updateGuidelinePosition : null,
      onPanEnd: isEditMode ? (_) => stopDragging(guidelineData) : null,
      child: Padding(
        padding: type == 'horizontal'
            ? EdgeInsets.symmetric(vertical: touchPadding) // 가로선: 위아래 패딩
            : EdgeInsets.symmetric(horizontal: touchPadding), // 세로선: 좌우 패딩
        child: SizedBox(
          width: type == 'horizontal' ? screenWidth : visibleWidth, // 가로선: 화면 너비, 세로선: 기준선 두께
          height: type == 'vertical' ? screenHeight : visibleHeight, // 세로선: 화면 높이, 가로선: 기준선 두께
          child: Stack(
            children: [
              Container(
                color: color.withOpacity(0.5), // 기준선 색상
              ),
              if (isEditMode)
                Positioned(
                  right: type == 'horizontal' ? 0 : null,
                  bottom: type == 'vertical' ? 0 : null,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onRemoveGuideline(guidelineData),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}