import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _db;

  /// Khởi tạo database và tạo bảng nếu chưa có
  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocab.db');
<<<<<<< HEAD
    
    print('📂 Database path: $path');
=======
    // await deleteDatabase(path);
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
<<<<<<< HEAD
        print('🆕 Tạo database mới...');
        
        await db.execute('''
          CREATE TABLE topics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT UNIQUE,
=======
        await db.execute('''
          CREATE TABLE topics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
            topic_index INTEGER,
            name TEXT,
            image TEXT,
            length INTEGER,
<<<<<<< HEAD
            percent INTEGER DEFAULT 0
=======
            percent INTEGER
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
          );
        ''');

        await db.execute('''
          CREATE TABLE words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
<<<<<<< HEAD
            name TEXT UNIQUE,
=======
            name TEXT,
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
            phonetic TEXT,
            translate TEXT,
            isLearned INTEGER DEFAULT 0
          );
        ''');
<<<<<<< HEAD
        
        print('✅ Database đã tạo xong!');
      },
      onOpen: (db) async {
        print('📖 Mở database hiện có');
        // Kiểm tra số lượng dữ liệu
        final topicCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM topics')
        ) ?? 0;
        final wordCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM words')
        ) ?? 0;
        print('   - Có $topicCount chủ đề');
        print('   - Có $wordCount từ vựng');
=======
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
      },
    );
  }

<<<<<<< HEAD
  /// Reset database (chỉ dùng khi cần xóa toàn bộ)
  static Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocab.db');
    await deleteDatabase(path);
    print('🗑️ Đã xóa database');
    await init();
  }

=======
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
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
<<<<<<< HEAD
    final updated = await _db!.update('words', {'isLearned': 1}, where: 'name = ?', whereArgs: [name]);
    print('✅ Đánh dấu từ "$name" đã học (rows updated: $updated)');
=======
    await _db!.update('words', {'isLearned': 1}, where: 'name = ?', whereArgs: [name]);
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
  }

  /// Đếm số từ đã học trong một chủ đề
  static Future<int> countLearnedWords(String topic) async {
    final result = await _db!.rawQuery(
      'SELECT COUNT(*) FROM words WHERE topic = ? AND isLearned = 1',
      [topic],
    );
<<<<<<< HEAD
    final count = Sqflite.firstIntValue(result) ?? 0;
    print('📊 Số từ đã học trong "$topic": $count');
    return count;
=======
    return Sqflite.firstIntValue(result) ?? 0;
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
  }

  /// Cập nhật phần trăm đã học của chủ đề
  static Future<void> updateTopicPercent(String topic, int percent) async {
<<<<<<< HEAD
    print('💾 Đang cập nhật percent cho "$topic": $percent%');
    
    final updated = await _db!.update(
      'topics', 
      {'percent': percent}, 
      where: 'topic = ?', 
      whereArgs: [topic],
    );
    
    print('   → Số rows đã update: $updated');
    
    // Kiểm tra lại xem đã lưu chưa
    final check = await _db!.query('topics', where: 'topic = ?', whereArgs: [topic]);
    if (check.isNotEmpty) {
      final savedPercent = check.first['percent'];
      if (savedPercent == percent) {
        print('   ✅ Xác nhận: ${check.first['name']} = $savedPercent% (ĐÚNG!)');
      } else {
        print('   ❌ LỖI: Lưu $percent% nhưng đọc lại được $savedPercent%');
      }
    } else {
      print('   ❌ LỖI: Không tìm thấy topic "$topic" trong database');
    }
=======
    await _db!.update('topics', {'percent': percent}, where: 'topic = ?', whereArgs: [topic]);
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
  }

  /// Xóa toàn bộ dữ liệu (nếu cần reset)
  static Future<void> clearAll() async {
    await _db!.delete('topics');
    await _db!.delete('words');
  }
}
