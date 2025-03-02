import '../class/srt_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/srt_modify_service.dart';

class SrtModifyState {
  final String? srtContent; // 번역된 SRT
  final String? originalSrtContent; // 원본 SRT (추가)
  final List<SrtEntry> parsedSrtEntries; // 파싱된 자막 리스트
  final bool isEditing; // 편집 중 여부
  final String? modifiedSrtContent; // 수정된 SRT 문자열
  final List<SrtEntry> modifiedSrtEntries; // 수정된 자막 리스트
  final String? errorMessage; // 오류 메시지
  final bool isModified; // 수정 완료 여부
  final String? firstSubtitle; // 첫 번째 자막 텍스트

  SrtModifyState({
    this.srtContent,
    this.originalSrtContent, // 원본 SRT 필드 추가
    this.parsedSrtEntries = const [],
    this.isEditing = false,
    this.modifiedSrtContent,
    this.modifiedSrtEntries = const [],
    this.errorMessage,
    this.isModified = false,
    this.firstSubtitle,
  });

  SrtModifyState copyWith({
    String? srtContent,
    String? originalSrtContent, // copyWith에 추가
    List<SrtEntry>? parsedSrtEntries,
    bool? isEditing,
    String? modifiedSrtContent,
    List<SrtEntry>? modifiedSrtEntries,
    String? errorMessage,
    bool? isModified,
    String? firstSubtitle,
  }) {
    return SrtModifyState(
      srtContent: srtContent ?? this.srtContent,
      originalSrtContent: originalSrtContent ?? this.originalSrtContent, // 기존 값 유지
      parsedSrtEntries: parsedSrtEntries ?? this.parsedSrtEntries,
      isEditing: isEditing ?? this.isEditing,
      modifiedSrtContent: modifiedSrtContent ?? this.modifiedSrtContent,
      modifiedSrtEntries: modifiedSrtEntries ?? this.modifiedSrtEntries,
      errorMessage: errorMessage ?? this.errorMessage,
      isModified: isModified ?? this.isModified,
      firstSubtitle: firstSubtitle ?? this.firstSubtitle,
    );
  }
}

class SrtModifyNotifier extends StateNotifier<SrtModifyState> {
  SrtModifyNotifier() : super(SrtModifyState());

  void setSrtContent(String translatedSrt, String originalSrt) {
    final parsedEntries = SrtModifyService.parseSrt(translatedSrt, originalSrt);
    final firstSubtitle = _getFirstSubtitle(translatedSrt); // 번역된 SRT에서 첫 자막 추출
    state = state.copyWith(
      srtContent: translatedSrt,
      originalSrtContent: originalSrt, // 원본 SRT 저장
      parsedSrtEntries: parsedEntries,
      modifiedSrtEntries: parsedEntries, // 초기에는 파싱된 항목으로 설정
      isModified: false,
      firstSubtitle: firstSubtitle,
    );
  }

  void updateModifiedEntries(List<SrtEntry> modifiedEntries) {
    final modifiedSrtContent = SrtModifyService.updateSrt(modifiedEntries);
    final firstSubtitle = _getFirstSubtitle(modifiedSrtContent); // 수정된 SRT에서 첫 자막 추출
    state = state.copyWith(
      modifiedSrtEntries: modifiedEntries,
      modifiedSrtContent: modifiedSrtContent,
      isModified: true,
      firstSubtitle: firstSubtitle,
    );
  }

  void setEditing(bool isEditing) {
    state = state.copyWith(isEditing: isEditing);
  }

  void setErrorMessage(String errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }

  // 첫 번째 자막을 추출하는 헬퍼 메서드
  String _getFirstSubtitle(String srtContent) {
    final lines = srtContent.split('\n');
    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i].contains('-->')) {
        return lines[i + 1].trim(); // 시간 코드 다음 줄의 자막 텍스트 반환
      }
    }
    return '자막 없음'; // 자막이 없을 경우 기본값
  }
}

final srtModifyProvider = StateNotifierProvider<SrtModifyNotifier, SrtModifyState>(
      (ref) => SrtModifyNotifier(),
);