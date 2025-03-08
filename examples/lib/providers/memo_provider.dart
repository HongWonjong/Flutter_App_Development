import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memo.dart';
import '../models/memo_element.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 메모 상태 관리를 위한 Notifier 클래스
class MemoNotifier extends StateNotifier<List<Memo>> {
  final DatabaseService _dbService = DatabaseService();

  MemoNotifier() : super([]) {
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final memosJson = prefs.getString('memos');
    if (memosJson != null) {
      final memosList = jsonDecode(memosJson) as List;
      state = memosList.map((json) => Memo.fromJson(json)).toList();
    }
  }

  Future<void> _saveMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final memosJson = jsonEncode(state.map((memo) => memo.toJson()).toList());
    await prefs.setString('memos', memosJson);
  }

  Future<String?> addMemo(String content,
      {List<MemoElement> elements = const []}) async {
    if (content.trim().isEmpty && elements.isEmpty) return null;

    final memo = Memo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      elements: elements,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = [...state, memo];
    await _saveMemos();
    return memo.id;
  }

  Future<void> updateMemo(String id, String content,
      {List<MemoElement> elements = const []}) async {
    state = [
      for (final memo in state)
        if (memo.id == id)
          memo.copyWith(
            content: content,
            elements: elements,
            updatedAt: DateTime.now(),
          )
        else
          memo
    ];
    await _saveMemos();
  }

  Future<void> deleteMemo(String id) async {
    state = state.where((memo) => memo.id != id).toList();
    await _saveMemos();
  }

  Future<void> toggleFavorite(String id) async {
    state = [
      for (final memo in state)
        if (memo.id == id) memo.copyWith(isFavorite: !memo.isFavorite) else memo
    ];
    await _saveMemos();
  }

  Future<void> addElement(String memoId, MemoElement element) async {
    final memoIndex = state.indexWhere((memo) => memo.id == memoId);
    if (memoIndex >= 0) {
      final memo = state[memoIndex];
      final updatedElements = [...memo.elements, element];

      final updatedMemo = memo.copyWith(
        elements: updatedElements,
        updatedAt: DateTime.now(),
      );

      await _dbService.saveMemo(updatedMemo);
      await _loadMemos();
    }
  }

  Future<void> removeElement(String memoId, String elementId) async {
    final memoIndex = state.indexWhere((memo) => memo.id == memoId);
    if (memoIndex >= 0) {
      final memo = state[memoIndex];
      final updatedElements =
          memo.elements.where((e) => e.id != elementId).toList();

      final updatedMemo = memo.copyWith(
        elements: updatedElements,
        updatedAt: DateTime.now(),
      );

      await _dbService.saveMemo(updatedMemo);
      await _loadMemos();
    }
  }

  String _generateTitle(String content) {
    if (content.isEmpty) {
      return '새 메모'; // '제목 없음' 대신 더 의미 있는 제목
    }

    // 첫 줄을 제목으로 (최대 20자)
    final firstLine = content.split('\n').first.trim();
    if (firstLine.isEmpty) {
      return '새 메모';
    }

    return firstLine.length > 20
        ? '${firstLine.substring(0, 20)}...'
        : firstLine;
  }
}

// 메모 제공자
final memoProvider = StateNotifierProvider<MemoNotifier, List<Memo>>((ref) {
  return MemoNotifier();
});

// 탭 인덱스 제공자
final tabIndexProvider = StateProvider<int>((ref) => 0);
