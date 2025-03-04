import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';

class FloatingWidgetList extends StatefulWidget {
  final String roomKey;
  final bool isEditMode;
  final Function(Map<String, dynamic>) onAddWidget;
  final Function(Map<String, dynamic>) onRemoveWidget;
  final Function(Map<String, dynamic>) onUpdateWidget;
  final Function(Map<String, dynamic>) onAddGuideline;
  final Function(Map<String, dynamic>) onRemoveGuideline;
  final Function(String) onUpdateRoomTitle;

  const FloatingWidgetList({
    super.key,
    required this.roomKey,
    required this.isEditMode,
    required this.onAddWidget,
    required this.onRemoveWidget,
    required this.onUpdateWidget,
    required this.onAddGuideline,
    required this.onRemoveGuideline,
    required this.onUpdateRoomTitle,
  });

  @override
  State<FloatingWidgetList> createState() => _FloatingWidgetListState();
}

class _FloatingWidgetListState extends State<FloatingWidgetList> {
  late Stream<DocumentSnapshot> _roomStream;
  Map<String, Map<String, dynamic>> _localWidgets = {};
  Map<String, Map<String, dynamic>> _localGuidelines = {};
  Timer? _debounceTimer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _roomStream = FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).snapshots();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debouncedUpdate(Map<String, dynamic> data) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onUpdateWidget(data);
    });
  }

  void _startDragging() {
    setState(() {
      _isDragging = true;
    });
  }

  void _stopDragging(Map<String, dynamic> data) {
    setState(() {
      _isDragging = false;
    });
    _debouncedUpdate(data);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _roomStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final roomData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final widgets = roomData['widgets'] as List<dynamic>? ?? [];
            final guidelines = roomData['guidelines'] as List<dynamic>? ?? [];
            final backgroundColor = Color(int.parse((roomData['backgroundColor'] as String? ?? '#FFFFFF').replaceAll('#', '0xff')));
            final appBarColor = Color(int.parse((roomData['appBarColor'] as String? ?? '#42A5F5').replaceAll('#', '0xff')));

            // 드래그 중이 아닐 때만 Firestore 데이터를 로컬 상태에 반영
            if (!_isDragging) {
              _localWidgets = {
                for (var w in widgets)
                  w['id']: Map<String, dynamic>.from(w)
                    ..update(
                      'position',
                          (pos) => {
                        'xfactor': (pos['xfactor'] ?? (pos['x'] ?? 0.0) / screenWidth).toDouble().clamp(0.0, 1.0),
                        'yfactor': (pos['yfactor'] ?? (pos['y'] ?? 0.0) / screenHeight).toDouble().clamp(0.0, 1.0),
                      },
                      ifAbsent: () => {'xfactor': 0.0, 'yfactor': 0.0},
                    )
              };
              _localGuidelines = {
                for (var g in guidelines)
                  g['id']: Map<String, dynamic>.from(g)
                    ..update(
                      'position',
                          (pos) => (pos is double ? pos : 0.5).toDouble().clamp(0.0, 1.0),
                      ifAbsent: () => 0.5,
                    )
              };
            }

            return Container(
              color: backgroundColor,
              width: screenWidth, // 명시적으로 크기 지정
              height: screenHeight, // 명시적으로 크기 지정
              child: Stack(
                children: [
                  ..._localWidgets.values.map((widgetData) => _buildWidget(context, widgetData, screenWidth, screenHeight)),
                  ..._localGuidelines.values.map((guidelineData) => _buildGuideline(context, guidelineData, screenWidth, screenHeight)),
                  if (widget.isEditMode)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: () => _showTitleDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightGreen[300],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('방 제목'),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => widget.onAddWidget({
                                      'id': Uuid().v4(),
                                      'type': 'text',
                                      'content': '새 텍스트',
                                      'position': {'xfactor': 0.1, 'yfactor': 0.1},
                                      'style': {'fontSizeFactor': 0.01, 'color': '#000000', 'alignment': 'center', 'widthFactor': 0.3, 'heightFactor': 0.15},
                                    }),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('텍스트'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => widget.onAddWidget({
                                      'id': Uuid().v4(),
                                      'type': 'image',
                                      'content': 'https://via.placeholder.com/150',
                                      'position': {'xfactor': 0.1, 'yfactor': 0.1},
                                      'style': {'fontSizeFactor': 0.01, 'color': '#000000', 'alignment': 'center', 'widthFactor': 0.3, 'heightFactor': 0.15},
                                    }),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('이미지'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => widget.onAddGuideline({
                                      'id': Uuid().v4(),
                                      'type': 'horizontal',
                                      'position': 0.5,
                                      'color': '#FF0000',
                                    }),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('가로선'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => widget.onAddGuideline({
                                      'id': Uuid().v4(),
                                      'type': 'vertical',
                                      'position': 0.5,
                                      'color': '#FF0000',
                                    }),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('세로선'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _showColorPicker(context, (color) {
                                      FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).update({
                                        'backgroundColor': '#${color.value.toRadixString(16).substring(2)}',
                                      });
                                    }),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('배경색'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _showColorPicker(context, (color) {
                                      FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).update({
                                        'appBarColor': '#${color.value.toRadixString(16).substring(2)}',
                                      });
                                    }),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('앱 바 색상'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, Map<String, dynamic> widgetData, double screenWidth, double screenHeight) {
    final style = widgetData['style'] as Map<String, dynamic>;
    final position = widgetData['position'] as Map<String, dynamic>;
    final xfactor = (position['xfactor'] as double?) ?? 0.0;
    final yfactor = (position['yfactor'] as double?) ?? 0.0;
    final color = Color(int.parse(style['color'].replaceAll('#', '0xff')));
    final fontSize = screenWidth * (style['fontSizeFactor'] as double);
    final width = screenWidth * (style['widthFactor'] as double);
    final height = screenHeight * (style['heightFactor'] as double);

    // 화면 밖으로 나가지 않도록 위치 조정
    final left = (xfactor * screenWidth).clamp(0.0, screenWidth - width);
    final top = (yfactor * screenHeight).clamp(0.0, screenHeight - height);

    Widget content;
    switch (widgetData['type']) {
      case 'text':
        content = Text(widgetData['content'], style: TextStyle(fontSize: fontSize, color: color));
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
        onTap: widget.isEditMode ? () => _showEditPanel(context, widgetData, screenWidth, screenHeight) : null,
        onPanStart: widget.isEditMode ? (_) => _startDragging() : null,
        onPanUpdate: widget.isEditMode ? (details) => _updatePosition(widgetData, details, screenWidth, screenHeight) : null,
        onPanEnd: widget.isEditMode ? (_) => _stopDragging(widgetData) : null,
        child: Container(
          width: width,
          height: height,
          alignment: _getAlignment(style['alignment'] as String),
          decoration: widget.isEditMode ? BoxDecoration(border: Border.all(color: Colors.blue)) : null,
          child: content,
        ),
      ),
    );
  }

  Widget _buildGuideline(BuildContext context, Map<String, dynamic> guidelineData, double screenWidth, double screenHeight) {
    final type = guidelineData['type'] as String;
    final positionFactor = (guidelineData['position'] as double?) ?? 0.5;
    final color = Color(int.parse((guidelineData['color'] as String).replaceAll('#', '0xff')));

    return Positioned(
      top: type == 'horizontal' ? (positionFactor * screenHeight).clamp(0.0, screenHeight - 3) : 0,
      left: type == 'vertical' ? (positionFactor * screenWidth).clamp(0.0, screenWidth - 3) : 0,
      child: GestureDetector(
        onTap: widget.isEditMode ? () => _showGuidelineOptions(context, guidelineData, screenWidth, screenHeight) : null,
        onPanStart: widget.isEditMode ? (_) => _startDragging() : null,
        onPanUpdate: widget.isEditMode ? (details) => _updateGuidelinePosition(guidelineData, details, screenWidth, screenHeight) : null,
        onPanEnd: widget.isEditMode ? (_) => _stopDragging(guidelineData) : null,
        child: SizedBox(
          width: type == 'horizontal' ? screenWidth : 3,
          height: type == 'vertical' ? screenHeight * 1.5 : 3,
          child: Stack(
            children: [
              Container(color: color.withOpacity(0.5)),
              if (widget.isEditMode)
                Positioned(
                  right: type == 'horizontal' ? 0 : null,
                  bottom: type == 'vertical' ? 0 : null,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => widget.onRemoveGuideline(guidelineData),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePosition(Map<String, dynamic> widgetData, DragUpdateDetails details, double screenWidth, double screenHeight) {
    final position = widgetData['position'] as Map<String, dynamic>;
    final style = widgetData['style'] as Map<String, dynamic>;
    final widthFactor = style['widthFactor'] as double;
    final heightFactor = style['heightFactor'] as double;

    position['xfactor'] = ((position['xfactor'] as double?) ?? 0.0) + details.delta.dx / screenWidth;
    position['yfactor'] = ((position['yfactor'] as double?) ?? 0.0) + details.delta.dy / screenHeight;

    // 위젯이 화면 밖으로 나가지 않도록 제한
    position['xfactor'] = position['xfactor'].clamp(0.0, 1.0 - widthFactor);
    position['yfactor'] = position['yfactor'].clamp(0.0, 1.0 - heightFactor);

    _localWidgets[widgetData['id']] = Map.from(widgetData);
    setState(() {});
  }

  void _updateGuidelinePosition(Map<String, dynamic> guidelineData, DragUpdateDetails details, double screenWidth, double screenHeight) {
    final type = guidelineData['type'] as String;
    guidelineData['position'] = ((guidelineData['position'] as double?) ?? 0.5) +
        (type == 'horizontal' ? details.delta.dy / screenHeight : details.delta.dx / screenWidth);

    // 기준선이 화면 밖으로 나가지 않도록 제한
    guidelineData['position'] = guidelineData['position'].clamp(0.0, 1.0);

    _localGuidelines[guidelineData['id']] = Map.from(guidelineData);
    setState(() {});
  }

  Alignment _getAlignment(String alignment) {
    switch (alignment) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      case 'center':
      default:
        return Alignment.center;
    }
  }

  void _showEditPanel(BuildContext context, Map<String, dynamic> widgetData, double screenWidth, double screenHeight) {
    final style = widgetData['style'] as Map<String, dynamic>;
    String newContent = widgetData['content'];
    double fontSizeFactor = style['fontSizeFactor'] as double;
    double widthFactor = style['widthFactor'] as double;
    double heightFactor = style['heightFactor'] as double;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${widgetData['type']} 편집'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: '내용'),
                  controller: TextEditingController(text: newContent),
                  onChanged: (value) => newContent = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: '글꼴 크기 비율 (0.01~0.2)'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: fontSizeFactor.toString()),
                  onChanged: (value) => fontSizeFactor = double.parse(value).clamp(0.01, 0.2),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: '너비 비율 (0.1~1.0)'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: widthFactor.toString()),
                  onChanged: (value) => widthFactor = double.parse(value).clamp(0.1, 1.0),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: '높이 비율 (0.05~0.5)'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: heightFactor.toString()),
                  onChanged: (value) => heightFactor = double.parse(value).clamp(0.05, 0.5),
                ),
                DropdownButton<String>(
                  value: style['alignment'],
                  items: ['left', 'center', 'right'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (value) => setState(() => style['alignment'] = value!),
                ),
                ElevatedButton(
                  onPressed: () => _showColorPicker(context, (color) {
                    style['color'] = '#${color.value.toRadixString(16).substring(2)}';
                    widget.onUpdateWidget(widgetData);
                  }),
                  child: const Text('색상 선택'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                widgetData['content'] = newContent;
                style['fontSizeFactor'] = fontSizeFactor;
                style['widthFactor'] = widthFactor;
                style['heightFactor'] = heightFactor;
                widget.onUpdateWidget(widgetData);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
            TextButton(
              onPressed: () {
                widget.onRemoveWidget(widgetData);
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showGuidelineOptions(BuildContext context, Map<String, dynamic> guidelineData, double screenWidth, double screenHeight) {
    final type = guidelineData['type'] as String;
    double newPosition = guidelineData['position'] as double;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$type 기준선 편집'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: '위치 비율 (0.0~1.0)'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: newPosition.toString()),
                  onChanged: (value) => newPosition = double.parse(value).clamp(0.0, 1.0),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showColorPicker(context, (color) {
                    guidelineData['color'] = '#${color.value.toRadixString(16).substring(2)}';
                    widget.onUpdateWidget(guidelineData);
                  }),
                  child: const Text('색상 선택'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                guidelineData['position'] = newPosition;
                widget.onUpdateWidget(guidelineData);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
            TextButton(
              onPressed: () {
                widget.onRemoveGuideline(guidelineData);
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, ValueChanged<Color> onColorChanged) {
    Color currentColor = Colors.white;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) => currentColor = color,
          ),
        ),
        actions: [
          TextButton(
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

  void _showTitleDialog(BuildContext context) {
    final TextEditingController tempController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('방 제목 변경'),
        content: TextField(
          controller: tempController,
          decoration: const InputDecoration(hintText: '새 제목을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              widget.onUpdateRoomTitle(tempController.text);
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}