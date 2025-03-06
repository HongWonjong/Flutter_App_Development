import 'package:flutter/foundation.dart' show kIsWeb; // 웹 환경 체크용
import 'package:flutter/material.dart';
import 'package:self_introdiction/components/room/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html; // 웹에서 URL 열기용

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
  // null 체크 추가
  final style = widgetData['style'] as Map<String, dynamic>? ?? {};
  final position = widgetData['position'] as Map<String, dynamic>? ?? {'xfactor': 0.0, 'yfactor': 0.0};
  final xfactor = (position['xfactor'] as double?) ?? 0.0;
  final yfactor = (position['yfactor'] as double?) ?? 0.0;
  final width = screenWidth * (style['widthFactor'] as double? ?? 0.3);
  final height = screenHeight * (style['heightFactor'] as double? ?? 0.1);

  final left = xfactor * screenWidth;
  final top = yfactor * screenHeight;

  Widget content;
  switch (widgetData['type']) {
    case 'text':
      final color = Color(int.parse((style['color'] as String? ?? '#000000').replaceAll('#', '0xff')));
      final fontSize = screenWidth * (style['fontSizeFactor'] as double? ?? 0.04);
      content = Text(
        widgetData['content'] ?? '내용 없음',
        style: TextStyle(fontSize: fontSize, color: color),
        maxLines: null,
        overflow: TextOverflow.visible,
      );
      break;
    case 'image':
      content = Image.network(
        widgetData['content'] ?? 'https://via.placeholder.com/150',
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
      break;
    case 'button':
    // 버튼 속성에 기본값 추가 및 null 체크
      final backgroundColor = Color(int.parse((style['backgroundColor'] as String? ?? '#42A5F5').replaceAll('#', '0xff')));
      final textColor = Color(int.parse((style['textColor'] as String? ?? '#FFFFFF').replaceAll('#', '0xff')));
      final fontSize = screenWidth * (style['fontSizeFactor'] as double? ?? 0.04);
      final borderRadius = (style['borderRadius'] as double? ?? 0.2) * 50; // 0.0~1.0을 픽셀로 변환
      final opacity = (style['opacity'] as double?) ?? 1.0;
      final url = widgetData['url'] as String? ?? 'https://example.com';

      // 디버깅 로그 추가
      print('Button 렌더링: $widgetData');

      content = Opacity(
        opacity: opacity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            minimumSize: Size(width, height),
          ),
          onPressed: isEditMode
              ? null // 편집 모드에서는 클릭 비활성화
              : () {
            if (kIsWeb) {
              // 웹 환경에서는 window.open 사용
              html.window.open(url, '_blank');
            } else {
              // 모바일 환경에서는 url_launcher 사용
              final uri = Uri.parse(url);
              launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('URL을 열 수 없습니다: $url')),
                );
                return false;
              });
            }
          },
          child: Text(
            widgetData['content'] ?? '새 버튼',
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        ),
      );
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
        alignment: getAlignment(style['alignment'] as String? ?? 'center'),
        decoration: isEditMode ? BoxDecoration(border: Border.all(color: Colors.blueAccent)) : null,
        child: content,
      ),
    ),
  );
}