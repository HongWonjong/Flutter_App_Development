import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts 유지
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
  late double subtitlePosition;
  late double fontSize;
  late String fontFamily;
  late Color textColor;
  late Color bgColor;
  late double paddingVertical;
  late double paddingHorizontal;
  double? _imageAspectRatio; // 이미지 비율
  Size? _thumbnailSize; // 썸네일 실제 크기
  final GlobalKey _thumbnailKey = GlobalKey(); // 썸네일 크기 측정용 키

  @override
  void initState() {
    super.initState();
    _loadCurrentStyle(); // 초기화 시 기존 스타일 로드
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

  void _loadCurrentStyle() {
    final currentStyle = ref.read(subtitleStyleProvider);
    setState(() {
      subtitlePosition = currentStyle.subtitlePosition;
      fontSize = currentStyle.fontSize;
      fontFamily = currentStyle.fontFamily;
      textColor = currentStyle.textColor;
      bgColor = currentStyle.bgColor; // 투명도 제거
      paddingVertical = currentStyle.bgHeight / 2; // 상하 여백 계산
      paddingHorizontal = 12.0; // 초기값 유지
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

  double _calculateTextHeight(String text, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.getFont(fontFamily,
          fontSize: fontSize,
          color: textColor, // 투명도 제거
          height: 1.2,
        ),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    )..layout(maxWidth: maxWidth - paddingHorizontal * 2);
    return textPainter.height + paddingVertical * 2;
  }

  @override
  Widget build(BuildContext context) {
    final subtitleText = ref.watch(srtModifyProvider).firstSubtitle ?? '자막 없음';
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent, // 배경 투명으로 설정
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.75,
        padding: EdgeInsets.all(ResponsiveSizes.h2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[100]!], // 밝은 그라디언트 배경
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 영역 (theme.primaryColor 적용)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveSizes.h2),
              color: theme.primaryColor,
              child: Text(
                '자막 스타일 편집',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveSizes.textSize(5),
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 흰색 텍스트로 변경
                ),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 좌측: 미리보기 영역
                  Expanded(
                    flex: 2,
                    child: _buildPreviewThumbnail(subtitleText),
                  ),
                  SizedBox(width: ResponsiveSizes.h5),
                  // 우측: 스타일 조절 영역
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(ResponsiveSizes.h3),
                        child: _buildStyleControls(subtitleText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 버튼 영역 (제출 버튼에 theme.primaryColor 적용)
            Padding(
              padding: EdgeInsets.all(ResponsiveSizes.h2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSizes.h3,
                        vertical: ResponsiveSizes.h2,
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSizes.textSize(3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveSizes.h3),
                  ElevatedButton(
                    onPressed: () {
                      final updatedState = SubtitleStyleState(
                        fontSize: fontSize,
                        fontFamily: fontFamily,
                        textColor: textColor,
                        bgHeight: _calculateTextHeight(subtitleText,
                            _thumbnailSize?.width ?? MediaQuery.of(context).size.width * 0.85 * 0.4),
                        bgColor: bgColor,
                        subtitlePosition: subtitlePosition,
                      );
                      // 상태 업데이트
                      ref.read(subtitleStyleProvider.notifier).state = updatedState;
                      Navigator.pop(context, updatedState);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor, // theme.primaryColor 적용
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSizes.h3,
                        vertical: ResponsiveSizes.h2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '적용',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSizes.textSize(3),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewThumbnail(String subtitleText) {
    return Container(
      padding: EdgeInsets.all(ResponsiveSizes.h2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _imageAspectRatio == null
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _updateThumbnailSize());

          final thumbnailWidth = _thumbnailSize?.width ?? constraints.maxWidth;
          final thumbnailHeight = _thumbnailSize?.height ?? (thumbnailWidth / (_imageAspectRatio ?? 1.0));
          final textHeight = _calculateTextHeight(subtitleText, thumbnailWidth);

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
                          height: textHeight,
                          decoration: BoxDecoration(
                            color: bgColor, // 투명도 제거
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              subtitleText,
                              style: GoogleFonts.getFont(fontFamily,
                                fontSize: fontSize,
                                color: textColor, // 투명도 제거
                                height: 1.2,
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
    );
  }

  Widget _buildStyleControls(String subtitleText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('자막 스타일', [
          _buildSlider('글씨 크기', fontSize, 10, 50, (value) => setState(() => fontSize = value)),
          _buildFontDropdown(),
          _buildColorPicker('글씨 색상', textColor, (color) => setState(() => textColor = color)),
        ]),
        _buildSection('배경 스타일', [
          _buildColorPicker('배경 색상', bgColor, (color) => setState(() => bgColor = color)),
          _buildSlider('상하 여백', paddingVertical, 0, 20, (value) => setState(() => paddingVertical = value)),
          _buildSlider('좌우 여백', paddingHorizontal, 0, 30, (value) => setState(() => paddingHorizontal = value)),
        ]),
        _buildSection('자막 위치', [
          _buildSlider('수직 위치', subtitlePosition, 0, 100, (value) => setState(() => subtitlePosition = value)),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveSizes.h3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveSizes.h2),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveSizes.textSize(4),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...children.map((child) => Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveSizes.h3, vertical: ResponsiveSizes.h2),
            child: child,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSizes.textSize(3),
            color: Colors.grey[800],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: Colors.green[300]!,
          inactiveColor: Colors.grey[300],
          thumbColor: Colors.green[400]!,
        ),
      ],
    );
  }

  Widget _buildFontDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '글씨체',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSizes.textSize(3),
            color: Colors.grey[800],
          ),
        ),
        DropdownButton<String>(
          value: fontFamily,
          items: [
            'Noto Sans',
            'Roboto',
            'Open Sans',
            'Lora',
            'Alumni Sans',
            'Montserrat',
            'Poppins',
            'Merriweather',
            'Inter',
            'Cabin',
            'Playfair Display',
            'Quicksand',
            'Fira Sans',
            'Karla',
          ].map((font) => DropdownMenuItem(
            value: font,
            child: Text(
              font,
              style: GoogleFonts.getFont(font, fontSize: ResponsiveSizes.textSize(3)),
            ),
          )).toList(),
          onChanged: (value) => setState(() => fontFamily = value!),
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSizes.textSize(3),
            color: Colors.black87,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          icon: Icon(Icons.arrow_drop_down),
          elevation: 4,
        ),
      ],
    );
  }

  Widget _buildColorPicker(String label, Color currentColor, Function(Color) onColorChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveSizes.textSize(3),
            color: Colors.grey[800],
          ),
        ),
        InkWell(
          onTap: () => _showColorPickerDialog(context, currentColor, onColorChanged),
          child: Container(
            width: ResponsiveSizes.h5,
            height: ResponsiveSizes.h5,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showColorPickerDialog(BuildContext context, Color initialColor, Function(Color) onColorChanged) async {
    Color? selectedColor = initialColor;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSizes.h2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '색상 선택',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveSizes.textSize(4),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: ResponsiveSizes.h2),
              ColorPicker(
                pickerColor: initialColor,
                onColorChanged: (color) => selectedColor = color,
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false, // 투명도 옵션 제거
                displayThumbColor: true,
                colorPickerWidth: 300,
                pickerAreaBorderRadius: BorderRadius.circular(8),
                paletteType: PaletteType.hsvWithHue,
                labelTypes: const [],
              ),
              SizedBox(height: ResponsiveSizes.h2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '취소',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSizes.textSize(3),
                        color: Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveSizes.h3),
                  TextButton(
                    onPressed: () {
                      if (selectedColor != null) onColorChanged(selectedColor!);
                      Navigator.pop(context);
                    },
                    child: Text(
                      '확인',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSizes.textSize(3),
                        color: Theme.of(context).primaryColor, // theme.primaryColor 적용
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}