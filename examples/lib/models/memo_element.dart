import 'dart:convert';
import 'package:flutter/material.dart'; // Color 클래스를 위한 import 추가

// 메모 요소 타입 열거형
enum MemoElementType {
  image,
  code,
  link,
  table,
  checklist, // 체크리스트
  quote, // 인용구
  divider, // 구분선
  list // 목록
}

// 메모 요소 기본 클래스
abstract class MemoElement {
  final String id;
  final MemoElementType type;
  final double xFactor; // 화면 너비에 대한 상대적 위치 (0.0 ~ 1.0)
  final double yFactor; // 화면 높이에 대한 상대적 위치 (0.0 ~ 1.0)
  final double width; // 추가: 너비
  final double height; // 추가: 높이

  MemoElement({
    required this.id,
    required this.type,
    this.xFactor = 0.1, // 기본값: 화면 왼쪽 10% 위치
    this.yFactor = 0.1, // 기본값: 화면 상단 10% 위치
    this.width = 200.0, // 기본값 설정
    this.height = 150.0, // 기본값 설정
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width, // 맵에 크기 정보 추가
      'height': height, // 맵에 크기 정보 추가
    };
  }

  Map<String, dynamic> toJson();

  factory MemoElement.fromJson(Map<String, dynamic> json) {
    final type = MemoElementType.values.firstWhere(
      (e) => e.toString() == 'MemoElementType.${json['type']}',
    );

    switch (type) {
      case MemoElementType.image:
        return ImageElement.fromJson(json);
      case MemoElementType.code:
        return CodeElement.fromJson(json);
      case MemoElementType.link:
        return LinkElement.fromJson(json);
      case MemoElementType.table:
        return TableElement.fromJson(json);
      case MemoElementType.checklist:
        return ChecklistElement.fromJson(json);
      case MemoElementType.quote:
        return QuoteElement.fromJson(json);
      case MemoElementType.divider:
        return DividerElement.fromJson(json);
      case MemoElementType.list:
        return ListElement.fromJson(json);
    }
  }

  // 새 위치와 크기로 복사본 생성
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  });
}

// 이미지 요소
class ImageElement extends MemoElement {
  final String path;

  ImageElement({
    required String id,
    required this.path,
    double xFactor = 0.1,
    double yFactor = 0.1,
    double width = 200.0,
    double height = 150.0,
  }) : super(
          id: id,
          type: MemoElementType.image,
          xFactor: xFactor,
          yFactor: yFactor,
          width: width,
          height: height,
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['path'] = path;
    return map;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'path': path,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      id: json['id'] as String,
      path: json['path'] as String,
      xFactor: json['xFactor'] as double,
      yFactor: json['yFactor'] as double,
      width: json['width'] as double? ?? 200.0,
      height: json['height'] as double? ?? 150.0,
    );
  }

  @override
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  }) {
    return ImageElement(
      id: id,
      path: path,
      xFactor: xFactor ?? this.xFactor,
      yFactor: yFactor ?? this.yFactor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

// 코드 요소
class CodeElement extends MemoElement {
  final String code;
  final String language;

  CodeElement({
    required String id,
    required this.code,
    this.language = 'text',
    double xFactor = 0.1,
    double yFactor = 0.1,
    double width = 300.0,
    double height = 200.0,
  }) : super(
          id: id,
          type: MemoElementType.code,
          xFactor: xFactor,
          yFactor: yFactor,
          width: width,
          height: height,
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['code'] = code;
    map['language'] = language;
    return map;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'code': code,
      'language': language,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  factory CodeElement.fromJson(Map<String, dynamic> json) {
    return CodeElement(
      id: json['id'] as String,
      code: json['code'] as String,
      language: json['language'] as String,
      xFactor: json['xFactor'] as double,
      yFactor: json['yFactor'] as double,
      width: json['width'] as double? ?? 300.0,
      height: json['height'] as double? ?? 200.0,
    );
  }

  @override
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  }) {
    return CodeElement(
      id: id,
      code: code,
      language: language,
      xFactor: xFactor ?? this.xFactor,
      yFactor: yFactor ?? this.yFactor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

// 링크 요소
class LinkElement extends MemoElement {
  final String url;
  final String title;

  LinkElement({
    required String id,
    required this.url,
    required this.title,
    double xFactor = 0.1,
    double yFactor = 0.1,
    double width = 300.0,
    double height = 120.0,
  }) : super(
          id: id,
          type: MemoElementType.link,
          xFactor: xFactor,
          yFactor: yFactor,
          width: width,
          height: height,
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['url'] = url;
    map['title'] = title;
    return map;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'url': url,
      'title': title,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  factory LinkElement.fromJson(Map<String, dynamic> json) {
    return LinkElement(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      xFactor: json['xFactor'] as double,
      yFactor: json['yFactor'] as double,
      width: json['width'] as double? ?? 300.0,
      height: json['height'] as double? ?? 120.0,
    );
  }

  @override
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  }) {
    return LinkElement(
      id: id,
      url: url,
      title: title,
      xFactor: xFactor ?? this.xFactor,
      yFactor: yFactor ?? this.yFactor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

// 표 요소
class TableElement extends MemoElement {
  final List<List<String>> data;
  final int rows;
  final int columns;

  TableElement({
    required String id,
    required this.data,
    required this.rows,
    required this.columns,
    double xFactor = 0.1,
    double yFactor = 0.1,
    double? width,
    double? height,
  }) : super(
          id: id,
          type: MemoElementType.table,
          xFactor: xFactor,
          yFactor: yFactor,
          width: width ?? columns * 80.0,
          height: height ?? rows * 40.0 + 20.0,
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['data'] = jsonEncode(data);
    map['rows'] = rows;
    map['columns'] = columns;
    return map;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
      'rows': rows,
      'columns': columns,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  factory TableElement.fromJson(Map<String, dynamic> json) {
    return TableElement(
      id: json['id'] as String,
      data: (json['data'] as List)
          .map((row) => (row as List).map((cell) => cell.toString()).toList())
          .toList(),
      rows: json['rows'] as int,
      columns: json['columns'] as int,
      xFactor: json['xFactor'] as double,
      yFactor: json['yFactor'] as double,
      width: json['width'] as double? ?? 0,
      height: json['height'] as double? ?? 0,
    );
  }

  @override
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  }) {
    return TableElement(
      id: id,
      data: data,
      rows: rows,
      columns: columns,
      xFactor: xFactor ?? this.xFactor,
      yFactor: yFactor ?? this.yFactor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

// ChecklistElement: 체크리스트 요소 클래스
class ChecklistElement extends MemoElement {
  final List<Map<String, dynamic>>
      items; // {text: String, checked: bool} 형태의 아이템들

  ChecklistElement({
    required String id,
    required this.items,
    required double xFactor,
    required double yFactor,
    double? width,
    double? height,
  }) : super(
          id: id,
          type: MemoElementType.checklist,
          xFactor: xFactor,
          yFactor: yFactor,
          width: width ?? 300,
          height: height ?? (items.length * 40 + 40).toDouble(),
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'items': items,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'items': items,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  factory ChecklistElement.fromJson(Map<String, dynamic> json) {
    return ChecklistElement(
      id: json['id'] as String,
      items: (json['items'] as List)
          .map((item) => {
                'text': item['text'] as String,
                'checked': item['checked'] as bool,
              })
          .toList(),
      xFactor: json['xFactor'] as double,
      yFactor: json['yFactor'] as double,
      width: json['width'] as double? ?? 300,
      height: json['height'] as double? ?? 0,
    );
  }

  @override
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  }) {
    return ChecklistElement(
      id: id,
      items: items,
      xFactor: xFactor ?? this.xFactor,
      yFactor: yFactor ?? this.yFactor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

// QuoteElement: 인용구 요소 클래스
class QuoteElement extends MemoElement {
  final String text;
  final String? source;

  QuoteElement({
    required String id,
    required this.text,
    this.source,
    required double xFactor,
    required double yFactor,
    double? width,
    double? height,
  }) : super(
          id: id,
          type: MemoElementType.quote,
          xFactor: xFactor,
          yFactor: yFactor,
          width: width ?? 300,
          height: height ?? 120,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'text': text,
      'source': source,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'text': text,
      'source': source,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  factory QuoteElement.fromJson(Map<String, dynamic> json) {
    return QuoteElement(
      id: json['id'] as String,
      text: json['text'] as String,
      source: json['source'] as String?,
      xFactor: json['xFactor'] as double,
      yFactor: json['yFactor'] as double,
      width: json['width'] as double? ?? 300,
      height: json['height'] as double? ?? 120,
    );
  }

  @override
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  }) {
    return QuoteElement(
      id: id,
      text: text,
      source: source,
      xFactor: xFactor ?? this.xFactor,
      yFactor: yFactor ?? this.yFactor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

// DividerElement: 구분선 요소 클래스
class DividerElement extends MemoElement {
  final bool isVertical;
  final double thickness;
  final Color? color;

  DividerElement({
    required String id,
    required this.isVertical,
    this.thickness = 2.0,
    this.color,
    required double xFactor,
    required double yFactor,
    double? width,
    double? height,
  }) : super(
          id: id,
          type: MemoElementType.divider,
          xFactor: xFactor,
          yFactor: yFactor,
          width: width ?? (isVertical ? 50 : 300), // 기본값만 적당히 지정
          height: height ?? (isVertical ? 300 : 50), // 기본값만 적당히 지정
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'isVertical': isVertical,
      'thickness': thickness,
      'color': color?.value,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'isVertical': isVertical,
      'thickness': thickness,
      'color': color?.value,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  factory DividerElement.fromJson(Map<String, dynamic> json) {
    return DividerElement(
      id: json['id'] as String,
      isVertical: json['isVertical'] as bool,
      thickness: json['thickness'] as double? ?? 2.0,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      xFactor: json['xFactor'] as double,
      yFactor: json['yFactor'] as double,
      width: json['width'] as double? ?? 0,
      height: json['height'] as double? ?? 0,
    );
  }

  @override
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  }) {
    return DividerElement(
      id: id,
      isVertical: isVertical,
      thickness: thickness,
      color: color,
      xFactor: xFactor ?? this.xFactor,
      yFactor: yFactor ?? this.yFactor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

// ListElement: 목록 요소 클래스
class ListElement extends MemoElement {
  final List<String> items;
  final bool isOrdered; // 순서가 있는 목록인지 여부

  ListElement({
    required String id,
    required this.items,
    this.isOrdered = false,
    required double xFactor,
    required double yFactor,
    double? width,
    double? height,
  }) : super(
          id: id,
          type: MemoElementType.list,
          xFactor: xFactor,
          yFactor: yFactor,
          width: width ?? 300,
          height: height ?? (items.length * 30 + 40).toDouble(),
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'items': items,
      'isOrdered': isOrdered,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'items': items,
      'isOrdered': isOrdered,
      'xFactor': xFactor,
      'yFactor': yFactor,
      'width': width,
      'height': height,
    };
  }

  factory ListElement.fromJson(Map<String, dynamic> json) {
    return ListElement(
      id: json['id'] as String,
      items: (json['items'] as List).map((item) => item.toString()).toList(),
      isOrdered: json['isOrdered'] as bool? ?? false,
      xFactor: json['xFactor'] as double,
      yFactor: json['yFactor'] as double,
      width: json['width'] as double? ?? 300,
      height: json['height'] as double? ?? 0,
    );
  }

  @override
  MemoElement copyWithPosition({
    double? xFactor,
    double? yFactor,
    double? width,
    double? height,
  }) {
    return ListElement(
      id: id,
      items: items,
      isOrdered: isOrdered,
      xFactor: xFactor ?? this.xFactor,
      yFactor: yFactor ?? this.yFactor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
