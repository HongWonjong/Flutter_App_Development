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
  int _currentPage = 1; // 현재 페이지 번호
  final int _itemsPerPage = 10; // 페이지당 항목 수

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
                    final totalItems = rooms.length;
                    final totalPages = (totalItems / _itemsPerPage).ceil();

                    // 현재 페이지에 표시할 데이터 슬라이싱
                    final startIndex = (_currentPage - 1) * _itemsPerPage;
                    final endIndex = startIndex + _itemsPerPage > totalItems
                        ? totalItems
                        : startIndex + _itemsPerPage;
                    final paginatedRooms = rooms.sublist(startIndex, endIndex);

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
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
                                  paginatedRooms.length,
                                      (index) {
                                    final room = paginatedRooms[index];
                                    final roomKey = room.id;
                                    final roomData = room.data() as Map<String, dynamic>;
                                    final title = roomData['title'] ?? '제목 없음';
                                    final createdAt = roomData['createdAt']?.toDate().toString() ?? '생성일 없음';
                                    return DataRow(
                                      cells: [
                                        DataCell(Text((startIndex + index + 1).toString())),
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
                          ),
                        ),
                        // 페이지네이션 UI
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // << (이전 페이지)
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                              ),
                              // 처음으로 버튼
                              if (_currentPage > 3)
                                TextButton(
                                  onPressed: () => setState(() => _currentPage = 1),
                                  child: const Text('처음으로'),
                                ),
                              // 페이지 번호들 (최대 5개 표시)
                              ...List.generate(
                                5,
                                    (index) {
                                  final pageNum = _currentPage - 2 + index;
                                  if (pageNum >= 1 && pageNum <= totalPages) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: TextButton(
                                        onPressed: () => setState(() => _currentPage = pageNum),
                                        style: TextButton.styleFrom(
                                          backgroundColor: _currentPage == pageNum
                                              ? Colors.blueAccent
                                              : null,
                                          foregroundColor: _currentPage == pageNum
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        child: Text('$pageNum'),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                              // 마지막 버튼
                              if (_currentPage < totalPages - 2)
                                TextButton(
                                  onPressed: () => setState(() => _currentPage = totalPages),
                                  child: const Text('마지막'),
                                ),
                              // >> (다음 페이지)
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
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