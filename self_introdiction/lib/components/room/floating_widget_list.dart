import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'widget_renderer.dart';
import 'guideline_renderer.dart';
import 'position_updater.dart';
import 'dialogs.dart';

class FloatingWidgetList extends StatefulWidget {
  final String roomKey;
  final bool isEditMode;
  final Function(Map<String, dynamic>) onAddWidget;
  final Function(Map<String, dynamic>) onRemoveWidget;
  final Function(Map<String, dynamic>) onUpdateWidget;
  final Function(Map<String, dynamic>) onAddGuideline;
  final Function(Map<String, dynamic>) onRemoveGuideline;
  final Function(Map<String, dynamic>) onUpdateGuideline;
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
    required this.onUpdateGuideline,
    required this.onUpdateRoomTitle,
  });

  @override
  State<FloatingWidgetList> createState() => _FloatingWidgetListState();
}

class _FloatingWidgetListState extends State<FloatingWidgetList> {
  late Stream<DocumentSnapshot> _roomStream;
  Map<String, Map<String, dynamic>> _localWidgets = {};
  Map<String, Map<String, dynamic>> _localGuidelines = {};
  final PositionUpdater _positionUpdater = PositionUpdater();
  bool _isDragging = false;
  Map<String, dynamic>? _lastRoomData;

  @override
  void initState() {
    super.initState();
    _roomStream = FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).snapshots();
  }

  @override
  void dispose() {
    _positionUpdater.dispose();
    super.dispose();
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
    if (data.containsKey('type') && (data['type'] == 'horizontal' || data['type'] == 'vertical')) {
      _positionUpdater.debouncedUpdate(data, widget.onUpdateGuideline);
    } else {
      _positionUpdater.debouncedUpdate(data, widget.onUpdateWidget);
    }
  }

  double _calculateContentHeight() {
    double maxWidgetHeight = _localWidgets.values.isNotEmpty
        ? _localWidgets.values.map((w) {
      final pos = w['position'] as Map<String, dynamic>;
      final yfactor = (pos['yfactor'] as double?) ?? 0.0;
      final style = w['style'] as Map<String, dynamic>;
      final heightFactor = (style['heightFactor'] as double?) ?? 0.0;
      return yfactor + heightFactor;
    }).reduce((a, b) => a > b ? a : b) * MediaQuery.of(context).size.height
        : 0.0;

    double maxGuidelineHeight = _localGuidelines.values.isNotEmpty
        ? _localGuidelines.values.map((g) {
      final pos = (g['position'] as double?) ?? 0.0;
      return pos;
    }).reduce((a, b) => a > b ? a : b) * MediaQuery.of(context).size.height
        : 0.0;

    final screenHeight = MediaQuery.of(context).size.height;
    return (maxWidgetHeight > maxGuidelineHeight ? maxWidgetHeight : maxGuidelineHeight) + screenHeight;
  }

  // 방 삭제 다이얼로그 표시
  void _showDeleteRoomDialog() {
    final TextEditingController uuidController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('방 삭제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('삭제하려면 방의 UUID를 입력하세요:'),
            const SizedBox(height: 10),
            TextField(
              controller: uuidController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'UUID 입력',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (uuidController.text == widget.roomKey) {
                _deleteRoom();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UUID가 일치하지 않습니다.')),
                );
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 방 삭제 및 메인 페이지로 이동
  void _deleteRoom() async {
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).delete();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/'); // 메인 페이지로 이동
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류 발생: $e')),
        );
      }
    }
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

            if (!_isDragging) {
              _lastRoomData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              _localWidgets = {
                for (var w in (_lastRoomData!['widgets'] as List<dynamic>? ?? []))
                  w['id']: Map<String, dynamic>.from(w)
                    ..update(
                      'position',
                          (pos) => {
                        'xfactor': (pos['xfactor'] ?? (pos['x'] ?? 0.0) / screenWidth).toDouble().clamp(0.0, 1.0),
                        'yfactor': (pos['yfactor'] ?? (pos['y'] ?? 0.0) / screenHeight).toDouble(),
                      },
                      ifAbsent: () => {'xfactor': 0.0, 'yfactor': 0.0},
                    )
              };
              _localGuidelines = {
                for (var g in (_lastRoomData!['guidelines'] as List<dynamic>? ?? []))
                  g['id']: Map<String, dynamic>.from(g)
                    ..update(
                      'position',
                          (pos) => (pos is double ? pos : 0.5).toDouble(),
                      ifAbsent: () => 0.5,
                    )
              };
            }

            final roomData = _isDragging && _lastRoomData != null ? _lastRoomData! : snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final backgroundColor = Color(int.parse((roomData['backgroundColor'] as String? ?? '#FFFFFF').replaceAll('#', '0xff')));

            return Container(
              color: backgroundColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  width: screenWidth,
                  height: _calculateContentHeight(),
                  child: Stack(
                    children: [
                      ..._localWidgets.values.map((widgetData) => buildWidget(
                        context,
                        widgetData,
                        screenWidth,
                        screenHeight,
                        widget.isEditMode,
                        _startDragging,
                            (details) => _positionUpdater.updatePosition(
                          widgetData,
                          details,
                          screenWidth,
                          screenHeight,
                          _localWidgets,
                              () => setState(() {}),
                        ),
                        _stopDragging,
                        showEditPanel,
                        widget.onUpdateWidget,
                        widget.onRemoveWidget,
                      )),
                      ..._localGuidelines.values.map((guidelineData) => buildGuideline(
                        context,
                        guidelineData,
                        screenWidth,
                        screenHeight,
                        widget.isEditMode,
                        _startDragging,
                            (details) => _positionUpdater.updateGuidelinePosition(
                          guidelineData,
                          details,
                          screenWidth,
                          screenHeight,
                          _localGuidelines,
                              () => setState(() {}),
                        ),
                        _stopDragging,
                        showGuidelineOptions,
                        widget.onUpdateGuideline,
                        widget.onRemoveGuideline,
                      )),
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
                            padding: const EdgeInsets.all(16.0),
                            child: IntrinsicWidth(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () => showTitleDialog(context, widget.onUpdateRoomTitle),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.lightGreen[300],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      child: const Text('방 제목', style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () => widget.onAddWidget({
                                            'id': Uuid().v4(),
                                            'type': 'text',
                                            'content': '새 텍스트',
                                            'position': {'xfactor': 0.1, 'yfactor': 0.1},
                                            'style': {
                                              'fontSizeFactor': 0.01,
                                              'color': '#000000',
                                              'alignment': 'center',
                                              'widthFactor': 0.3,
                                              'heightFactor': 0.15
                                            },
                                          }),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen[300],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('텍스트', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () => widget.onAddWidget({
                                            'id': Uuid().v4(),
                                            'type': 'image',
                                            'content': 'https://via.placeholder.com/150',
                                            'position': {'xfactor': 0.1, 'yfactor': 0.1},
                                            'style': {
                                              'fontSizeFactor': 0.01,
                                              'color': '#000000',
                                              'alignment': 'center',
                                              'widthFactor': 0.3,
                                              'heightFactor': 0.15
                                            },
                                          }),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen[300],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('이미지', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
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
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('가로선', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
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
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('세로선', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(

                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () => showColorPicker(context, (color) {
                                            FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).update({
                                              'backgroundColor': '#${color.value.toRadixString(16).substring(2)}',
                                            });
                                          }),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen[300],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('배경색', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () => showColorPicker(context, (color) {
                                            FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).update({
                                              'appBarColor': '#${color.value.toRadixString(16).substring(2)}',
                                            });
                                          }),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen[300],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('앱 바 색상', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: _showDeleteRoomDialog, // 삭제 다이얼로그 호출
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[300], // 삭제 버튼은 빨간색으로 구분
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('방 삭제', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () => widget.onAddWidget({
                                            'id': Uuid().v4(),
                                            'type': 'button',
                                            'content': '새 버튼',
                                            'position': {'xfactor': 0.1, 'yfactor': 0.1},
                                            'style': {
                                              'backgroundColor': '#42A5F5', // 기본 파란색
                                              'borderRadius': 0.2, // 약간 둥근 모서리
                                              'opacity': 0.8, // 완전 불투명
                                              'widthFactor': 0.3,
                                              'heightFactor': 0.1,
                                              'color': '#000000', // 흰색 텍스트
                                              'fontSizeFactor': 0.015,
                                            },
                                            'url': 'https://example.com', // 기본 URL
                                          }),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen[300],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const Text('하이퍼링크', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}