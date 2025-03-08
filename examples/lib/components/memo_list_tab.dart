import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/memo_provider.dart';
import '../pages/memo_detail_page.dart';
import '../utils/date_formatter.dart';

// 메모 목록 탭
class MemoListTab extends ConsumerWidget {
  final bool isFavoriteOnly;

  const MemoListTab({Key? key, required this.isFavoriteOnly}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMemos = ref.watch(memoProvider);
    final memos =
        isFavoriteOnly
            ? allMemos.where((memo) => memo.isFavorite).toList()
            : allMemos;

    if (memos.isEmpty) {
      return Center(
        child: Text(
          isFavoriteOnly
              ? '즐겨찾기한 메모가 없습니다.'
              : '메모가 없습니다.\n오른쪽 하단 버튼을 눌러 새 메모를 추가하세요.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final memo = memos[index];
        return Dismissible(
          key: Key(memo.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('메모 삭제'),
                    content: const Text('이 메모를 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (_) {
            ref.read(memoProvider.notifier).deleteMemo(memo.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('메모가 삭제되었습니다')));
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                memo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                memo.content.replaceFirst(memo.title, '').trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormatter.formatRelativeDate(memo.updatedAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  IconButton(
                    icon: Icon(
                      memo.isFavorite ? Icons.star : Icons.star_border,
                      color: memo.isFavorite ? Colors.amber : null,
                    ),
                    onPressed: () {
                      ref.read(memoProvider.notifier).toggleFavorite(memo.id);
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoDetailPage(memoId: memo.id),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
