import 'dart:convert';
import 'package:flutter/services.dart';
import 'local_database_service.dart';

class DataLoader {
<<<<<<< HEAD
  /// Đọc file JSON và lưu dữ liệu vào SQLite (chỉ load 1 lần)
  static Future<void> loadVocabularyFromJson() async {
    // Kiểm tra xem đã có dữ liệu chưa
    final existingTopics = await LocalDatabaseService.getTopics();
    if (existingTopics.isNotEmpty) {
      // Đã có dữ liệu rồi, không cần load lại
      print('✓ Database đã có ${existingTopics.length} chủ đề, bỏ qua việc load JSON');
      return;
    }

    print('🔄 Đang load dữ liệu từ vocabulary.json vào database...');

    final jsonString = await rootBundle.loadString('assets/data/vocabulary.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    int topicCount = 0;
    int wordCount = 0;

=======
  /// Đọc file JSON và lưu dữ liệu vào SQLite
  static Future<void> loadVocabularyFromJson() async {
    final jsonString = await rootBundle.loadString('assets/data/vocabulary.json');
    final Map<String, dynamic> data = json.decode(jsonString);

>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
    for (var entry in data.entries) {
      final topicKey = entry.key;
      final topicData = entry.value as Map<String, dynamic>;

      // Lưu chủ đề
      await LocalDatabaseService.insertTopic({
        'topic': topicKey,
<<<<<<< HEAD
        'topic_index': topicData['topic_index'] ?? 0,
=======
        'topic_index': topicData['index'] ?? 0,
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
        'name': topicData['name'] ?? '',
        'image': topicData['image'] ?? '',
        'length': topicData['length'] ?? 0,
        'percent': topicData['percent'] ?? 0,
      });
<<<<<<< HEAD
      topicCount++;
=======
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff

      // Lưu từ vựng
      final words = topicData['words'] as Map<String, dynamic>;
      for (var wordEntry in words.entries) {
        final word = wordEntry.value as Map<String, dynamic>;
        await LocalDatabaseService.insertWord({
          'topic': topicKey,
          'name': word['name'] ?? '',
          'phonetic': word['phonetic'] ?? '',
          'translate': word['translate'] ?? '',
          'isLearned': 0,
        });
<<<<<<< HEAD
        wordCount++;
      }
    }
    
    print('✅ Đã load xong: $topicCount chủ đề, $wordCount từ vựng');
=======
      }
    }
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff
  }
}
