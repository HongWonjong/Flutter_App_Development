import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';
import '../../providers/subtle_style_provider.dart';
import '../../providers/srt_provider.dart';

class SubtitleEditorDialog extends ConsumerStatefulWidget {
  final Uint8List frameImage;

  const SubtitleEditorDialog({
    super.key,
    required this.frameImage,
  });

  @override
  _SubtitleEditorDialogState createState() => _SubtitleEditorDialogState();
}

class _SubtitleEditorDialogState extends ConsumerState<SubtitleEditorDialog> {
  double subtitlePosition = 10.0;
  double fontSize = 20.0;
  String fontFamily = 'Roboto';
  Color textColor = Colors.white;
  double textOpacity = 1.0;
  double bgHeight = 40.0;
  Color bgColor = Colors.black;
  double bgOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final subtitleText = ref.watch(srtModifyProvider).firstSubtitle ?? '자막 없음';

    return AlertDialog(
      title: Text(
        '자막 스타일 편집',
        style: TextStyle(fontSize: ResponsiveSizes.textSize(5), fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.grey[200], // 다이얼로그 전체 배경색
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 좌측: 미리보기 영역
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(ResponsiveSizes.h2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Image.memory(
                      widget.frameImage,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      bottom: subtitlePosition,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: bgHeight,
                        color: bgColor.withOpacity(bgOpacity),
                        child: Center(
                          child: Text(
                            subtitleText,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: textColor.withOpacity(textOpacity),
                              fontFamily: fontFamily,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: ResponsiveSizes.h5),

            // 우측: 스타일 조절 영역
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 자막 스타일 섹션
                    Container(
                      padding: EdgeInsets.all(ResponsiveSizes.h3),
                      margin: EdgeInsets.only(bottom: ResponsiveSizes.h2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border(bottom: BorderSide(color: Colors.black)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('자막 스타일', color: Colors.black87),
                          _buildSlider('글씨 크기', fontSize, 10, 50, (value) => setState(() => fontSize = value)),
                          _buildFontDropdown(),
                          _buildColorPicker('글씨 색상', textColor, (color) => setState(() => textColor = color)),
                          _buildSlider('글씨 투명도', textOpacity, 0, 1, (value) => setState(() => textOpacity = value)),
                        ],
                      ),
                    ),

                    // 배경 스타일 섹션
                    Container(
                      padding: EdgeInsets.all(ResponsiveSizes.h3),
                      margin: EdgeInsets.only(bottom: ResponsiveSizes.h2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border(top: BorderSide(color: Colors.black)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('배경 스타일', color: Colors.black87),
                          _buildSlider('배경 높이', bgHeight, 20, 100, (value) => setState(() => bgHeight = value)),
                          _buildColorPicker('배경 색상', bgColor, (color) => setState(() => bgColor = color)),
                          _buildSlider('배경 투명도', bgOpacity, 0, 1, (value) => setState(() => bgOpacity = value)),
                        ],
                      ),
                    ),

                    // 자막 위치 섹션
                    Container(
                      padding: EdgeInsets.all(ResponsiveSizes.h3),
                      margin: EdgeInsets.only(top: ResponsiveSizes.h2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border(top: BorderSide(color: Colors.black)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('자막 위치', color: Colors.black87),
                          _buildSlider(
                            '수직 위치',
                            subtitlePosition,
                            0,
                            100,
                                (value) => setState(() => subtitlePosition = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: TextStyle(fontSize: ResponsiveSizes.textSize(3), color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            final updatedState = SubtitleStyleState(
              fontSize: fontSize,
              fontFamily: fontFamily,
              textColor: textColor,
              textOpacity: textOpacity,
              bgHeight: bgHeight,
              bgColor: bgColor,
              bgOpacity: bgOpacity,
              subtitlePosition: subtitlePosition,
            );
            Navigator.pop(context, updatedState);
          },
          child: Text('적용', style: TextStyle(fontSize: ResponsiveSizes.textSize(3), color: Colors.green)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {Color color = Colors.black}) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveSizes.h2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveSizes.textSize(4),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveSizes.h2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.toStringAsFixed(1)}',
            style: TextStyle(fontSize: ResponsiveSizes.textSize(3), color: Colors.grey[800]),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: Colors.green,
            inactiveColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildFontDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveSizes.h2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('글씨체', style: TextStyle(fontSize: ResponsiveSizes.textSize(3), color: Colors.grey[800])),
          DropdownButton<String>(
            value: fontFamily,
            items: ['Roboto', 'Arial', 'Times New Roman']
                .map((font) => DropdownMenuItem(value: font, child: Text(font)))
                .toList(),
            onChanged: (value) => setState(() => fontFamily = value!),
            style: TextStyle(fontSize: ResponsiveSizes.textSize(3), color: Colors.black),
            dropdownColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(String label, Color currentColor, Function(Color) onColorChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveSizes.h2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: ResponsiveSizes.textSize(3), color: Colors.grey[800])),
          GestureDetector(
            onTap: () async {
              final color = await _showColorPicker(context, currentColor);
              if (color != null) onColorChanged(color);
            },
            child: Container(
              width: ResponsiveSizes.h5,
              height: ResponsiveSizes.h5,
              decoration: BoxDecoration(
                color: currentColor,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color initialColor) async {
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('색상 선택', style: TextStyle(fontSize: ResponsiveSizes.textSize(4))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (var color in [Colors.white, Colors.black, Colors.red, Colors.green, Colors.blue, Colors.yellow])
                GestureDetector(
                  onTap: () => Navigator.pop(context, color),
                  child: Container(
                    margin: EdgeInsets.all(ResponsiveSizes.h2),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}