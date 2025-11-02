import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vocabsimple/src/components/user/PageLogin.dart';
import 'package:vocabsimple/src/components/homepage/vocabulary/flashcard.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';
import 'package:vocabsimple/src/services/data_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print(' ...');

  await Firebase.initializeApp(); // Khởi tạo Firebase
  print(' OK');

  await LocalDatabaseService.init(); // Khởi tạo SQLite
  print(' OK');

  await DataLoader.loadVocabularyFromJson(); // Đổ dữ liệu từ JSON vào SQLite nếu cần
  print(' OK');

  // Kiểm tra số chủ đề trong database
  final topics = await LocalDatabaseService.getTopics();
  print(' Có ${topics.length} chủ đề ');
  for (var topic in topics) {
    print('  - ${topic['name']} (${topic['topic']})');
  }

  print('sẵn sàng!\n');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PageLogin(),
      onGenerateRoute: (settings) {
        if (settings.name == '/flashcard') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                FlashcardPage(topic: args['topic'], name: args['name']),
          );
        }
        return null;
      },
    ),
  );
}
