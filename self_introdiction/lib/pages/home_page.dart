import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _keyController = TextEditingController();

  void _createNewRoom() {
    final String newKey = Uuid().v4();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새로운 방 생성'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('발급된 UUID로 추후에도 편집모드로 들어갈 수 있습니다 :)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SelectableText(newKey), // UUID 표시
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: newKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('복사 성공!')),
                    );
                  },
                  tooltip: '키 복사',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              context.go('/room/$newKey'); // 방으로 이동
            },
            child: const Text('편집 모드로'),
          ),
        ],
      ),
    );
  }

  void _goToExistingRoom() {
    final String key = _keyController.text.trim();
    if (key.isNotEmpty) {
      context.go('/room/$key');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '방 만들기 / 이동',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _keyController,
                          decoration: InputDecoration(
                            labelText: '방 키 입력',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _goToExistingRoom,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ),
                        child: const Text('이동'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _createNewRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                    ),
                    child: const Text('새 방 생성'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final rooms = snapshot.data!.docs;
                    return SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('번호', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('제목', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('생성일', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: List<DataRow>.generate(
                            rooms.length,
                                (index) {
                              final room = rooms[index];
                              final roomKey = room.id;
                              final roomData = room.data() as Map<String, dynamic>;
                              final title = roomData['title'] ?? '제목 없음';
                              final createdAt = roomData['createdAt']?.toDate().toString() ?? '생성일 없음';
                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(title)),
                                  DataCell(Text(createdAt)),
                                ],
                                onSelectChanged: (selected) {
                                  if (selected ?? false) {
                                    context.go('/room/$roomKey?mode=read');
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}