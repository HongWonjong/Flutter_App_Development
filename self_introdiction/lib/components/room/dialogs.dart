import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void showEditPanel(
    BuildContext context,
    Map<String, dynamic> widgetData,
    double screenWidth,
    double screenHeight,
    Function(Map<String, dynamic>) onUpdateWidget,
    Function(Map<String, dynamic>) onRemoveWidget) {
  final style = widgetData['style'] as Map<String, dynamic>;
  String newContent = widgetData['content'];
  double fontSizeFactor = style['fontSizeFactor'] as double;
  double widthFactor = style['widthFactor'] as double;
  double heightFactor = style['heightFactor'] as double;

  // 버튼 전용 속성
  String newUrl = widgetData['type'] == 'button' ? (widgetData['url'] ?? 'https://example.com') : '';
  double borderRadius = widgetData['type'] == 'button' ? (style['borderRadius'] as double? ?? 0.0) : 0.0;
  double opacity = widgetData['type'] == 'button' ? (style['opacity'] as double? ?? 1.0) : 1.0;

  showDialog(
    context: context,
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        title: Text(
          '${widgetData['type']} 편집',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                label: '내용',
                initialValue: newContent,
                onChanged: (value) => newContent = value,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              if (widgetData['type'] == 'button') ...[
                _buildTextField(
                  label: 'URL',
                  initialValue: newUrl,
                  onChanged: (value) => newUrl = value,
                  keyboardType: TextInputType.url,
                ),
                _buildNumberField(
                  label: '둥글기 (0.0~1.0)',
                  initialValue: borderRadius,
                  onChanged: (value) => borderRadius = value.clamp(0.0, 1.0),
                ),
                _buildNumberField(
                  label: '투명도 (0.0~1.0)',
                  initialValue: opacity,
                  onChanged: (value) => opacity = value.clamp(0.0, 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FilledButton(
                    onPressed: () => showColorPicker(context, (color) {
                      style['backgroundColor'] = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      onUpdateWidget(widgetData);
                    }),
                    child: const Text('배경색 선택'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FilledButton(
                    onPressed: () => showColorPicker(context, (color) {
                      style['textColor'] = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      onUpdateWidget(widgetData);
                    }),
                    child: const Text('텍스트 색상 선택'),
                  ),
                ),
              ],
              _buildNumberField(
                label: '글꼴 크기 비율 (0.01~0.2)',
                initialValue: fontSizeFactor,
                onChanged: (value) => fontSizeFactor = value.clamp(0.01, 0.2),
              ),
              _buildNumberField(
                label: '너비 비율 (0.1~1.0)',
                initialValue: widthFactor,
                onChanged: (value) => widthFactor = value.clamp(0.1, 1.0),
              ),
              _buildNumberField(
                label: '높이 비율 (0.05~0.5)',
                initialValue: heightFactor,
                onChanged: (value) => heightFactor = value.clamp(0.05, 0.5),
              ),
              if (widgetData['type'] != 'button')
                _buildDropdown(
                  value: style['alignment'],
                  items: ['left', 'center', 'right'],
                  onChanged: (value) => style['alignment'] = value!,
                ),
              if (widgetData['type'] != 'button')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: FilledButton(
                    onPressed: () => showColorPicker(context, (color) {
                      style['color'] = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      onUpdateWidget(widgetData);
                    }),
                    child: const Text('색상 선택'),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              widgetData['content'] = newContent;
              style['fontSizeFactor'] = fontSizeFactor;
              style['widthFactor'] = widthFactor;
              style['heightFactor'] = heightFactor;
              if (widgetData['type'] == 'button') {
                widgetData['url'] = newUrl;
                style['borderRadius'] = borderRadius;
                style['opacity'] = opacity;
              }
              onUpdateWidget(widgetData);
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              onRemoveWidget(widgetData);
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    ),
  );
}

void showGuidelineOptions(
    BuildContext context,
    Map<String, dynamic> guidelineData,
    double screenWidth,
    double screenHeight,
    Function(Map<String, dynamic>) onUpdateWidget,
    Function(Map<String, dynamic>) onRemoveGuideline) {
  final type = guidelineData['type'] as String;
  double newPosition = guidelineData['position'] as double;

  showDialog(
    context: context,
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        title: Text(
          '$type 기준선 편집',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNumberField(
                label: '위치 비율 (0.0~1.0)',
                initialValue: newPosition,
                onChanged: (value) => newPosition = value.clamp(0.0, 1.0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FilledButton(
                  onPressed: () => showColorPicker(context, (color) {
                    guidelineData['color'] = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                    onUpdateWidget(guidelineData);
                  }),
                  child: const Text('색상 선택'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              guidelineData['position'] = newPosition;
              onUpdateWidget(guidelineData);
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              onRemoveGuideline(guidelineData);
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    ),
  );
}

void showColorPicker(BuildContext context, ValueChanged<Color> onColorChanged) {
  Color currentColor = Colors.white.withOpacity(0.5); // 초기 색상도 연하게 설정
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('색상 선택', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: currentColor,
          onColorChanged: (color) => currentColor = color,
          availableColors: [
            Colors.red.withOpacity(0.5),
            Colors.blue.withOpacity(0.5),
            Colors.green.withOpacity(0.5),
            Colors.yellow.withOpacity(0.5),
            Colors.purple.withOpacity(0.5),
            Colors.orange.withOpacity(0.5),
            Colors.teal.withOpacity(0.5),
            Colors.pink.withOpacity(0.5),
            Colors.cyan.withOpacity(0.5),
            Colors.lime.withOpacity(0.5),
            Colors.indigo.withOpacity(0.5),
            Colors.amber.withOpacity(0.5),
            Colors.grey.withOpacity(0.5),
            Colors.grey.shade200.withOpacity(0.5),
            Colors.grey.shade400.withOpacity(0.5),
            Colors.grey.shade600.withOpacity(0.5),
            Colors.black.withOpacity(0.5),
            Colors.white.withOpacity(0.5),
            const Color(0x801A237E),
            const Color(0x8000695C),
            const Color(0x802E7D32),
            const Color(0x80AD1457),
            const Color(0x80D81B60),
            const Color(0x804A148C),
            const Color(0x803E2723),
            const Color(0x80FF8A65),
            const Color(0x80F9A825),
            const Color(0x800277BD),
            const Color(0x808E24AA),
            const Color(0x80880E4F),
            const Color(0xB2B2EBF2),
            const Color(0xB2DCEDC8),
            const Color(0xB2FFE0B2),
            const Color(0xB2F8BBD0),
            const Color(0xB2D1C4E9),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            onColorChanged(currentColor);
            Navigator.pop(context);
          },
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

void showTitleDialog(BuildContext context, Function(String) onUpdateRoomTitle) {
  final TextEditingController tempController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      title: const Text('방 제목 변경', style: TextStyle(fontWeight: FontWeight.bold)),
      content: _buildTextField(
        label: '새 제목을 입력하세요',
        controller: tempController,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            onUpdateRoomTitle(tempController.text);
            Navigator.pop(context);
          },
          child: const Text('저장'),
        ),
      ],
    ),
  );
}

// 헬퍼 위젯들
Widget _buildTextField({
  required String label,
  String? initialValue,
  TextEditingController? controller,
  ValueChanged<String>? onChanged,
  int? maxLines,
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      controller: controller ?? TextEditingController(text: initialValue),
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
    ),
  );
}

Widget _buildNumberField({
  required String label,
  required double initialValue,
  required ValueChanged<double> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: initialValue.toString()),
      onChanged: (value) => onChanged(double.tryParse(value) ?? initialValue),
    ),
  );
}

Widget _buildDropdown({
  required String value,
  required List<String> items,
  required ValueChanged<String> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (newValue) => onChanged(newValue!),
    ),
  );
}