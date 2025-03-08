import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../providers/memo_provider.dart';
import '../providers/theme_provider.dart';
import '../models/memo_element.dart';
import '../utils/date_formatter.dart';
import 'memo_edit_page.dart';

// 메모 상세 화면
class MemoDetailPage extends ConsumerStatefulWidget {
  final String memoId;

  const MemoDetailPage({Key? key, required this.memoId}) : super(key: key);

  @override
  ConsumerState<MemoDetailPage> createState() => _MemoDetailPageState();
}

class _MemoDetailPageState extends ConsumerState<MemoDetailPage> {
  // 확대 중인 요소 ID
  String? _enlargedElementId;

  // 뷰포트 크기
  Size _viewportSize = Size.zero;

  // 요소 크기 정보 저장 맵
  Map<String, Size> _elementSizes = {};

  // 메모 삭제 처리 메서드
  void _deleteMemo(String memoId) async {
    try {
      // 대화상자 닫기
      Navigator.pop(context);

      // 메모를 즉시 삭제 (삭제 전에 상세 화면을 닫지 않음)
      await ref.read(memoProvider.notifier).deleteMemo(memoId);

      // 삭제 성공 후에 화면 닫기
      if (mounted) {
        Navigator.pop(context);

        // 성공 메시지 표시
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('메모가 삭제되었습니다')));
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('메모 삭제 중 오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewportSize = MediaQuery.of(context).size;
  }

  // 이미지 파일 저장 및 공유
  Future<void> _saveAndShareImage(ImageElement imageElement) async {
    try {
      final File imageFile = File(imageElement.path);
      if (await imageFile.exists()) {
        final result = await Share.shareXFiles([
          XFile(imageFile.path),
        ], text: '이미지 파일');

        if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('이미지가 공유되었습니다')));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미지 파일을 찾을 수 없습니다')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 공유 중 오류가 발생했습니다: $e')));
    }
  }

  // 코드 텍스트 파일로 저장 및 공유
  Future<void> _saveAndShareCode(CodeElement codeElement) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'code_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${tempDir.path}/$fileName');

      // 코드 내용과 언어 정보를 파일에 저장
      await file.writeAsString(
        '// Language: ${codeElement.language}\n\n${codeElement.code}',
      );

      final result = await Share.shareXFiles([
        XFile(file.path),
      ], text: '코드 파일 (${codeElement.language})');

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('코드가 공유되었습니다')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('코드 공유 중 오류가 발생했습니다: $e')));
    }
  }

  // 테이블 CSV 파일로 저장 및 공유
  Future<void> _saveAndShareTable(TableElement tableElement) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'table_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${tempDir.path}/$fileName');

      // CSV 형식으로 변환
      final csvData = const ListToCsvConverter().convert(tableElement.data);
      await file.writeAsString(csvData);

      final result = await Share.shareXFiles([
        XFile(file.path),
      ], text: 'CSV 테이블 파일');

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('테이블이 공유되었습니다')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('테이블 공유 중 오류가 발생했습니다: $e')));
    }
  }

  // 링크 공유
  Future<void> _shareLink(LinkElement linkElement) async {
    try {
      // result를 사용하지 않도록 수정
      await Share.share(
        '${linkElement.title}: ${linkElement.url}',
        subject: linkElement.title,
      );

      // 성공 여부와 상관없이 공유 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('링크가 공유되었습니다')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('링크 공유 중 오류가 발생했습니다: $e')));
    }
  }

  // 요소 절대 위치 계산 (편집 모드와 동일하게 수정)
  Offset _getElementPosition(MemoElement element) {
    return Offset(
      element.xFactor * _viewportSize.width,
      element.yFactor * _viewportSize.height,
    );
  }

  // 새로운 메서드: 메모와 요소들을 함께 배치한 통합 레이아웃 생성
  Widget _buildIntegratedLayout(
    BuildContext context,
    String content,
    List<MemoElement> elements,
  ) {
    // 테마 가져오기
    final theme = ref.watch(themeProvider);
    final textColor = theme.textColor;
    final backgroundColor = theme.backgroundColor;

    // 요소들의 y좌표를 기준으로 정렬
    final sortedElements = List<MemoElement>.from(elements)
      ..sort((a, b) => (a.yFactor).compareTo(b.yFactor));

    // 텍스트 스타일 정의 - 테마 색상 적용
    final textStyle = TextStyle(fontSize: 16, color: textColor);

    // 콘텐츠 패딩 고려
    const double contentPadding = 32.0; // 상하좌우 패딩 합계

    // 텍스트 영역 높이 계산 (더 정확하게)
    final contentLines = content.split('\n').length;
    final estimatedTextHeight = max(
      150.0, // 최소 높이
      contentLines * 22.0 + contentPadding, // 줄당 약 22픽셀 + 패딩
    );

    // 텍스트 하단 위치 (요소들의 시작점)
    final textBottomOffset = estimatedTextHeight;

    // 가장 아래에 위치한 요소의 위치 계산
    double maxElementBottom = textBottomOffset;

    // 편집 모드와 유사한 위치 계산
    if (sortedElements.isNotEmpty) {
      for (var element in sortedElements) {
        // 요소 위치 계산
        final elementPos = _getElementPosition(element);
        final elementHeight = element.height > 0 ? element.height : 150.0;
        final elementBottom = elementPos.dy + elementHeight + 50.0; // 요소 간 여백
        maxElementBottom = max(maxElementBottom, elementBottom);
      }
    }

    // 전체 콘텐츠 높이 계산 - 정확하게 콘텐츠에 맞추기
    final totalHeight = maxElementBottom + 80.0; // 최소한의 여백만 추가 (편집 모드와 유사하게)

    return Container(
      width: _viewportSize.width,
      height: totalHeight,
      child: Stack(
        fit: StackFit.loose,
        clipBehavior: Clip.none,
        children: [
          // 1. 텍스트 콘텐츠
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(content, style: textStyle),
            ),
          ),

          // 2. 요소들 배치 (절대 위치 사용)
          for (var element in sortedElements) ...[
            Positioned(
              left: element.xFactor * _viewportSize.width,
              top: element.yFactor * _viewportSize.height,
              width: element.width > 0 ? element.width : 200.0,
              height: element.height > 0 ? element.height : 150.0,
              child: element.type == MemoElementType.divider
                  ? _buildElementContent(element) // 구분선은 직접 표시
                  : Container(
                      decoration: BoxDecoration(
                        color: backgroundColor, // 배경색 테마에 맞게 변경
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color:
                                textColor.withOpacity(0.1), // 그림자 색상도 테마에 맞게 변경
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildElementContent(element),
                    ),
            ),
          ],

          // 3. 하단에 최소한의 여백 확보
          Positioned(
            left: 0,
            top: totalHeight - 50,
            width: _viewportSize.width,
            height: 50,
            child: const SizedBox(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memos = ref.watch(memoProvider);
    final theme = ref.watch(themeProvider);

    // 메모 찾기 전 로딩 UI 표시
    if (memos.isEmpty) {
      return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarColor,
          elevation: 0,
          title: Text(
            '메모 상세',
            style: TextStyle(color: theme.textColor),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 메모 찾기 시 예외 처리 추가
    final memoIndex = memos.indexWhere((memo) => memo.id == widget.memoId);
    if (memoIndex == -1) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('메모 상세'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('메모를 찾을 수 없습니다.', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    final memo = memos[memoIndex];

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarColor,
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: true,
        title: Text(
          '메모 상세',
          style: TextStyle(
            color: theme.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textColor, size: 24),
          padding: const EdgeInsets.all(12),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              memo.isFavorite ? Icons.star : Icons.star_border,
              color: memo.isFavorite ? Colors.amber : theme.textColor,
              size: 24,
            ),
            padding: const EdgeInsets.all(12),
            onPressed: () {
              ref.read(memoProvider.notifier).toggleFavorite(memo.id);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit, color: theme.textColor, size: 24),
            padding: const EdgeInsets.all(12),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoEditPage(memoId: widget.memoId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: theme.textColor, size: 24),
            padding: const EdgeInsets.all(12),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: theme.backgroundColor,
                  title: Text(
                    '메모 삭제',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    '이 메모를 삭제하시겠습니까?',
                    style: TextStyle(color: theme.textColor),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        '취소',
                        style: TextStyle(color: theme.textColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _deleteMemo(widget.memoId),
                      child: const Text(
                        '삭제',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 스크롤 가능한 콘텐츠 영역 - 편집 모드와 유사한 스크롤 물리 사용
            SingleChildScrollView(
              // 콘텐츠 영역 내로 스크롤 제한 (Android 스타일)
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: _buildIntegratedLayout(
                context,
                memo.content,
                memo.elements,
              ),
            ),

            // 확대된 요소는 별도의 오버레이로 표시
            if (_enlargedElementId != null)
              Positioned.fill(
                child: _buildEnlargedElementOverlay(
                  memo.elements.firstWhere((e) => e.id == _enlargedElementId),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: memo.elements.isNotEmpty
          ? FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              tooltip: '첨부 요소 보기',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '첨부된 요소',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Divider(),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: memo.elements
                                .map(
                                  (element) => ListTile(
                                    leading: _getElementIcon(element),
                                    title: Text(
                                      _getElementTitle(element),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _shareElement(element);
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(
                                        () => _enlargedElementId = element.id,
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Icon(Icons.attachment, color: Colors.blueGrey),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // 확대된 요소 오버레이
  Widget _buildEnlargedElementOverlay(MemoElement element) {
    // 테마 가져오기
    final theme = ref.watch(themeProvider);
    final textColor = theme.textColor;
    final backgroundColor = theme.backgroundColor;

    // 확대 모드에서의 기본 크기 (화면 비율 기준)
    final enlargedWidth = _viewportSize.width * 0.9;
    final enlargedHeight = _viewportSize.height * 0.7;

    // 요소의 원래 비율 계산 (요소 크기가 0이 아닌 경우만)
    double aspectRatio = 1.0;
    if (element.width > 0 && element.height > 0) {
      aspectRatio = element.width / element.height;
    }

    // 비율 유지하면서 확대 크기 계산
    final double finalWidth, finalHeight;
    if (enlargedWidth / aspectRatio <= enlargedHeight) {
      finalWidth = enlargedWidth;
      finalHeight = enlargedWidth / aspectRatio;
    } else {
      finalHeight = enlargedHeight;
      finalWidth = enlargedHeight * aspectRatio;
    }

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => setState(() => _enlargedElementId = null),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              width: finalWidth,
              height: finalHeight,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getElementTitle(element),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () =>
                            setState(() => _enlargedElementId = null),
                      ),
                    ],
                  ),
                  Divider(color: textColor.withOpacity(0.2)),
                  Expanded(
                    child: _buildElementContent(element, enlarged: true),
                  ),
                  const Divider(),
                  ElevatedButton.icon(
                    onPressed: () => _shareElement(element),
                    icon: const Icon(Icons.share),
                    label: const Text('공유하기'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 요소별 공유 기능 실행
  void _shareElement(MemoElement element) {
    switch (element.type) {
      case MemoElementType.image:
        _saveAndShareImage(element as ImageElement);
        break;
      case MemoElementType.code:
        _saveAndShareCode(element as CodeElement);
        break;
      case MemoElementType.link:
        _shareLink(element as LinkElement);
        break;
      case MemoElementType.table:
        _saveAndShareTable(element as TableElement);
        break;
      case MemoElementType.checklist:
        _shareChecklist(element as ChecklistElement);
        break;
      case MemoElementType.quote:
        _shareQuote(element as QuoteElement);
        break;
      case MemoElementType.divider:
        _shareDivider(element as DividerElement);
        break;
      case MemoElementType.list:
        _shareList(element as ListElement);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('지원되지 않는 요소 타입입니다')),
        );
        break;
    }
  }

  // 체크리스트 공유
  Future<void> _shareChecklist(ChecklistElement checklistElement) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'checklist_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${tempDir.path}/$fileName');

      // 체크리스트 내용을 텍스트 형식으로 변환
      final buffer = StringBuffer('체크리스트:\n');
      for (var item in checklistElement.items) {
        buffer.write('${item['checked'] ? '[✓]' : '[ ]'} ${item['text']}\n');
      }

      await file.writeAsString(buffer.toString());

      final result = await Share.shareXFiles([
        XFile(file.path),
      ], text: '체크리스트');

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('체크리스트가 공유되었습니다')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('체크리스트 공유 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 인용구 공유
  Future<void> _shareQuote(QuoteElement quoteElement) async {
    try {
      final quoteText =
          quoteElement.source != null && quoteElement.source!.isNotEmpty
              ? '"${quoteElement.text}" - ${quoteElement.source}'
              : '"${quoteElement.text}"';

      await Share.share(quoteText, subject: '인용구');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인용구가 공유되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인용구 공유 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 목록 공유
  Future<void> _shareList(ListElement listElement) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'list_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${tempDir.path}/$fileName');

      // 목록 내용을 텍스트 형식으로 변환
      final buffer =
          StringBuffer('${listElement.isOrdered ? '순서 있는 목록' : '목록'}:\n');
      for (var i = 0; i < listElement.items.length; i++) {
        buffer.write(
            '${listElement.isOrdered ? '${i + 1}.' : '•'} ${listElement.items[i]}\n');
      }

      await file.writeAsString(buffer.toString());

      final result = await Share.shareXFiles([
        XFile(file.path),
      ], text: listElement.isOrdered ? '순서 있는 목록' : '목록');

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('목록이 공유되었습니다')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('목록 공유 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 구분선 공유
  Future<void> _shareDivider(DividerElement dividerElement) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('구분선은 공유할 내용이 없습니다')),
    );
  }

  // 요소 타입별 제목 생성
  String _getElementTitle(MemoElement element) {
    switch (element.type) {
      case MemoElementType.image:
        return '이미지';
      case MemoElementType.code:
        final codeElement = element as CodeElement;
        return codeElement.language.isNotEmpty &&
                codeElement.language != 'plain'
            ? '코드 (${codeElement.language})'
            : '코드';
      case MemoElementType.link:
        final linkElement = element as LinkElement;
        return linkElement.title;
      case MemoElementType.table:
        return '표';
      case MemoElementType.checklist:
        return '체크리스트';
      case MemoElementType.quote:
        return '인용구';
      case MemoElementType.divider:
        return '구분선';
      case MemoElementType.list:
        return '목록';
      default:
        return element.type.toString().split('.').last;
    }
  }

  // 요소 내용 위젯 빌드
  Widget _buildElementContent(MemoElement element, {bool enlarged = false}) {
    // 확대 모드일 경우 더 큰 크기 사용, 아니면 요소의 실제 크기 사용
    final size = enlarged
        ? Size(_viewportSize.width * 0.85, _viewportSize.height * 0.6)
        : Size(element.width, element.height);

    // 테마 가져오기
    final theme = ref.watch(themeProvider);
    final textColor = theme.textColor;
    final backgroundColor = theme.backgroundColor;

    switch (element.type) {
      case MemoElementType.image:
        final imageElement = element as ImageElement;
        return FutureBuilder<bool>(
          future: File(imageElement.path).exists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data == true) {
              return Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  border: Border.all(color: textColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imageElement.path),
                    fit: BoxFit.cover,
                    width: size.width,
                    height: size.height,
                    errorBuilder: (context, error, stackTrace) {
                      print('이미지 로드 오류: $error');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '이미지를 로드할 수 없습니다: $error',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image,
                        color: textColor.withOpacity(0.5), size: 40),
                    const SizedBox(height: 8),
                    Text('이미지를 찾을 수 없습니다', style: TextStyle(color: textColor)),
                  ],
                ),
              );
            }
          },
        );

      case MemoElementType.code:
        final codeElement = element as CodeElement;
        // 코드 블록은 약간 어두운 배경
        final codeBackground =
            ThemeData.estimateBrightnessForColor(backgroundColor) ==
                    Brightness.dark
                ? Colors.grey[800] // 다크 모드면 약간 밝은 회색
                : Colors.grey[200]; // 라이트 모드면 약간 어두운 회색

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: codeBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                codeElement.language.isNotEmpty &&
                        codeElement.language != 'plain'
                    ? '${codeElement.language}'
                    : '',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    codeElement.code,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case MemoElementType.link:
        final linkElement = element as LinkElement;
        final linkColor = Colors.blue.shade700; // 링크는 파란색 유지
        final linkBackground =
            ThemeData.estimateBrightnessForColor(backgroundColor) ==
                    Brightness.dark
                ? Colors.blue.shade900.withOpacity(0.2) // 다크 모드
                : Colors.blue.shade50; // 라이트 모드

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: linkBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('링크:',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 4),
              Text(
                linkElement.title,
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                linkElement.url,
                style: TextStyle(color: linkColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.open_in_new, size: 16, color: linkColor),
                  label: Text('열기', style: TextStyle(color: linkColor)),
                  onPressed: () {
                    launchUrl(Uri.parse(linkElement.url));
                  },
                ),
              ),
            ],
          ),
        );

      case MemoElementType.table:
        final tableElement = element as TableElement;
        // 표 배경색
        final tableBackground =
            ThemeData.estimateBrightnessForColor(backgroundColor) ==
                    Brightness.dark
                ? Colors.grey[800] // 다크 모드면 약간 밝은 회색
                : Colors.white; // 라이트 모드면 흰색

        final borderColor =
            ThemeData.estimateBrightnessForColor(backgroundColor) ==
                    Brightness.dark
                ? Colors.grey[600] // 다크 모드면 약간 밝은 회색
                : Colors.grey[400]; // 라이트 모드면 어두운 회색

        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: tableBackground,
            border: Border.all(color: borderColor ?? Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    border: TableBorder.all(color: borderColor ?? Colors.grey),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: tableElement.data.map((row) {
                      return TableRow(
                        children: row.map((cell) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              cell,
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );

      case MemoElementType.checklist:
        final checklistElement = element as ChecklistElement;
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checklist,
                    color: textColor.withOpacity(0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '체크리스트',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: checklistElement.items.length,
                  itemBuilder: (context, index) {
                    final item = checklistElement.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            item['checked']
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: item['checked']
                                ? Colors.green
                                : textColor.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['text'],
                              style: TextStyle(
                                color: textColor,
                                decoration: item['checked']
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );

      case MemoElementType.quote:
        final quoteElement = element as QuoteElement;
        return Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: textColor.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: textColor.withOpacity(0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '인용구',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.blue.withOpacity(0.7),
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            quoteElement.text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      if (quoteElement.source != null &&
                          quoteElement.source!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                          child: Text(
                            '- ${quoteElement.source}',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      case MemoElementType.divider:
        final dividerElement = element as DividerElement;
        // 순수한 검은색 직선으로 구현
        final dividerColor =
            dividerElement.color ?? Colors.black.withOpacity(0.7);

        return Container(
          width: size.width,
          height: size.height,
          color: Colors.transparent, // 완전 투명 배경
          child: Center(
            child: dividerElement.isVertical
                ? Container(
                    width: dividerElement.thickness,
                    height: size.height, // 전체 높이 사용
                    color: dividerColor, // 순수한 선 색상
                  )
                : Container(
                    width: size.width, // 전체 너비 사용
                    height: dividerElement.thickness,
                    color: dividerColor, // 순수한 선 색상
                  ),
          ),
        );

      case MemoElementType.list:
        final listElement = element as ListElement;
        return Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    listElement.isOrdered
                        ? Icons.format_list_numbered
                        : Icons.format_list_bulleted,
                    color: textColor.withOpacity(0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    listElement.isOrdered ? '순서 있는 목록' : '기본 목록',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: listElement.items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              listElement.isOrdered ? '${index + 1}.' : '•',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              listElement.items[index],
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );

      default:
        // 지원되지 않는 요소 타입에 대한 기본 UI
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              '지원되지 않는 요소 타입: ${element.type}',
              style: TextStyle(color: textColor),
            ),
          ),
        );
    }
  }

  // 요소 아이콘 생성
  Widget _getElementIcon(MemoElement element) {
    IconData icon;
    Color color;

    switch (element.type) {
      case MemoElementType.image:
        icon = Icons.image;
        color = Colors.blue;
        break;
      case MemoElementType.code:
        icon = Icons.code;
        color = Colors.orange;
        break;
      case MemoElementType.link:
        icon = Icons.link;
        color = Colors.green;
        break;
      case MemoElementType.table:
        icon = Icons.grid_on;
        color = Colors.purple;
        break;
      case MemoElementType.checklist:
        icon = Icons.checklist;
        color = Colors.green;
        break;
      case MemoElementType.quote:
        icon = Icons.format_quote;
        color = Colors.orange;
        break;
      case MemoElementType.divider:
        icon = Icons.more_horiz;
        color = Colors.grey;
        break;
      case MemoElementType.list:
        icon = Icons.format_list_bulleted;
        color = Colors.blue;
        break;
      default:
        icon = Icons.extension;
        color = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
