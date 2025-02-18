import 'package:idb_shim/idb_shim.dart';
import 'dart:typed_data';

class IndexedDbService {
  static const String dbName = 'VideoSubtitlesDB';
  static const String storeName = 'videos';
  Database? _db;

  // 데이터베이스 초기화
  Future<Database> _getDatabase() async {
    if (_db != null) return _db!;
    final idbFactory = idbFactoryWeb; // 웹용 IndexedDB 팩토리
    _db = await idbFactory.open(
      dbName,
      version: 1,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final db = event.database;
        db.createObjectStore(storeName, autoIncrement: true);
      },
    );
    return _db!;
  }

  // 비디오 데이터 저장
  Future<int> saveVideo(Uint8List videoBytes) async {
    final db = await _getDatabase();
    final txn = db.transaction(storeName, 'readwrite');
    final store = txn.objectStore(storeName);
    final key = await store.put(videoBytes); // 비디오 바이트 저장
    await txn.completed;
    return key as int; // 저장된 키 반환
  }

  // 비디오 데이터 불러오기
  Future<Uint8List?> getVideo(int key) async {
    final db = await _getDatabase();
    final txn = db.transaction(storeName, 'readonly');
    final store = txn.objectStore(storeName);
    final data = await store.getObject(key);
    await txn.completed;
    return data as Uint8List?;
  }

  // 비디오 데이터 삭제
  Future<void> deleteVideo(int key) async {
    final db = await _getDatabase();
    final txn = db.transaction(storeName, 'readwrite');
    final store = txn.objectStore(storeName);
    await store.delete(key);
    await txn.completed;
  }
}