import 'package:flutter/material.dart';
import '../models/memo_element.dart';

// 요소 편집기 컴포넌트
class ElementEditor extends StatelessWidget {
  final MemoElement element;
  final VoidCallback onDelete;

  const ElementEditor({Key? key, required this.element, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(_getElementTitle()),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }

  String _getElementTitle() {
    switch (element.type) {
      case MemoElementType.image:
        return '이미지';
      case MemoElementType.code:
        final codeElement = element as CodeElement;
        return '코드 (${codeElement.language})';
      case MemoElementType.link:
        final linkElement = element as LinkElement;
        return '링크: ${linkElement.title}';
      case MemoElementType.table:
        final tableElement = element as TableElement;
        return '표 (${tableElement.rows}x${tableElement.columns})';
      case MemoElementType.checklist:
        final checklistElement = element as ChecklistElement;
        return '체크리스트 (${checklistElement.items.length}개 항목)';
      case MemoElementType.quote:
        return '인용구';
      case MemoElementType.divider:
        final dividerElement = element as DividerElement;
        return '구분선 (${dividerElement.isVertical ? "세로" : "가로"})';
      case MemoElementType.list:
        final listElement = element as ListElement;
        return '${listElement.isOrdered ? "순서 있는" : "순서 없는"} 목록 (${listElement.items.length}개 항목)';
    }
  }
}
