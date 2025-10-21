import 'dart:convert';
import 'package:flutter/services.dart';
import 'local_database_service.dart';

class DataLoader {
  /// Đọc file JSON và lưu dữ liệu vào SQLite
  static Future<void> loadVocabularyFromJson() async {
    final jsonString = await rootBundle.loadString('assets/data/vocabulary.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    for (var entry in data.entries) {
      final topicKey = entry.key;
      final topicData = entry.value as Map<String, dynamic>;

      // Lưu chủ đề
      await LocalDatabaseService.insertTopic({
        'topic': topicKey,
        'topic_index': topicData['index'] ?? 0,
        'name': topicData['name'] ?? '',
        'image': topicData['image'] ?? '',
        'length': topicData['length'] ?? 0,
        'percent': topicData['percent'] ?? 0,
      });

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
      }
    }
  }
}
