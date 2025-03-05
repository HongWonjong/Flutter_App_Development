import 'package:flutter/material.dart';
import 'package:self_introdiction/components/room/utils.dart';

Widget buildWidget(
    BuildContext context,
    Map<String, dynamic> widgetData,
    double screenWidth,
    double screenHeight,
    bool isEditMode,
    VoidCallback startDragging,
    Function(DragUpdateDetails) updatePosition,
    Function(Map<String, dynamic>) stopDragging,
    Function(BuildContext, Map<String, dynamic>, double, double, Function(Map<String, dynamic>), Function(Map<String, dynamic>)) showEditPanelFunc,
    Function(Map<String, dynamic>) onUpdateWidget,
    Function(Map<String, dynamic>) onRemoveWidget) {
  final style = widgetData['style'] as Map<String, dynamic>;
  final position = widgetData['position'] as Map<String, dynamic>;
  final xfactor = (position['xfactor'] as double?) ?? 0.0;
  final yfactor = (position['yfactor'] as double?) ?? 0.0;
  final color = Color(int.parse(style['color'].replaceAll('#', '0xff')));
  final fontSize = screenWidth * (style['fontSizeFactor'] as double);
  final width = screenWidth * (style['widthFactor'] as double);
  final height = screenHeight * (style['heightFactor'] as double);

  // clamp 제거: 스크롤 영역 전체를 활용하도록
  final left = xfactor * screenWidth;
  final top = yfactor * screenHeight;

  Widget content;
  switch (widgetData['type']) {
    case 'text':
      content = Text(
        widgetData['content'],
        style: TextStyle(fontSize: fontSize, color: color),
        maxLines: null,
        overflow: TextOverflow.visible,
      );
      break;
    case 'image':
      content = Image.network(widgetData['content'], width: width, height: height, fit: BoxFit.cover);
      break;
    default:
      content = const SizedBox.shrink();
  }

  return Positioned(
    left: left,
    top: top,
    child: GestureDetector(
      onTap: isEditMode ? () => showEditPanelFunc(context, widgetData, screenWidth, screenHeight, onUpdateWidget, onRemoveWidget) : null,
      onPanStart: isEditMode ? (_) => startDragging() : null,
      onPanUpdate: isEditMode ? updatePosition : null,
      onPanEnd: isEditMode ? (_) => stopDragging(widgetData) : null,
      child: Container(
        width: width,
        height: height,
        alignment: getAlignment(style['alignment'] as String),
        decoration: isEditMode ? BoxDecoration(border: Border.all(color: Colors.blue)) : null,
        child: content,
      ),
    ),
  );
}