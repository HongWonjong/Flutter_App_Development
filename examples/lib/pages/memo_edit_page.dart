import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:async';
import 'dart:math';

import '../models/memo.dart';
import '../models/memo_element.dart';
import '../models/app_theme.dart';
import '../providers/memo_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_strings.dart';
import '../utils/clipboard_helper.dart';
import '../utils/color_utils.dart';

// 컴포넌트 임포트
import '../components/editor/index.dart';
import '../components/memo_elements/index.dart';

// 앱 수명 주기 관찰자
class _MemoEditLifecycleObserver extends WidgetsBindingObserver {
  final Function onAppPaused;

  _MemoEditLifecycleObserver({required this.onAppPaused});

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused) {
      onAppPaused();
    }
  }
}

// 메모 편집 화면
class MemoEditPage extends ConsumerStatefulWidget {
  final String? memoId;

  const MemoEditPage({Key? key, this.memoId}) : super(key: key);

  @override
  ConsumerState<MemoEditPage> createState() => _MemoEditPageState();
}

class _MemoEditPageState extends ConsumerState<MemoEditPage> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isEditing = false;
  String? _currentMemoId;

  // 메모 요소 및 크기 관리
  List<MemoElement> _elements = [];
  Map<String, Size> _elementSizes = {};

  // 드래그 및 크기 조절 상태
  String? _dragElementId;
  Offset? _dragOffset;

  // 저장 상태
  bool _isDirty = false;
  bool _isSaving = false;
  Timer? _saveTimer;

  // 컨트롤러 및 변수들
  late _MemoEditLifecycleObserver _lifecycleObserver;
  bool _memoNotFound = false;

  @override
  void initState() {
    super.initState();

    // 수명 주기 관찰자 설정
    _lifecycleObserver = _MemoEditLifecycleObserver(
      onAppPaused: () => _saveChanges(immediate: true),
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    // 기존 메모 로드
    if (widget.memoId != null) {
      _isEditing = true;
      _currentMemoId = widget.memoId;
      _loadMemoContent();
    }

    // 변경 감지를 위한 리스너
    _contentController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChange);
  }

  // 메모 콘텐츠 로드
  void _loadMemoContent() {
    try {
      final memos = ref.read(memoProvider);
      final memo = memos.firstWhere((m) => m.id == widget.memoId);

      _contentController.text = memo.content;
      setState(() {
        _elements = List.from(memo.elements);

        // 요소 크기 초기화
        _elementSizes.clear();
        for (var element in memo.elements) {
          _initElementSize(element);
        }
      });
    } catch (e) {
      print('메모 로드 오류: $e');
      _memoNotFound = true;
    }
  }

  // 요소 크기 초기화
  void _initElementSize(MemoElement element) {
    if (element.width > 0 && element.height > 0) {
      _elementSizes[element.id] = Size(element.width, element.height);
      return;
    }

    // 기본 크기 설정
    double width = 200.0;
    double height = 150.0;

    switch (element.type) {
      case MemoElementType.image:
        width = 200.0;
        height = 150.0;
        break;
      case MemoElementType.code:
        width = 300.0;
        height = 200.0;
        break;
      case MemoElementType.link:
        width = 300.0;
        height = 120.0;
        break;
      case MemoElementType.table:
        final tableElement = element as TableElement;
        width = tableElement.columns * 80.0;
        height = tableElement.rows * 40.0 + 20.0;
        break;
      default:
        width = 300.0;
        height = 150.0;
        break;
    }

    _elementSizes[element.id] = Size(width, height);
  }

  // 텍스트 변경 감지
  void _onTextChanged() {
    _markDirty();
  }

  // 포커스 변경 감지
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      RawKeyboard.instance.addListener(_handleKeyEvent);
    } else {
      RawKeyboard.instance.removeListener(_handleKeyEvent);
    }
  }

  // 키 이벤트 처리
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if ((event.isMetaPressed || event.isControlPressed) &&
          event.logicalKey == LogicalKeyboardKey.keyV) {
        _handlePaste();
      }
    }
  }

  // 붙여넣기 처리
  Future<void> _handlePaste() async {
    try {
      final imageFile = await ClipboardHelper.getImageFromClipboard(context);
      if (imageFile != null) {
        _addImageFromFile(imageFile);
      }
    } catch (e) {
      print('붙여넣기 오류: $e');
    }
  }

  // 변경 표시
  void _markDirty() {
    if (!_isDirty && !_isSaving) {
      setState(() {
        _isDirty = true;
      });

      // 자동 저장 타이머
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(milliseconds: 300), _saveChanges);
    }
  }

  // 메모 저장
  void _saveChanges({bool immediate = false}) {
    if (_isSaving) return;

    if (_dragElementId != null && !immediate) {
      _markDirty();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final content = _contentController.text.trim();

    // 저장할 내용이 없으면 무시
    if (content.isEmpty && _elements.isEmpty) {
      setState(() {
        _isDirty = false;
        _isSaving = false;
      });
      return;
    }

    // 요소에 크기 정보 업데이트
    final updatedElements = _elements.map((element) {
      final size = _elementSizes[element.id];
      if (size != null) {
        return element.copyWithPosition(
          xFactor: element.xFactor,
          yFactor: element.yFactor,
          width: size.width,
          height: size.height,
        );
      }
      return element;
    }).toList();

    // 저장 로직
    Future<void> performSave() async {
      try {
        if (_isEditing && _currentMemoId != null) {
          await ref.read(memoProvider.notifier).updateMemo(
                _currentMemoId!,
                content,
                elements: updatedElements,
              );
        } else {
          final newMemoId = await ref.read(memoProvider.notifier).addMemo(
                content,
                elements: updatedElements,
              );

          if (newMemoId != null && mounted) {
            setState(() {
              _isEditing = true;
              _currentMemoId = newMemoId;
            });
          }
        }

        if (mounted) {
          setState(() {
            _isDirty = false;
            _isSaving = false;
          });
        }
      } catch (e) {
        print('메모 저장 오류: $e');
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }

    if (immediate) {
      performSave();
    } else {
      Future.microtask(performSave);
    }
  }

  // 위치 계산 (상대 -> 절대)
  Offset _getAbsolutePosition(MemoElement element, Size screenSize) {
    return Offset(
      element.xFactor * screenSize.width,
      element.yFactor * screenSize.height,
    );
  }

  // 위치 업데이트 (절대 -> 상대)
  void _updateElementPosition(String elementId, Offset position) {
    final screenSize = MediaQuery.of(context).size;
    final index = _elements.indexWhere((e) => e.id == elementId);

    if (index >= 0) {
      final element = _elements[index];
      final xFactor = position.dx / screenSize.width;
      final yFactor = position.dy / screenSize.height;

      final normalizedXFactor = xFactor.clamp(0.0, 0.95);
      final normalizedYFactor = yFactor.clamp(0.0, 0.95);

      final size = _elementSizes[element.id];

      setState(() {
        _elements[index] = element.copyWithPosition(
          xFactor: normalizedXFactor,
          yFactor: normalizedYFactor,
          width: size?.width,
          height: size?.height,
        );
      });

      _markDirty();
    }
  }

  // 요소 크기 업데이트
  void _updateElementSize(String elementId, double width, double height) {
    setState(() {
      _elementSizes[elementId] = Size(width, height);
    });

    _markDirty();
  }

  // 요소 제거
  void _removeElement(String elementId) {
    setState(() {
      _elements.removeWhere((e) => e.id == elementId);
      _elementSizes.remove(elementId);
    });

    _markDirty();
  }

  // 이미지 추가
  void _addImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _addImageFromFile(File(image.path));
    }
  }

  // 파일에서 이미지 요소 추가
  void _addImageFromFile(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    final savedImage = await file.copy(p.join(appDir.path, fileName));

    final screenSize = MediaQuery.of(context).size;
    final defaultXFactor = 0.1;
    final defaultYFactor = 0.3;

    final imageElement = ImageElement(
      id: const Uuid().v4(),
      path: savedImage.path,
      xFactor: defaultXFactor,
      yFactor: defaultYFactor,
      width: 200.0,
      height: 150.0,
    );

    setState(() {
      _elements.add(imageElement);
      _elementSizes[imageElement.id] = const Size(200.0, 150.0);
    });

    _markDirty();
  }

  // 코드 추가 다이얼로그
  void _showAddCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => CodeDialog(
        theme: ref.read(themeProvider),
        onSave: (codeElement) {
          setState(() {
            _elements.add(codeElement);
            _initElementSize(codeElement);
          });
          _markDirty();
        },
      ),
    );
  }

  // 링크 추가 다이얼로그
  void _showAddLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => LinkDialog(
        theme: ref.read(themeProvider),
        onSave: (linkElement) {
          setState(() {
            _elements.add(linkElement);
            _initElementSize(linkElement);
          });
          _markDirty();
        },
      ),
    );
  }

  // 표 추가 다이얼로그
  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (context) => TableDialog(
        theme: ref.read(themeProvider),
        onSave: (tableElement) {
          setState(() {
            _elements.add(tableElement);
            _initElementSize(tableElement);
          });
          _markDirty();
        },
      ),
    );
  }

  // 체크리스트 추가 다이얼로그
  void _showAddChecklistDialog() {
    showDialog(
      context: context,
      builder: (context) => ChecklistDialog(
        theme: ref.read(themeProvider),
        onSave: (checklistElement) {
          setState(() {
            _elements.add(checklistElement);
            _initElementSize(checklistElement);
          });
          _markDirty();
        },
      ),
    );
  }

  // 인용구 추가 다이얼로그
  void _showAddQuoteDialog() {
    showDialog(
      context: context,
      builder: (context) => QuoteDialog(
        theme: ref.read(themeProvider),
        onSave: (quoteElement) {
          setState(() {
            _elements.add(quoteElement);
            _initElementSize(quoteElement);
          });
          _markDirty();
        },
      ),
    );
  }

  // 구분선 추가 다이얼로그
  void _showAddDividerDialog() {
    // 현재 메모장 레이아웃 크기 계산 (실제 영역에 맞게)
    final screenSize = MediaQuery.of(context).size;

    // 텍스트 필드와 요소들이 배치되는 실제 영역 크기 계산
    // 화면 전체 너비는 패딩과 마진을 제외하고 거의 다 사용
    final layoutWidth = screenSize.width - 32; // 양쪽 기본 패딩 16px씩 제외

    // 높이는 스크롤 가능한 영역 (screenSize.height * 2로 정의됨)
    // 하지만 실제로 한 화면에 보이는 크기는 더 작으므로 적절한 값 사용
    final layoutHeight = screenSize.height - 150; // 앱바, 요소 생성바 등 공간 제외

    showDialog(
      context: context,
      builder: (context) => DividerDialog(
        theme: ref.read(themeProvider),
        onSave: (dividerElement) {
          // 요소 생성 시 측정된 레이아웃 크기에 맞게 조정
          final adjustedElement = DividerElement(
            id: dividerElement.id,
            isVertical: dividerElement.isVertical,
            thickness: dividerElement.thickness,
            color: dividerElement.color,
            xFactor: dividerElement.xFactor,
            yFactor: dividerElement.yFactor,
            // 방향에 따라 메모장 크기에 맞게 조정
            width: dividerElement.isVertical ? 50 : layoutWidth,
            height: dividerElement.isVertical ? layoutHeight : 50,
          );

          setState(() {
            _elements.add(adjustedElement);
            _initElementSize(adjustedElement);
          });
          _markDirty();
        },
      ),
    );
  }

  // 목록 추가 다이얼로그
  void _showAddListDialog() {
    showDialog(
      context: context,
      builder: (context) => ListDialog(
        theme: ref.read(themeProvider),
        onSave: (listElement) {
          setState(() {
            _elements.add(listElement);
            _initElementSize(listElement);
          });
          _markDirty();
        },
      ),
    );
  }

  @override
  void dispose() {
    // 타이머 취소
    _saveTimer?.cancel();

    // 변경 사항 저장
    if (_isDirty && !_isSaving) {
      final content = _contentController.text.trim();
      final elements = List<MemoElement>.from(_elements);
      final memoId = _currentMemoId;

      if (content.isNotEmpty || elements.isNotEmpty) {
        if (_isEditing && memoId != null) {
          Future.microtask(() {
            ref.read(memoProvider.notifier).updateMemo(
                  memoId,
                  content,
                  elements: elements,
                );
          });
        } else if (content.isNotEmpty) {
          Future.microtask(() {
            ref.read(memoProvider.notifier).addMemo(
                  content,
                  elements: elements,
                );
          });
        }
      }
    }

    // 리소스 해제
    _saveTimer?.cancel();
    _contentController.removeListener(_onTextChanged);
    _contentController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final backgroundColor = theme.backgroundColor;
    final textColor = theme.textColor;
    final screenSize = MediaQuery.of(context).size;

    // 메모를 찾지 못한 경우
    if (_memoNotFound) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarColor,
          elevation: 0,
          title: Text(
            AppStrings.memoNotFound,
            style: TextStyle(color: textColor),
          ),
        ),
        body: Center(
          child: Text(
            AppStrings.memoNotFound,
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }

    // 요소 정렬
    final sortedElements = List<MemoElement>.from(_elements)
      ..sort((a, b) => a.yFactor.compareTo(b.yFactor));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarColor,
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: true,
        title: Text(
          _isEditing ? '메모 수정' : '새 메모',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor, size: 24),
          padding: const EdgeInsets.all(12),
          onPressed: () {
            _saveChanges(immediate: true);
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // 요소 생성 버튼
          ElementCreationBar(
            theme: theme,
            onImagePressed: () => _addImage(context),
            onCodePressed: _showAddCodeDialog,
            onLinkPressed: _showAddLinkDialog,
            onTablePressed: _showAddTableDialog,
            onChecklistPressed: _showAddChecklistDialog,
            onQuotePressed: _showAddQuoteDialog,
            onDividerPressed: _showAddDividerDialog,
            onListPressed: _showAddListDialog,
          ),

          // 메인 콘텐츠
          Expanded(
            child: GuidelineBackground(
              color: textColor.withOpacity(0.05),
              spacing: 50.0,
              child: Stack(
                children: [
                  // 스크롤 가능한 콘텐츠 영역
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      height: screenSize.height * 2,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 텍스트 입력 필드
                          Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            child: MemoTextField(
                              controller: _contentController,
                              focusNode: _focusNode,
                              backgroundColor: backgroundColor,
                              textColor: textColor,
                              hintText: AppStrings.memoHint,
                              onChanged: _markDirty,
                            ),
                          ),

                          // 요소들
                          for (final element in sortedElements)
                            _buildElementWidget(
                                element, backgroundColor, textColor),

                          // 상태 표시
                          StatusIndicator(
                            isSaving: _isSaving,
                            isDirty: _isDirty,
                            appTheme: theme,
                            savingText: AppStrings.memoSaving,
                            changedText: AppStrings.memoChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 요소 타입에 따른 위젯 빌드
  Widget _buildElementWidget(
      MemoElement element, Color backgroundColor, Color textColor) {
    final size = _elementSizes[element.id] ?? const Size(200, 150);

    switch (element.type) {
      case MemoElementType.image:
        return ImageElementWidget(
          element: element as ImageElement,
          width: size.width,
          height: size.height,
          backgroundColor: backgroundColor,
          textColor: textColor,
          onRemove: _removeElement,
          onPositionChanged: _updateElementPosition,
          onSizeChanged: _updateElementSize,
          onEdit: _editElement,
        );

      case MemoElementType.code:
        return CodeElementWidget(
          element: element as CodeElement,
          width: size.width,
          height: size.height,
          backgroundColor: backgroundColor,
          textColor: textColor,
          onRemove: _removeElement,
          onPositionChanged: _updateElementPosition,
          onSizeChanged: _updateElementSize,
          onEdit: _editElement,
        );

      case MemoElementType.link:
        return LinkElementWidget(
          element: element as LinkElement,
          width: size.width,
          height: size.height,
          backgroundColor: backgroundColor,
          textColor: textColor,
          onRemove: _removeElement,
          onPositionChanged: _updateElementPosition,
          onSizeChanged: _updateElementSize,
          onEdit: _editElement,
        );

      case MemoElementType.table:
        return TableElementWidget(
          element: element as TableElement,
          width: size.width,
          height: size.height,
          backgroundColor: backgroundColor,
          textColor: textColor,
          onRemove: _removeElement,
          onPositionChanged: _updateElementPosition,
          onSizeChanged: _updateElementSize,
          onEdit: _editElement,
        );

      case MemoElementType.checklist:
        return ChecklistElementWidget(
          element: element as ChecklistElement,
          width: size.width,
          height: size.height,
          backgroundColor: backgroundColor,
          textColor: textColor,
          onRemove: _removeElement,
          onPositionChanged: _updateElementPosition,
          onSizeChanged: _updateElementSize,
          onEdit: _editElement,
          onItemsChanged: _updateChecklistItems,
        );

      case MemoElementType.quote:
        return QuoteElementWidget(
          element: element as QuoteElement,
          width: size.width,
          height: size.height,
          backgroundColor: backgroundColor,
          textColor: textColor,
          onRemove: _removeElement,
          onPositionChanged: _updateElementPosition,
          onSizeChanged: _updateElementSize,
          onEdit: _editElement,
        );

      case MemoElementType.divider:
        return DividerElementWidget(
          element: element as DividerElement,
          width: size.width,
          height: size.height,
          backgroundColor: backgroundColor,
          textColor: textColor,
          onRemove: _removeElement,
          onPositionChanged: _updateElementPosition,
          onSizeChanged: _updateElementSize,
          onEdit: _editElement,
        );

      case MemoElementType.list:
        return ListElementWidget(
          element: element as ListElement,
          width: size.width,
          height: size.height,
          backgroundColor: backgroundColor,
          textColor: textColor,
          onRemove: _removeElement,
          onPositionChanged: _updateElementPosition,
          onSizeChanged: _updateElementSize,
          onEdit: _editElement,
        );

      default:
        // 기본 컨테이너 반환 (지원되지 않는 요소 타입)
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: textColor.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '지원되지 않는 요소 타입: ${element.type}',
              style: TextStyle(color: textColor),
            ),
          ),
        );
    }
  }

  // 요소 편집 기능
  void _editElement(String elementId) {
    final element = _elements.firstWhere((e) => e.id == elementId);

    switch (element.type) {
      case MemoElementType.image:
        // 이미지는 갤러리에서 새로 선택
        _addImage(context);
        break;
      case MemoElementType.code:
        _editCodeElement(element as CodeElement);
        break;
      case MemoElementType.link:
        _editLinkElement(element as LinkElement);
        break;
      case MemoElementType.table:
        _editTableElement(element as TableElement);
        break;
      case MemoElementType.checklist:
        _editChecklistElement(element as ChecklistElement);
        break;
      case MemoElementType.quote:
        _editQuoteElement(element as QuoteElement);
        break;
      case MemoElementType.divider:
        _editDividerElement(element as DividerElement);
        break;
      case MemoElementType.list:
        _editListElement(element as ListElement);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('지원되지 않는 요소 타입입니다')),
        );
    }
  }

  // 코드 요소 편집
  void _editCodeElement(CodeElement element) {
    showDialog(
      context: context,
      builder: (context) => CodeDialog(
        theme: ref.read(themeProvider),
        initialCode: element.code,
        initialLanguage: element.language,
        onSave: (newElement) {
          setState(() {
            final index = _elements.indexWhere((e) => e.id == element.id);
            if (index >= 0) {
              // 기존 요소의 위치와 ID는 유지하고 내용만 업데이트
              _elements[index] = CodeElement(
                id: element.id,
                code: newElement.code,
                language: newElement.language,
                xFactor: element.xFactor,
                yFactor: element.yFactor,
                width: element.width,
                height: element.height,
              );
            }
          });
          _markDirty();
        },
      ),
    );
  }

  // 링크 요소 편집
  void _editLinkElement(LinkElement element) {
    showDialog(
      context: context,
      builder: (context) => LinkDialog(
        theme: ref.read(themeProvider),
        initialUrl: element.url,
        initialTitle: element.title,
        onSave: (newElement) {
          setState(() {
            final index = _elements.indexWhere((e) => e.id == element.id);
            if (index >= 0) {
              _elements[index] = LinkElement(
                id: element.id,
                url: newElement.url,
                title: newElement.title,
                xFactor: element.xFactor,
                yFactor: element.yFactor,
                width: element.width,
                height: element.height,
              );
            }
          });
          _markDirty();
        },
      ),
    );
  }

  // 표 요소 편집
  void _editTableElement(TableElement element) {
    showDialog(
      context: context,
      builder: (context) => TableDialog(
        theme: ref.read(themeProvider),
        initialData: element.data,
        initialRows: element.rows,
        initialColumns: element.columns,
        onSave: (newElement) {
          setState(() {
            final index = _elements.indexWhere((e) => e.id == element.id);
            if (index >= 0) {
              _elements[index] = TableElement(
                id: element.id,
                data: newElement.data,
                rows: newElement.rows,
                columns: newElement.columns,
                xFactor: element.xFactor,
                yFactor: element.yFactor,
                width: element.width,
                height: element.height,
              );
            }
          });
          _markDirty();
        },
      ),
    );
  }

  // 체크리스트 요소 편집
  void _editChecklistElement(ChecklistElement element) {
    showDialog(
      context: context,
      builder: (context) => ChecklistDialog(
        theme: ref.read(themeProvider),
        initialItems: element.items,
        onSave: (newElement) {
          setState(() {
            final index = _elements.indexWhere((e) => e.id == element.id);
            if (index >= 0) {
              _elements[index] = ChecklistElement(
                id: element.id,
                items: newElement.items,
                xFactor: element.xFactor,
                yFactor: element.yFactor,
                width: element.width,
                height: element.height,
              );
            }
          });
          _markDirty();
        },
      ),
    );
  }

  // 인용구 요소 편집
  void _editQuoteElement(QuoteElement element) {
    showDialog(
      context: context,
      builder: (context) => QuoteDialog(
        theme: ref.read(themeProvider),
        initialText: element.text,
        initialSource: element.source,
        onSave: (newElement) {
          setState(() {
            final index = _elements.indexWhere((e) => e.id == element.id);
            if (index >= 0) {
              _elements[index] = QuoteElement(
                id: element.id,
                text: newElement.text,
                source: newElement.source,
                xFactor: element.xFactor,
                yFactor: element.yFactor,
                width: element.width,
                height: element.height,
              );
            }
          });
          _markDirty();
        },
      ),
    );
  }

  // 구분선 요소 편집
  void _editDividerElement(DividerElement element) {
    // 현재 메모장 레이아웃 크기 계산
    final screenSize = MediaQuery.of(context).size;
    final layoutWidth = screenSize.width; // 패딩 제거
    final layoutHeight = screenSize.height - 150;

    showDialog(
      context: context,
      builder: (context) => DividerDialog(
        theme: ref.read(themeProvider),
        initialIsVertical: element.isVertical,
        initialThickness: element.thickness,
        initialColor: element.color, // 현재 색상도 전달
        onSave: (newElement) {
          setState(() {
            final index = _elements.indexWhere((e) => e.id == element.id);
            if (index >= 0) {
              // 방향이 바뀌었을 경우 크기를 레이아웃에 맞게 업데이트
              final updatedWidth = newElement.isVertical ? 50.0 : layoutWidth;
              final updatedHeight =
                  newElement.isVertical ? layoutHeight.toDouble() : 50.0;

              _elements[index] = DividerElement(
                id: element.id,
                isVertical: newElement.isVertical,
                thickness: newElement.thickness,
                color: newElement.color,
                xFactor: element.xFactor,
                yFactor: element.yFactor,
                width: updatedWidth,
                height: updatedHeight,
              );

              // 요소 크기 정보 업데이트
              _elementSizes[element.id] = Size(updatedWidth, updatedHeight);
            }
          });
          _markDirty();
        },
      ),
    );
  }

  // 목록 요소 편집
  void _editListElement(ListElement element) {
    showDialog(
      context: context,
      builder: (context) => ListDialog(
        theme: ref.read(themeProvider),
        initialItems: element.items,
        initialIsOrdered: element.isOrdered,
        onSave: (newElement) {
          setState(() {
            final index = _elements.indexWhere((e) => e.id == element.id);
            if (index >= 0) {
              _elements[index] = ListElement(
                id: element.id,
                items: newElement.items,
                isOrdered: newElement.isOrdered,
                xFactor: element.xFactor,
                yFactor: element.yFactor,
                width: element.width,
                height: element.height,
              );
            }
          });
          _markDirty();
        },
      ),
    );
  }

  // 체크리스트 항목 변경 처리
  void _updateChecklistItems(ChecklistElement updatedElement) {
    setState(() {
      final index = _elements.indexWhere((e) => e.id == updatedElement.id);
      if (index >= 0) {
        _elements[index] = updatedElement;
      }
    });
    _markDirty(); // 변경 사항 저장
  }
}
