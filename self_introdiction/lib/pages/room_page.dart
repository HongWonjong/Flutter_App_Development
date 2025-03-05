import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../components/room/floating_widget_list.dart';
import '../logics/room_logic.dart';

class RoomPage extends StatefulWidget {
  final String roomKey;

  const RoomPage({super.key, required this.roomKey});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final RoomLogic _roomLogic = RoomLogic();
  String _mode = 'edit';
  String _roomTitle = '';

  @override
  void initState() {
    super.initState();
    _roomLogic.getRoomStream(widget.roomKey).first.then((snapshot) {
      if (!snapshot.exists) {
        _roomLogic.createRoom(widget.roomKey);
      } else {
        final roomData = snapshot.data() as Map<String, dynamic>?;
        final title = roomData?['title'] as String? ?? '';
        setState(() => _roomTitle = title);
      }
    });
  }

  Future<void> _updateRoomTitle(String title) async {
    await FirebaseFirestore.instance.collection('rooms').doc(widget.roomKey).update({'title': title});
    setState(() => _roomTitle = title);
  }

  void _copyRoomKey() {
    Clipboard.setData(ClipboardData(text: widget.roomKey));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('방 키가 클립보드에 복사되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = GoRouterState.of(context).uri.queryParameters;
    _mode = queryParams['mode'] ?? 'edit';

    return StreamBuilder<DocumentSnapshot>(
      stream: _roomLogic.getRoomStream(widget.roomKey),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final roomData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final appBarColor = Color(int.parse((roomData['appBarColor'] as String? ?? '#42A5F5').replaceAll('#', '0xff')));

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
              tooltip: '돌아가기',
            ),
            backgroundColor: appBarColor,
            title: Center(
              child: Text(
                _mode == 'edit'
                    ? (_roomTitle.isEmpty ? '제목 없음' : _roomTitle)
                    : (_roomTitle.isEmpty ? '방 보기' : _roomTitle),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            actions: _mode == 'edit'
                ? [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('방: '),
                  Text(
                    widget.roomKey,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyRoomKey,
                    tooltip: '방 키 복사',
                  ),
                ],
              ),
            ]
                : null,
          ),
          body: FloatingWidgetList(
            roomKey: widget.roomKey,
            isEditMode: _mode == 'edit',
            onAddWidget: (widgetData) => _roomLogic.addWidget(widget.roomKey, widgetData),
            onRemoveWidget: (widgetData) => _roomLogic.removeWidget(widget.roomKey, widgetData),
            onUpdateWidget: (widgetData) => _roomLogic.updateWidget(widget.roomKey, widgetData),
            onAddGuideline: (guidelineData) => _roomLogic.addGuideline(widget.roomKey, guidelineData),
            onRemoveGuideline: (guidelineData) => _roomLogic.removeGuideline(widget.roomKey, guidelineData),
            onUpdateGuideline: (guidelineData) => _roomLogic.updateGuideline(widget.roomKey, guidelineData),
            onUpdateRoomTitle: _updateRoomTitle,
          ),
        );
      },
    );
  }
}