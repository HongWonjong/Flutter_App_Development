import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';

// 디바운스 함수 정의
void Function() debounce(void Function() func, Duration duration) {
  Timer? timer;
  return () {
    if (timer?.isActive ?? false) timer!.cancel();
    timer = Timer(duration, func);
  };
}

class FloatingWidgetList extends StatefulWidget {
  final String roomKey;
  final bool isEditMode;
  final Function(Map<String, dynamic>) onAddWidget;
  final Function(Map<String, dynamic>) onRemoveWidget;
  final Function(Map<String, dynamic>) onUpdateWidget;
  final Function(Map<String, dynamic>) onAddGuideline;
  final Function(Map<String, dynamic>) onRemoveGuideline;
  final Color backgroundColor;
  final Function(Color) onBackgroundColorChanged;
  final Color appBarColor;
  final Function(Color) onAppBarColorChanged;
  final String roomTitle;
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
    required this.backgroundColor,
    required this.onBackgroundColorChanged,
    required this.appBarColor,
    required this.onAppBarColorChanged,
    required this.roomTitle,
    required this.onUpdateRoomTitle,
  });

  @override
  State<FloatingWidgetList> createState() => _FloatingWidgetListState();
}

class _FloatingWidgetListState extends State<FloatingWidgetList> {
  late Stream<DocumentSnapshot> _roomStream;
  late void Function() _debouncedAddWidget;
  late void Function() _debouncedRemoveWidget;
  late void Function() _debouncedUpdateWidget;
  late void Function() _debouncedAddGuideline;
  late void Function() _debouncedRemoveGuideline;
  late void Function() _debouncedBackgroundColorUpdate;
  late void Function() _debouncedAppBarColorUpdate;
  late void Function() _debouncedUpdateRoomTitle;

  Map<String, dynamic>? _pendingWidgetData;
  Map<String, dynamic>? _pendingGuidelineData;
  Color? _pendingBackgroundColor;
  Color? _pendingAppBarColor;
  String? _pendingRoomTitle;

  @override
  void initState() {
    super.initState();
    _roomStream = FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).snapshots();

    _debouncedAddWidget = debounce(() {
      if (_pendingWidgetData != null) widget.onAddWidget(_pendingWidgetData!);
    }, const Duration(milliseconds: 300));
    _debouncedRemoveWidget = debounce(() {
      if (_pendingWidgetData != null) widget.onRemoveWidget(_pendingWidgetData!);
    }, const Duration(milliseconds: 300));
    _debouncedUpdateWidget = debounce(() {
      if (_pendingWidgetData != null) widget.onUpdateWidget(_pendingWidgetData!);
    }, const Duration(milliseconds: 300));
    _debouncedAddGuideline = debounce(() {
      if (_pendingGuidelineData != null) widget.onAddGuideline(_pendingGuidelineData!);
    }, const Duration(milliseconds: 300));
    _debouncedRemoveGuideline = debounce(() {
      if (_pendingGuidelineData != null) widget.onRemoveGuideline(_pendingGuidelineData!);
    }, const Duration(milliseconds: 300));
    _debouncedBackgroundColorUpdate = debounce(() {
      if (_pendingBackgroundColor != null) widget.onBackgroundColorChanged(_pendingBackgroundColor!);
    }, const Duration(milliseconds: 300));
    _debouncedAppBarColorUpdate = debounce(() {
      if (_pendingAppBarColor != null) widget.onAppBarColorChanged(_pendingAppBarColor!);
    }, const Duration(milliseconds: 300));
    _debouncedUpdateRoomTitle = debounce(() {
      if (_pendingRoomTitle != null) widget.onUpdateRoomTitle(_pendingRoomTitle!);
    }, const Duration(milliseconds: 300));
  }

  void _showColorPicker(BuildContext context, Function(Color) onColorChanged, Color initialColor) {
    Color currentColor = initialColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              currentColor = color;
              setState(() {
                if (onColorChanged == widget.onBackgroundColorChanged) {
                  _pendingBackgroundColor = color;
                  _debouncedBackgroundColorUpdate();
                } else if (onColorChanged == widget.onAppBarColorChanged) {
                  _pendingAppBarColor = color;
                  _debouncedAppBarColorUpdate();
                }
              });
            },
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
            final roomData = snapshot.data!.data() as Map<String, dynamic>?;
            final widgets = roomData?['widgets'] as List<dynamic>? ?? [];
            final guidelines = roomData?['guidelines'] as List<dynamic>? ?? [];

            return Container(
              color: widget.backgroundColor,
              child: Stack(
                children: [
                  ...widgets.map((widgetData) => _buildWidget(context, widgetData as Map<String, dynamic>, screenWidth, screenHeight)),
                  ...guidelines.map((guidelineData) => _buildGuideline(context, guidelineData as Map<String, dynamic>, screenWidth, screenHeight)),
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
                                    onPressed: () {
                                      _pendingWidgetData = {
                                        'id': Uuid().v4(),
                                        'type': 'text',
                                        'content': '새 텍스트',
                                        'position': {'x': screenWidth * 0.1, 'y': screenHeight * 0.1},
                                        'style': {'fontSizeFactor': 0.04, 'color': '#000000', 'alignment': 'center', 'widthFactor': 0.2, 'heightFactor': 0.1},
                                      };
                                      _debouncedAddWidget();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('텍스트'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      _pendingWidgetData = {
                                        'id': Uuid().v4(),
                                        'type': 'image',
                                        'content': 'https://via.placeholder.com/150',
                                        'position': {'x': screenWidth * 0.1, 'y': screenHeight * 0.1},
                                        'style': {'fontSizeFactor': 0.04, 'color': '#000000', 'alignment': 'center', 'widthFactor': 0.2, 'heightFactor': 0.1},
                                      };
                                      _debouncedAddWidget();
                                    },
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
                                    onPressed: () {
                                      _pendingGuidelineData = {
                                        'id': Uuid().v4(),
                                        'type': 'horizontal',
                                        'position': screenHeight * 0.5,
                                        'color': '#FF0000',
                                      };
                                      _debouncedAddGuideline();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('가로선'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      _pendingGuidelineData = {
                                        'id': Uuid().v4(),
                                        'type': 'vertical',
                                        'position': screenWidth * 0.5,
                                        'color': '#FF0000',
                                      };
                                      _debouncedAddGuideline();
                                    },
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
                                    onPressed: () => _showColorPicker(context, widget.onBackgroundColorChanged, widget.backgroundColor),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen[300],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('배경색'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _showColorPicker(context, widget.onAppBarColorChanged, widget.appBarColor),
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
    final color = Color(int.parse(style['color'].replaceAll('#', '0xff')));
    final fontSize = screenWidth * (style['fontSizeFactor'] as double);
    final width = screenWidth * (style['widthFactor'] as double);
    final height = screenHeight * (style['heightFactor'] as double);

    Widget content;
    switch (widgetData['type']) {
      case 'text':
        content = Text(widgetData['content'], style: TextStyle(fontSize: fontSize, color: color));
        break;
      case 'image':
        content = Image.network(widgetData['content'], width: width, height: height);
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Positioned(
      left: position['x'] as double,
      top: position['y'] as double,
      child: GestureDetector(
        onTap: widget.isEditMode ? () => _showEditPanel(context, widgetData, screenWidth, screenHeight) : null,
        onPanUpdate: widget.isEditMode ? (details) => _updatePosition(widgetData, details) : null,
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
    final position = guidelineData['position'] as double;
    final color = Color(int.parse((guidelineData['color'] as String).replaceAll('#', '0xff')));

    return Positioned(
      top: type == 'horizontal' ? position : 0,
      left: type == 'vertical' ? position : 0,
      child: GestureDetector(
        onTap: widget.isEditMode ? () => _showGuidelineOptions(context, guidelineData, screenWidth, screenHeight) : null,
        onPanUpdate: widget.isEditMode ? (details) => _updateGuidelinePosition(guidelineData, details) : null,
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
                    onPressed: () {
                      _pendingGuidelineData = guidelineData;
                      _debouncedRemoveGuideline();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePosition(Map<String, dynamic> widgetData, DragUpdateDetails details) {
    final position = widgetData['position'] as Map<String, dynamic>;
    position['x'] = (position['x'] as double) + details.delta.dx;
    position['y'] = (position['y'] as double) + details.delta.dy;
    _pendingWidgetData = widgetData;
    _debouncedUpdateWidget();
  }

  void _updateGuidelinePosition(Map<String, dynamic> guidelineData, DragUpdateDetails details) {
    final type = guidelineData['type'] as String;
    guidelineData['position'] = (guidelineData['position'] as double) +
        (type == 'horizontal' ? details.delta.dy : details.delta.dx);
    _pendingGuidelineData = guidelineData;
    _debouncedUpdateWidget();
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
                    _pendingWidgetData = widgetData;
                    _debouncedUpdateWidget();
                  }, Color(int.parse(style['color'].replaceAll('#', '0xff')))),
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
                _pendingWidgetData = widgetData;
                _debouncedUpdateWidget();
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
            TextButton(
              onPressed: () {
                _pendingWidgetData = widgetData;
                _debouncedRemoveWidget();
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
    Color currentColor = Color(int.parse((guidelineData['color'] as String).replaceAll('#', '0xff')));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$type 기준선 편집'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: '위치 (${type == 'horizontal' ? 'Y' : 'X'}축)'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: newPosition.toString()),
                  onChanged: (value) => newPosition = double.parse(value),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showColorPicker(context, (color) {
                    guidelineData['color'] = '#${color.value.toRadixString(16).substring(2)}';
                    _pendingGuidelineData = guidelineData;
                    _debouncedUpdateWidget();
                  }, currentColor),
                  child: const Text('색상 선택'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                guidelineData['position'] = newPosition;
                _pendingGuidelineData = guidelineData;
                _debouncedUpdateWidget();
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
            TextButton(
              onPressed: () {
                _pendingGuidelineData = guidelineData;
                _debouncedRemoveGuideline();
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showTitleDialog(BuildContext context) {
    final TextEditingController tempController = TextEditingController(text: widget.roomTitle);
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
              _pendingRoomTitle = tempController.text;
              _debouncedUpdateRoomTitle();
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}