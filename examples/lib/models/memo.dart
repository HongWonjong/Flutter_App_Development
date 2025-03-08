import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'memo_element.dart';

// 메모 모델 클래스
class Memo {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final List<MemoElement> elements;

  String get title {
    // 첫 줄을 제목으로 사용
    final firstLine = content.split('\n').first.trim();
    return firstLine.isEmpty ? '제목 없음' : firstLine;
  }

  Memo({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.elements = const [],
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'elements': elements.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  // JSON 역직렬화
  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'] as String,
      content: json['content'] as String,
      elements: (json['elements'] as List?)
              ?.map((e) => MemoElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Memo copyWith({
    String? id,
    String? content,
    List<MemoElement>? elements,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return Memo(
      id: id ?? this.id,
      content: content ?? this.content,
      elements: elements ?? this.elements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // DB에서 사용할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
      'elements': jsonEncode(elements.map((e) => e.toMap()).toList()),
    };
  }

  // Map에서 Memo 객체 생성
  factory Memo.fromMap(Map<String, dynamic> map) {
    List<dynamic> elementsJson = [];
    try {
      elementsJson = jsonDecode(map['elements'] ?? '[]');
    } catch (e) {
      print('요소 파싱 오류: $e');
    }

    return Memo(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isFavorite: map['is_favorite'] == 1,
      elements: elementsJson
          .map((e) => MemoElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // 새 메모 생성
  factory Memo.create(String content, {List<MemoElement>? elements}) {
    return Memo(
      id: const Uuid().v4(),
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      elements: elements ?? [],
    );
  }
}
