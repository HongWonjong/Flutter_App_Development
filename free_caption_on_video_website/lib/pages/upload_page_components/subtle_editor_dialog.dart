import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  double subtitlePosition = 10.0; // 0~100 범위, 썸네일 하단에서부터의 상대적 위치
  double fontSize = 20.0;
  String fontFamily = 'Roboto';
  Color textColor = Colors.white;
  Color bgColor = Colors.black.withOpacity(0.5);
  double paddingVertical = 12.0; // 상하 여백 기본값 증가
  double paddingHorizontal = 12.0; // 좌우 여백
  double? _imageAspectRatio; // 이미지 비율
  Size? _thumbnailSize; // 썸네일 실제 크기
  final GlobalKey _thumbnailKey = GlobalKey(); // 썸네일 크기 측정용 키

  @override
  void initState() {
    super.initState();
    _calculateImageAspectRatio();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 렌더링 후 썸네일 크기 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateThumbnailSize();
    });
  }

  void _calculateImageAspectRatio() {
    final image = Image.memory(widget.frameImage);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo info, bool _) {
          setState(() {
            _imageAspectRatio = info.image.width / info.image.height;
          });
        },
      ),
    );
  }

  void _updateThumbnailSize() {
    final RenderBox? renderBox = _thumbnailKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && _thumbnailSize != renderBox.size) {
      setState(() {
        _thumbnailSize = renderBox.size;
      });
    }
  }

  // 텍스트 높이 계산 개선: 실제 렌더링과 일치하도록 보정
  double _calculateTextHeight(String text, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          color: textColor,
          height: 1.2, // 줄 간격 명시 (Text 위젯과 동일)
        ),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor, // 디바이스 텍스트 스케일 반영
    )..layout(maxWidth: maxWidth - paddingHorizontal * 2);
    return textPainter.height + paddingVertical * 2; // 상하 패딩 포함
  }

  @override
  Widget build(BuildContext context) {
    final subtitleText = ref.watch(srtModifyProvider).firstSubtitle ?? '자막 없음';

    return AlertDialog(
      title: Text(
        '자막 스타일 편집',
        style: TextStyle(fontSize: ResponsiveSizes.textSize(5), fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.grey[200],
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
                child: _imageAspectRatio == null
                    ? Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    // 실시간 썸네일 크기 업데이트
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateThumbnailSize();
                    });

                    final thumbnailWidth = _thumbnailSize?.width ?? constraints.maxWidth;
                    final thumbnailHeight = _thumbnailSize?.height ?? (thumbnailWidth / (_imageAspectRatio ?? 1.0));
                    final textHeight = _calculateTextHeight(subtitleText, thumbnailWidth);

                    // 자막 위치 조정: 썸네일 하단에서부터의 거리, 경계 초과 방지
                    final subtitleBottom = (thumbnailHeight * (subtitlePosition / 100))
                        .clamp(0, thumbnailHeight - textHeight)
                        .toDouble();

                    return ClipRect(
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: _imageAspectRatio!,
                            child: Stack(
                              children: [
                                Image.memory(
                                  widget.frameImage,
                                  fit: BoxFit.contain,
                                  key: _thumbnailKey,
                                ),
                                Positioned(
                                  bottom: subtitleBottom,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: paddingVertical,
                                      horizontal: paddingHorizontal,
                                    ),
                                    height: textHeight, // 계산된 높이 적용
                                    color: bgColor,
                                    child: Center(
                                      child: Text(
                                        subtitleText,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: textColor,
                                          fontFamily: fontFamily,
                                          height: 1.2, // 줄 간격 일치
                                        ),
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        maxLines: null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                          _buildSectionTitle('자막 스타일', color: Colors.black87),
                          _buildSlider('글씨 크기', fontSize, 10, 50, (value) => setState(() => fontSize = value)),
                          _buildFontDropdown(),
                          _buildColorPicker('글씨 색상', textColor, (color) => setState(() => textColor = color)),
                        ],
                      ),
                    ),
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
                          _buildSectionTitle('배경 스타일', color: Colors.black87),
                          _buildColorPicker('배경 색상', bgColor, (color) => setState(() => bgColor = color)),
                          _buildSlider('상하 여백', paddingVertical, 0, 20, (value) => setState(() => paddingVertical = value)),
                          _buildSlider('좌우 여백', paddingHorizontal, 0, 30, (value) => setState(() => paddingHorizontal = value)),
                        ],
                      ),
                    ),
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
              bgHeight: _calculateTextHeight(subtitleText, _thumbnailSize?.width ?? MediaQuery.of(context).size.width * 0.8 * 0.4),
              bgColor: bgColor,
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
      padding: EdgeInsets.only(top: ResponsiveSizes.h2),
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
    Color? selectedColor = initialColor;

    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('색상 선택', style: TextStyle(fontSize: ResponsiveSizes.textSize(4))),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('취소', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selectedColor),
            child: Text('확인', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}