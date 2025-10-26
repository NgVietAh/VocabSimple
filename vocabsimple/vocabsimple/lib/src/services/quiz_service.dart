import 'dart:math';
import 'package:vocabsimple/src/components/model/quiz.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';

class QuizService {
  /// Tạo quiz từ các từ đã học trong một chủ đề
  static Future<List<Quiz>> generateQuizFromTopic(String topic, {int count = 10}) async {
    final words = await LocalDatabaseService.getWordsByTopic(topic);
    
    // Lọc các từ đã học
    final learnedWords = words.where((w) => w['isLearned'] == 1).toList();
    
    if (learnedWords.isEmpty) {
      print('⚠️ Chưa có từ nào được học trong chủ đề "$topic"');
      return [];
    }

    // Shuffle và lấy số lượng cần
    learnedWords.shuffle();
    final selectedWords = learnedWords.take(min(count, learnedWords.length)).toList();

    List<Quiz> quizzes = [];

    for (var word in selectedWords) {
      // Random loại câu hỏi: 50% multiple choice, 50% fill blank
      final random = Random().nextDouble();
      
      if (random < 0.5) {
        // Multiple choice: Cho nghĩa tiếng Việt, chọn từ tiếng Anh
        quizzes.add(_createMultipleChoiceQuiz(word, words));
      } else {
        // Fill blank: Điền từ tiếng Anh
        quizzes.add(_createFillBlankQuiz(word));
      }
    }

    quizzes.shuffle();
    print('✅ Đã tạo ${quizzes.length} câu hỏi từ chủ đề "$topic"');
    return quizzes;
  }

  /// Multiple choice: Cho nghĩa tiếng Việt, chọn từ tiếng Anh đúng
  static Quiz _createMultipleChoiceQuiz(Map<String, dynamic> word, List<Map<String, dynamic>> allWords) {
    final correctAnswer = word['name'] as String;
    final question = word['translate'] as String;

    // Lấy 3 từ sai khác
    final wrongWords = allWords
        .where((w) => w['name'] != correctAnswer)
        .toList()
      ..shuffle();

    final options = [
      correctAnswer,
      ...wrongWords.take(3).map((w) => w['name'] as String),
    ];

    options.shuffle();

    return Quiz(
      question: 'Từ nào có nghĩa là "$question"?',
      correctAnswer: correctAnswer,
      options: options,
      type: 'multiple_choice',
      hint: word['phonetic'],
    );
  }

  /// Fill blank: Điền từ tiếng Anh từ nghĩa tiếng Việt
  static Quiz _createFillBlankQuiz(Map<String, dynamic> word) {
    final correctAnswer = word['name'] as String;
    final question = word['translate'] as String;

    return Quiz(
      question: 'Điền từ tiếng Anh có nghĩa là "$question"',
      correctAnswer: correctAnswer.toLowerCase(),
      options: [], // Không có options cho fill blank
      type: 'fill_blank',
      hint: 'Phiên âm: ${word['phonetic']}',
    );
  }

  /// Tạo quiz từ nhiều chủ đề (các từ đã học từ tất cả chủ đề)
  static Future<List<Quiz>> generateMixedQuiz({int count = 15}) async {
    final topics = await LocalDatabaseService.getTopics();
    List<Map<String, dynamic>> allLearnedWords = [];

    for (var topic in topics) {
      final words = await LocalDatabaseService.getWordsByTopic(topic['topic']);
      final learnedWords = words.where((w) => w['isLearned'] == 1).toList();
      allLearnedWords.addAll(learnedWords);
    }

    if (allLearnedWords.isEmpty) {
      print('⚠️ Chưa học từ nào');
      return [];
    }

    allLearnedWords.shuffle();
    final selectedWords = allLearnedWords.take(min(count, allLearnedWords.length)).toList();

    List<Quiz> quizzes = [];

    for (var word in selectedWords) {
      final random = Random().nextDouble();
      
      if (random < 0.5) {
        quizzes.add(_createMultipleChoiceQuiz(word, allLearnedWords));
      } else {
        quizzes.add(_createFillBlankQuiz(word));
      }
    }

    quizzes.shuffle();
    print('✅ Đã tạo ${quizzes.length} câu hỏi tổng hợp');
    return quizzes;
  }
}

