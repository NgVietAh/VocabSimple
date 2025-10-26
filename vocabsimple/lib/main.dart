import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vocabsimple/src/components/user/PageLogin.dart';
import 'package:vocabsimple/src/components/homepage/vocabulary/flashcard.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';
import 'package:vocabsimple/src/services/data_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD
  
  print('🚀 Khởi động VocabSimple...');
  
  await Firebase.initializeApp(); // Khởi tạo Firebase
  print('✓ Firebase OK');
  
  await LocalDatabaseService.init(); // Khởi tạo SQLite
  print('✓ SQLite OK');
  
  await DataLoader.loadVocabularyFromJson(); // Đổ dữ liệu từ JSON vào SQLite nếu cần
  print('✓ Dữ liệu OK');
  
  print('✅ App sẵn sàng!\n');
=======
  await Firebase.initializeApp(); // Khởi tạo Firebase
  await LocalDatabaseService.init(); // Khởi tạo SQLite
  // await DataLoader.loadVocabularyFromJson(); // Đổ dữ liệu từ JSON vào SQLite nếu cần
>>>>>>> a84f2bf4f1df15c3e664fc13c72585042fc9c3ff

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const PageLogin(),
    onGenerateRoute: (settings) {
      if (settings.name == '/flashcard') {
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => FlashcardPage(
            topic: args['topic'],
            name: args['name'],
          ),
        );
      }
      return null;
    },
  ));
}
