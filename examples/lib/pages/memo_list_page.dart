import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/memo_provider.dart';
import '../providers/theme_provider.dart';
import '../models/memo.dart';
import '../models/app_theme.dart';
import '../components/memo_list_tab.dart';
import 'memo_edit_page.dart';
import 'settings_page.dart';
import 'memo_detail_page.dart';
import '../utils/date_formatter.dart';

// 메모 정렬 방식
enum MemoSort {
  createdDesc,
  createdAsc,
  updatedDesc,
  updatedAsc,
}

// 메모 목록 화면
class MemoListPage extends ConsumerStatefulWidget {
  const MemoListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MemoListPage> createState() => _MemoListPageState();
}

class _MemoListPageState extends ConsumerState<MemoListPage> {
  String _searchQuery = '';
  MemoSort _currentSort = MemoSort.updatedDesc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Memo> _sortMemos(List<Memo> memos) {
    switch (_currentSort) {
      case MemoSort.createdDesc:
        return memos..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case MemoSort.createdAsc:
        return memos..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case MemoSort.updatedDesc:
        return memos..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case MemoSort.updatedAsc:
        return memos..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    }
  }

  List<Memo> _filterMemos(List<Memo> memos) {
    if (_searchQuery.isEmpty) return memos;
    return memos
        .where((memo) =>
            memo.content.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final memos = ref.watch(memoProvider);
    final tabIndex = ref.watch(tabIndexProvider);
    final theme = ref.watch(themeProvider);

    // 메모 필터링 및 정렬
    var filteredMemos = _filterMemos(memos);
    var sortedMemos = _sortMemos(filteredMemos);

    // 즐겨찾기 메모와 일반 메모 분리 (즐겨찾기 탭용)
    final favoriteMemos = sortedMemos.where((memo) => memo.isFavorite).toList();

    return DefaultTabController(
      initialIndex: tabIndex,
      length: 2,
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarColor,
          elevation: 0,
          toolbarHeight: 56,
          centerTitle: true,
          title: Text(
            '메모',
            style: TextStyle(
              color: theme.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // 정렬 버튼
            IconButton(
              icon: Icon(Icons.sort, color: theme.textColor, size: 24),
              padding: const EdgeInsets.all(12),
              onPressed: () => _showSortDialog(context, theme),
            ),
            // 검색 버튼
            IconButton(
              icon: Icon(Icons.search, color: theme.textColor, size: 24),
              padding: const EdgeInsets.all(12),
              onPressed: () => _showSearchDialog(context, theme),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: theme.textColor, size: 24),
              padding: const EdgeInsets.all(12),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
          bottom: TabBar(
            onTap: (index) => ref.read(tabIndexProvider.notifier).state = index,
            labelColor: theme.textColor,
            unselectedLabelColor: theme.textColor.withOpacity(0.5),
            indicatorColor: theme.textColor,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(text: '전체'),
              Tab(text: '즐겨찾기'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildMemoList(context, ref, sortedMemos, theme),
            _buildMemoList(context, ref, favoriteMemos, theme),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: theme.appBarColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, color: theme.textColor, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MemoEditPage()),
            );
          },
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context, AppTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        title: Text('정렬', style: TextStyle(color: theme.textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption(context, '최근 생성순', MemoSort.createdDesc, theme),
            _buildSortOption(context, '오래된 생성순', MemoSort.createdAsc, theme),
            _buildSortOption(context, '최근 수정순', MemoSort.updatedDesc, theme),
            _buildSortOption(context, '오래된 수정순', MemoSort.updatedAsc, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context, String title, MemoSort sort, AppTheme theme) {
    return ListTile(
      title: Text(title, style: TextStyle(color: theme.textColor)),
      trailing: _currentSort == sort
          ? Icon(Icons.check, color: theme.textColor)
          : null,
      onTap: () {
        setState(() => _currentSort = sort);
        Navigator.pop(context);
      },
    );
  }

  void _showSearchDialog(BuildContext context, AppTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        title: Text('검색', style: TextStyle(color: theme.textColor)),
        content: TextField(
          controller: _searchController,
          style: TextStyle(color: theme.textColor),
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
            hintStyle: TextStyle(color: theme.textColor.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.textColor.withOpacity(0.3)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.textColor),
            ),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: Text('취소', style: TextStyle(color: theme.textColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인', style: TextStyle(color: theme.textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoList(
      BuildContext context, WidgetRef ref, List<Memo> memos, AppTheme theme) {
    return memos.isEmpty
        ? Center(
            child: Text(_searchQuery.isEmpty ? '메모가 없습니다' : '검색 결과가 없습니다',
                style: TextStyle(color: theme.textColor)))
        : ListView.builder(
            itemCount: memos.length,
            itemBuilder: (context, index) {
              final memo = memos[index];
              return Card(
                color: theme.backgroundColor.withOpacity(0.7),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 1,
                shadowColor: theme.textColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.textColor.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    memo.content,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormatter.format(memo.createdAt),
                      style: TextStyle(
                        color: theme.textColor.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      memo.isFavorite ? Icons.star : Icons.star_border,
                      color: memo.isFavorite ? Colors.amber : theme.textColor,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(8),
                    onPressed: () {
                      ref.read(memoProvider.notifier).toggleFavorite(memo.id);
                    },
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
              );
            },
          );
  }
}
