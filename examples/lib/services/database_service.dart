import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/memo.dart';

// 데이터베이스 헬퍼 클래스
class DatabaseService {
  static const String _memosKey = 'memos';
  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_memosKey)) {
      await prefs.setString(_memosKey, '[]');
    }
  }

  Future<List<Memo>> getMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final memosJson = prefs.getString(_memosKey) ?? '[]';
    final memosList = jsonDecode(memosJson) as List;
    return memosList
        .map((json) => Memo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMemos(List<Memo> memos) async {
    final prefs = await SharedPreferences.getInstance();
    final memosJson = jsonEncode(memos.map((memo) => memo.toJson()).toList());
    await prefs.setString(_memosKey, memosJson);
  }

  Future<void> saveMemo(Memo memo) async {
    final memos = await getMemos();
    final index = memos.indexWhere((m) => m.id == memo.id);
    if (index >= 0) {
      memos[index] = memo;
    } else {
      memos.add(memo);
    }
    await saveMemos(memos);
  }

  Future<void> removeMemo(String id) async {
    final memos = await getMemos();
    memos.removeWhere((memo) => memo.id == id);
    await saveMemos(memos);
  }

  Future<bool> resetAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_memosKey, '[]');
      return true;
    } catch (e) {
      return false;
    }
  }
}
