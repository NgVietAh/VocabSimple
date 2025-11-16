import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _db;

  /// Khởi tạo database và tạo bảng nếu chưa có
  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocab.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE topics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT UNIQUE,
            topic_index INTEGER,
            name TEXT,
            image TEXT,
            length INTEGER,
            percent INTEGER DEFAULT 0
          );
        ''');

        await db.execute('''
          CREATE TABLE words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
            name TEXT UNIQUE,
            phonetic TEXT,
            translate TEXT,
            isLearned INTEGER DEFAULT 0
          );
        ''');

        await db.execute('''
          CREATE TABLE test_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            test_name TEXT,
            total_questions INTEGER,
            correct_answers INTEGER,
            wrong_answers INTEGER,
            skipped_answers INTEGER,
            score REAL,
            time_taken INTEGER,
            completed_at TEXT
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS test_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              test_name TEXT,
              total_questions INTEGER,
              correct_answers INTEGER,
              wrong_answers INTEGER,
              skipped_answers INTEGER,
              score REAL,
              time_taken INTEGER,
              completed_at TEXT
            );
          ''');
        }
      },
      onOpen: (db) async {
        // Kiểm tra số lượng dữ liệu
        final topicCount =
            Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM topics'),
            ) ??
            0;
        final wordCount =
            Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM words'),
            ) ??
            0;
      },
    );
  }

  /// Reset database (chỉ dùng khi cần xóa toàn bộ)
  static Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocab.db');
    await deleteDatabase(path);
    await init();
  }

  /// Thêm một chủ đề mới
  static Future<void> insertTopic(Map<String, dynamic> topic) async {
    await _db!.insert(
      'topics',
      topic,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Thêm một từ mới
  static Future<void> insertWord(Map<String, dynamic> word) async {
    await _db!.insert(
      'words',
      word,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lấy danh sách chủ đề
  static Future<List<Map<String, dynamic>>> getTopics() async {
    return await _db!.query('topics', orderBy: 'topic_index ASC');
  }

  /// Lấy danh sách từ theo chủ đề
  static Future<List<Map<String, dynamic>>> getWordsByTopic(
    String topic,
  ) async {
    return await _db!.query('words', where: 'topic = ?', whereArgs: [topic]);
  }

  /// Đánh dấu từ đã học
  static Future<void> markWordAsLearned(String name) async {
    final updated = await _db!.update(
      'words',
      {'isLearned': 1},
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  /// Đếm số từ đã học trong một chủ đề
  static Future<int> countLearnedWords(String topic) async {
    final result = await _db!.rawQuery(
      'SELECT COUNT(*) FROM words WHERE topic = ? AND isLearned = 1',
      [topic],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  /// Cập nhật phần trăm đã học của chủ đề
  static Future<void> updateTopicPercent(String topic, int percent) async {
    final updated = await _db!.update(
      'topics',
      {'percent': percent},
      where: 'topic = ?',
      whereArgs: [topic],
    );

    print('   → Số rows đã update: $updated');

    // Kiểm tra lại xem đã lưu chưa
    final check = await _db!.query(
      'topics',
      where: 'topic = ?',
      whereArgs: [topic],
    );
    if (check.isNotEmpty) {
      final savedPercent = check.first['percent'];
      if (savedPercent == percent) {
      } else {}
    } else {}
  }

  /// Xóa toàn bộ dữ liệu (nếu cần reset)
  static Future<void> clearAll() async {
    await _db!.delete('topics');
    await _db!.delete('words');
  }

  /// Lưu kết quả test
  static Future<void> saveTestResult({
    required String testName,
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
    required int skippedAnswers,
    required double score,
    required int timeTakenSeconds,
  }) async {
    await _db!.insert('test_history', {
      'test_name': testName,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'skipped_answers': skippedAnswers,
      'score': score,
      'time_taken': timeTakenSeconds,
      'completed_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Lấy lịch sử test
  static Future<List<Map<String, dynamic>>> getTestHistory() async {
    return await _db!.query(
      'test_history',
      orderBy: 'completed_at DESC',
      limit: 50,
    );
  }

  /// Đếm số bài test đã làm
  static Future<int> countCompletedTests() async {
    final result = await _db!.rawQuery('SELECT COUNT(*) FROM test_history');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Lấy điểm trung bình
  static Future<double> getAverageScore() async {
    final result = await _db!.rawQuery(
      'SELECT AVG(score) as avg_score FROM test_history',
    );
    if (result.isNotEmpty && result.first['avg_score'] != null) {
      return (result.first['avg_score'] as num).toDouble();
    }
    return 0.0;
  }

  /// Tìm kiếm từ vựng
  static Future<List<Map<String, dynamic>>> searchWords(String query) async {
    final lowerQuery = query.toLowerCase();

    // Tìm kiếm trong cả tên tiếng Anh và nghĩa tiếng Việt
    final results = await _db!.rawQuery(
      '''
      SELECT w.*, t.name as topic_name
      FROM words w
      LEFT JOIN topics t ON w.topic = t.topic
      WHERE LOWER(w.name) LIKE ? OR LOWER(w.translate) LIKE ?
      ORDER BY w.name ASC
      LIMIT 50
    ''',
      ['%$lowerQuery%', '%$lowerQuery%'],
    );

    return results;
  }
}
