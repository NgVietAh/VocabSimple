import 'dart:convert';
import 'package:flutter/services.dart';
import 'local_database_service.dart';

class DataLoader {
  /// Đọc file JSON và lưu dữ liệu vào SQLite (chỉ load 1 lần)
  static Future<void> loadVocabularyFromJson() async {
    // Kiểm tra xem đã có dữ liệu chưa
    final existingTopics = await LocalDatabaseService.getTopics();
    if (existingTopics.isNotEmpty) {
      // Kiểm tra xem có dữ liệu trùng lặp không
      final uniqueTopics = <String>{};
      bool hasDuplicates = false;

      for (var topic in existingTopics) {
        final topicName = topic['topic'] as String;
        if (uniqueTopics.contains(topicName)) {
          hasDuplicates = true;
          break;
        }
        uniqueTopics.add(topicName);
      }

      if (hasDuplicates) {
        print(' ...');
        await LocalDatabaseService.clearAll();
        // Không return ở đây, tiếp tục load lại dữ liệu
      } else {
        print('Database đã có ${existingTopics.length} chủ đề');
        return;
      }
    }

    print(' Đang load dữ liệu từ vocabulary.json vào database...');

    final jsonString = await rootBundle.loadString(
      'assets/data/vocabulary.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);

    int topicCount = 0;
    int wordCount = 0;

    for (var entry in data.entries) {
      final topicKey = entry.key;
      final topicData = entry.value as Map<String, dynamic>;

      // Lưu chủ đề
      await LocalDatabaseService.insertTopic({
        'topic': topicKey,
        'topic_index': topicData['topic_index'] ?? 0,
        'name': topicData['name'] ?? '',
        'image': topicData['image'] ?? '',
        'length': topicData['length'] ?? 0,
        'percent': topicData['percent'] ?? 0,
      });
      topicCount++;

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
        wordCount++;
      }
    }

    print(' $topicCount chủ đề, $wordCount từ vựng');
  }

  /// Reset toàn bộ database và load lại dữ liệu
  static Future<void> resetAndReload() async {
    await LocalDatabaseService.clearAll();
    await loadVocabularyFromJson();
  }
}
