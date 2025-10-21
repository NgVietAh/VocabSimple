import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _db;

  /// Khởi tạo database và tạo bảng nếu chưa có
  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocab.db');
    // await deleteDatabase(path);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE topics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
            topic_index INTEGER,
            name TEXT,
            image TEXT,
            length INTEGER,
            percent INTEGER
          );
        ''');

        await db.execute('''
          CREATE TABLE words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
            name TEXT,
            phonetic TEXT,
            translate TEXT,
            isLearned INTEGER DEFAULT 0
          );
        ''');
      },
    );
  }

  /// Thêm một chủ đề mới
  static Future<void> insertTopic(Map<String, dynamic> topic) async {
    await _db!.insert('topics', topic, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Thêm một từ mới
  static Future<void> insertWord(Map<String, dynamic> word) async {
    await _db!.insert('words', word, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Lấy danh sách chủ đề
  static Future<List<Map<String, dynamic>>> getTopics() async {
    return await _db!.query('topics', orderBy: 'topic_index ASC');
  }

  /// Lấy danh sách từ theo chủ đề
  static Future<List<Map<String, dynamic>>> getWordsByTopic(String topic) async {
    return await _db!.query('words', where: 'topic = ?', whereArgs: [topic]);
  }

  /// Đánh dấu từ đã học
  static Future<void> markWordAsLearned(String name) async {
    await _db!.update('words', {'isLearned': 1}, where: 'name = ?', whereArgs: [name]);
  }

  /// Đếm số từ đã học trong một chủ đề
  static Future<int> countLearnedWords(String topic) async {
    final result = await _db!.rawQuery(
      'SELECT COUNT(*) FROM words WHERE topic = ? AND isLearned = 1',
      [topic],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Cập nhật phần trăm đã học của chủ đề
  static Future<void> updateTopicPercent(String topic, int percent) async {
    await _db!.update('topics', {'percent': percent}, where: 'topic = ?', whereArgs: [topic]);
  }

  /// Xóa toàn bộ dữ liệu (nếu cần reset)
  static Future<void> clearAll() async {
    await _db!.delete('topics');
    await _db!.delete('words');
  }
}
