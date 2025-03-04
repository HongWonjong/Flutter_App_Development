import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../components/room/floating_widget_list.dart';
import '../logics/room_logic.dart';

// 디바운스 함수 정의
void Function() debounce(void Function() func, Duration duration) {
  Timer? timer;
  return () {
    if (timer?.isActive ?? false) timer!.cancel();
    timer = Timer(duration, func);
  };
}

class RoomPage extends StatefulWidget {
  final String roomKey;

  const RoomPage({super.key, required this.roomKey});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final RoomLogic _roomLogic = RoomLogic();
  String _mode = 'edit';
  late void Function() _debouncedUpdateRoomTitle;
  String? _pendingRoomTitle;

  @override
  void initState() {
    super.initState();
    _roomLogic.getRoomStream(widget.roomKey).first.then((snapshot) {
      if (!snapshot.exists) {
        _roomLogic.createRoom(widget.roomKey);
      }
    });
    _debouncedUpdateRoomTitle = debounce(() {
      if (_pendingRoomTitle != null) _updateRoomTitle(_pendingRoomTitle!);
    }, const Duration(milliseconds: 300));
  }

  Future<void> _updateRoomTitle(String title) async {
    await FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).update({'title': title});
  }

  void _copyRoomKey() {
    Clipboard.setData(ClipboardData(text: widget.roomKey));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('방 키가 클립보드에 복사되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = GoRouterState.of(context).uri.queryParameters;
    _mode = queryParams['mode'] ?? 'edit';
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<DocumentSnapshot>(
      stream: _roomLogic.getRoomStream(widget.roomKey),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final roomData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final bgColor = roomData['backgroundColor'] as String? ?? '#ffffff';
        final appBarColorStr = roomData['appBarColor'] as String? ?? '#42A5F5';
        final title = roomData['title'] as String? ?? '';
        final backgroundColor = Color(int.parse(bgColor.replaceAll('#', '0xff')));
        final appBarColor = Color(int.parse(appBarColorStr.replaceAll('#', '0xff')));

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
              tooltip: '돌아가기',
            ),
            backgroundColor: appBarColor,
            title: _mode == 'edit'
                ? Row(
              children: [
                const Text('방: '),
                Expanded(child: Text(widget.roomKey, overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyRoomKey,
                  tooltip: '방 키 복사',
                ),
              ],
            )
                : Text(title.isEmpty ? '방 보기' : title),
          ),
          body: FloatingWidgetList(
            roomKey: widget.roomKey,
            isEditMode: _mode == 'edit',
            onAddWidget: (widgetData) => _roomLogic.addWidget(widget.roomKey, widgetData),
            onRemoveWidget: (widgetData) => _roomLogic.removeWidget(widget.roomKey, widgetData),
            onUpdateWidget: (widgetData) => _roomLogic.updateWidget(widget.roomKey, widgetData),
            onAddGuideline: (guidelineData) => _roomLogic.addGuideline(widget.roomKey, guidelineData),
            onRemoveGuideline: (guidelineData) => _roomLogic.removeGuideline(widget.roomKey, guidelineData),
            backgroundColor: backgroundColor,
            onBackgroundColorChanged: (color) =>
                _roomLogic.updateBackgroundColor(widget.roomKey, '#${color.value.toRadixString(16).substring(2)}'),
            appBarColor: appBarColor,
            onAppBarColorChanged: (color) =>
                _roomLogic.updateAppBarColor(widget.roomKey, '#${color.value.toRadixString(16).substring(2)}'),
            roomTitle: title,
            onUpdateRoomTitle: (title) {
              _pendingRoomTitle = title;
              _debouncedUpdateRoomTitle();
            },
          ),
        );
      },
    );
  }
}