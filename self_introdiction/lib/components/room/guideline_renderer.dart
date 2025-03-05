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

  // 디버깅: position의 실제 타입 출력
  print('guidelineData["position"] type: ${guidelineData['position'].runtimeType}');
  print('guidelineData["position"] value: ${guidelineData['position']}');

  // 안전한 타입 변환
  final positionValue = guidelineData['position'];
  final positionFactor = (positionValue is num
      ? positionValue.toDouble()
      : positionValue is String
      ? double.tryParse(positionValue) ?? 0.5
      : 0.5);

  final color = Color(int.parse((guidelineData['color'] as String).replaceAll('#', '0xff')));

  const visibleWidth = 3.0;
  const visibleHeight = 3.0;
  const touchPadding = 20.0;

  // clamp 제거: 스크롤 영역 전체를 활용하도록
  final top = type == 'horizontal' ? positionFactor * screenHeight : 0.0;
  final left = type == 'vertical' ? positionFactor * screenWidth : 0.0;

  return Positioned(
    top: top,
    left: left,
    child: GestureDetector(
      onTap: isEditMode ? () => showGuidelineOptionsFunc(context, guidelineData, screenWidth, screenHeight, onUpdateGuideline, onRemoveGuideline) : null,
      onPanStart: isEditMode ? (_) => startDragging() : null,
      onPanUpdate: isEditMode ? updateGuidelinePosition : null,
      onPanEnd: isEditMode ? (_) => stopDragging(guidelineData) : null,
      child: Padding(
        padding: const EdgeInsets.all(touchPadding),
        child: SizedBox(
          width: type == 'horizontal' ? screenWidth - (2 * touchPadding) : visibleWidth,
          height: type == 'vertical' ? screenHeight * 1.5 - (2 * touchPadding) : visibleHeight,
          child: Stack(
            children: [
              Container(color: color.withOpacity(0.5)),
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