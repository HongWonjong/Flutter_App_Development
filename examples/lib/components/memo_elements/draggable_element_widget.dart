import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';

/// 드래그 및 크기 조절이 가능한 메모 요소의 기본 위젯
class DraggableElementWidget extends StatefulWidget {
  final MemoElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Widget child;
  final Function(String)? onRemove;
  final Function(String, Offset)? onPositionChanged;
  final Function(String, double, double)? onSizeChanged;
  final Function(String)? onEdit;

  const DraggableElementWidget({
    Key? key,
    required this.element,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.textColor,
    required this.child,
    this.onRemove,
    this.onPositionChanged,
    this.onSizeChanged,
    this.onEdit,
  }) : super(key: key);

  @override
  State<DraggableElementWidget> createState() => _DraggableElementWidgetState();
}

class _DraggableElementWidgetState extends State<DraggableElementWidget> {
  Offset? _dragOffset;
  Size? _initialSize;
  Offset? _initialResizePosition;
  bool _isResizing = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // 절대 위치 계산
    final position = Offset(
      widget.element.xFactor * screenSize.width,
      widget.element.yFactor * screenSize.height,
    );

    // 드래그 중인 위치 반영
    final currentPosition = _dragOffset ?? position;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: currentPosition.dx,
          top: currentPosition.dy,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 요소 본문
              Container(
                width: widget.width,
                height: widget.height,
                decoration: widget.element.type == MemoElementType.divider
                    ? null // 구분선인 경우 장식 없음
                    : BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.textColor.withOpacity(0.1),
                        ),
                      ),
                child: widget.child,
              ),

              // 드래그 핸들
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _dragOffset = currentPosition;
                    });
                  },
                  onPanUpdate: (details) {
                    if (!_isResizing) {
                      setState(() {
                        _dragOffset = Offset(
                          currentPosition.dx + details.delta.dx,
                          currentPosition.dy + details.delta.dy,
                        );
                      });
                    }
                  },
                  onPanEnd: (details) {
                    if (_dragOffset != null) {
                      // 위치 변경 콜백 호출
                      final newPosition = _dragOffset!;
                      if (widget.onPositionChanged != null) {
                        widget.onPositionChanged!(
                          widget.element.id,
                          newPosition,
                        );
                      }

                      setState(() {
                        _dragOffset = null;
                      });
                    }
                  },
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.textColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: widget.textColor.withOpacity(0.2),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 배경 아이콘 (그림자 효과)
                        Icon(
                          Icons.drag_handle,
                          size: 22,
                          color: widget.backgroundColor,
                        ),
                        // 전경 아이콘
                        Icon(
                          Icons.drag_handle,
                          size: 20,
                          color: widget.textColor.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 삭제 버튼
              Positioned(
                right: -6,
                top: -6,
                child: GestureDetector(
                  onTap: () => _onRemove(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // 편집 버튼
              Positioned(
                left: -6,
                top: -6,
                child: GestureDetector(
                  onTap: () => _onEdit(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 크기 조절 핸들을 최상위 Stack으로 이동
        Positioned(
          left: currentPosition.dx + widget.width - 15,
          top: currentPosition.dy + widget.height - 15,
          child: _buildResizeHandle(),
        ),
      ],
    );
  }

  // 크기 조절 핸들 빌드
  Widget _buildResizeHandle() {
    final isDivider = widget.element.type == MemoElementType.divider;
    final dividerElement = isDivider ? widget.element as DividerElement : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        setState(() {
          _isResizing = true;
          _initialSize = Size(widget.width, widget.height);
          _initialResizePosition = details.globalPosition;
        });
      },
      onPanUpdate: (details) {
        if (_initialSize != null && _initialResizePosition != null) {
          final dx = details.globalPosition.dx - _initialResizePosition!.dx;
          final dy = details.globalPosition.dy - _initialResizePosition!.dy;

          // 최소 크기 설정
          final minWidth =
              isDivider && !dividerElement!.isVertical ? 100.0 : 50.0;
          final minHeight =
              isDivider && dividerElement!.isVertical ? 100.0 : 50.0;

          double newWidth = (_initialSize!.width + dx).clamp(minWidth, 3000.0);
          double newHeight =
              (_initialSize!.height + dy).clamp(minHeight, 3000.0);

          // 구분선의 경우 가로/세로에 따라 한쪽 치수만 변경
          if (isDivider) {
            if (dividerElement!.isVertical) {
              newWidth = widget.width; // 너비는 고정
            } else {
              newHeight = widget.height; // 높이는 고정
            }
          }

          if (widget.onSizeChanged != null) {
            widget.onSizeChanged!(widget.element.id, newWidth, newHeight);
          }
        }
      },
      onPanEnd: (details) {
        setState(() {
          _isResizing = false;
          _initialSize = null;
          _initialResizePosition = null;
        });
      },
      child: Container(
        width: 52, // 실제 핸들(32) + 패딩(20)
        height: 52, // 실제 핸들(32) + 패딩(20)
        padding: const EdgeInsets.all(10), // 10픽셀 패딩
        child: Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.textColor.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            Icons.open_in_full,
            size: 18,
            color: widget.textColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  // 삭제 콜백 호출
  void _onRemove() {
    if (widget.onRemove != null) {
      widget.onRemove!(widget.element.id);
    }
  }

  // 편집 콜백 호출
  void _onEdit() {
    if (widget.onEdit != null) {
      widget.onEdit!(widget.element.id);
    }
  }
}
