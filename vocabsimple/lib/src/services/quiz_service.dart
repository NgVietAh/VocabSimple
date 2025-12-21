import 'dart:math';
import 'package:vocabsimple/src/components/model/quiz.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';
import 'package:vocabsimple/src/services/grammar_service.dart';
import 'package:vocabsimple/src/services/progress_service.dart';

class QuizService {
  /// Tạo quiz từ các từ đã học trong một chủ đề
  static Future<List<Quiz>> generateQuizFromTopic(
    String topic, {
    int count = 10,
  }) async {
    final words = await LocalDatabaseService.getWordsByTopic(topic);

    // Lọc các từ đã học
    final learnedWords = words.where((w) => w['isLearned'] == 1).toList();

    if (learnedWords.isEmpty) {
      return [];
    }

    // Shuffle và lấy số lượng cần
    learnedWords.shuffle();
    final selectedWords = learnedWords
        .take(min(count, learnedWords.length))
        .toList();

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
    return quizzes;
  }

  /// Multiple choice: Cho nghĩa tiếng Việt, chọn từ tiếng Anh đúng
  static Quiz _createMultipleChoiceQuiz(
    Map<String, dynamic> word,
    List<Map<String, dynamic>> allWords,
  ) {
    final correctAnswer = word['name'] as String;
    final question = word['translate'] as String;

    // Lấy 3 từ sai khác
    final wrongWords =
        allWords.where((w) => w['name'] != correctAnswer).toList()..shuffle();

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
      category: 'vocabulary',
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
      category: 'vocabulary',
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
      return [];
    }

    allLearnedWords.shuffle();

    // Chia tỷ lệ: 60% từ vựng, 40% ngữ pháp
    final vocabCount = (count * 0.6).round();
    final grammarCount = count - vocabCount;

    final selectedWords = allLearnedWords
        .take(min(vocabCount, allLearnedWords.length))
        .toList();

    List<Quiz> quizzes = [];

    // Tạo câu hỏi từ vựng
    for (var word in selectedWords) {
      final random = Random().nextDouble();

      if (random < 0.5) {
        quizzes.add(_createMultipleChoiceQuiz(word, allLearnedWords));
      } else {
        quizzes.add(_createFillBlankQuiz(word));
      }
    }

    // Tạo câu hỏi ngữ pháp
    final grammarQuizzes = await generateGrammarQuiz(count: grammarCount);
    quizzes.addAll(grammarQuizzes);

    quizzes.shuffle();
    return quizzes;
  }

  /// ==================== GRAMMAR QUIZ METHODS ====================

  /// Tạo câu hỏi ngữ pháp từ các ngữ pháp đã học
  static Future<List<Quiz>> generateGrammarQuiz({int count = 10}) async {
    try {
      // Lấy danh sách ngữ pháp đã học
      final learnedGrammarIds = await ProgressService.getLearnedGrammarIds();

      if (learnedGrammarIds.isEmpty) {
        return [];
      }

      // Load tất cả ngữ pháp
      final allGrammar = await GrammarService.loadGrammar();

      // Lọc các ngữ pháp đã học
      final learnedGrammar = allGrammar
          .where((g) => learnedGrammarIds.contains(g.id))
          .toList();

      if (learnedGrammar.isEmpty) {
        return [];
      }

      List<Quiz> quizzes = [];
      learnedGrammar.shuffle();

      final selectedGrammar = learnedGrammar
          .take(min(count, learnedGrammar.length))
          .toList();

      for (var grammar in selectedGrammar) {
        // Random loại câu hỏi
        final random = Random().nextDouble();

        if (random < 0.33 && grammar.structure.isNotEmpty) {
          // Structure multiple choice
          quizzes.add(_createGrammarStructureQuiz(grammar));
        } else if (random < 0.66 && grammar.examples.isNotEmpty) {
          // Sentence completion từ examples
          quizzes.add(_createGrammarSentenceQuiz(grammar));
        } else if (grammar.rules.isNotEmpty) {
          // Rules fill blank
          quizzes.add(_createGrammarRuleQuiz(grammar));
        }
      }

      quizzes.shuffle();
      return quizzes;
    } catch (e) {
      print('Error generating grammar quiz: $e');
      return [];
    }
  }

  /// Tạo câu hỏi multiple choice về cấu trúc ngữ pháp
  static Quiz _createGrammarStructureQuiz(grammar) {
    final structureEntries = grammar.structure.entries.toList();
    structureEntries.shuffle();

    final correctEntry = structureEntries.first;
    final correctAnswer = correctEntry.value;

    // Tạo câu hỏi
    String questionType = correctEntry.key;
    String questionTypeVi = _translateStructureType(questionType);

    final question = 'Cấu trúc ${questionTypeVi} của "${grammar.title}" là gì?';

    // Tạo các đáp án sai từ các structure khác
    List<String> wrongAnswers = structureEntries
        .where((e) => e.value != correctAnswer)
        .map((e) => e.value)
        .toList();

    // Nếu không đủ đáp án sai, tạo thêm
    while (wrongAnswers.length < 3) {
      wrongAnswers.add('S + V + O');
    }

    final options = <String>[correctAnswer, ...wrongAnswers.take(3)];
    options.shuffle();

    return Quiz(
      question: question,
      correctAnswer: correctAnswer,
      options: options,
      type: 'multiple_choice',
      hint: grammar.description,
      grammarId: grammar.id,
      category: 'grammar',
    );
  }

  /// Tạo câu hỏi hoàn thành câu từ examples
  static Quiz _createGrammarSentenceQuiz(grammar) {
    final examples = grammar.examples;
    examples.shuffle();

    final example = examples.first;
    final correctAnswer = example.en;

    // Tạo câu hỏi: cho nghĩa tiếng Việt, yêu cầu điền câu tiếng Anh
    final question = 'Hoàn thành câu: "${example.vi}"';

    // Tách câu thành các từ và ẩn một từ quan trọng
    final words = correctAnswer.split(' ');

    if (words.length >= 3) {
      // Ẩn động từ hoặc từ ở giữa
      final hiddenIndex = words.length ~/ 2;
      final hiddenWord = words[hiddenIndex].replaceAll(RegExp(r'[.,!?]'), '');

      words[hiddenIndex] = '_____';
      final questionSentence = words.join(' ');

      return Quiz(
        question: '$question\n$questionSentence',
        correctAnswer: hiddenWord.toLowerCase(),
        options: [],
        type: 'fill_blank',
        hint: 'Ngữ pháp: ${grammar.title}',
        grammarId: grammar.id,
        category: 'grammar',
      );
    } else {
      // Nếu câu quá ngắn, yêu cầu điền toàn bộ
      return Quiz(
        question: question,
        correctAnswer: correctAnswer.toLowerCase(),
        options: [],
        type: 'fill_blank',
        hint: 'Ngữ pháp: ${grammar.title}',
        grammarId: grammar.id,
        category: 'grammar',
      );
    }
  }

  /// Tạo câu hỏi về quy tắc ngữ pháp
  static Quiz _createGrammarRuleQuiz(grammar) {
    final rules = grammar.rules;
    rules.shuffle();

    final correctRule = rules.first;

    // Tạo câu hỏi
    final question = 'Điều gì đúng về "${grammar.title}"?';

    // Tạo các quy tắc sai
    List<String> wrongRules = [
      'Động từ không thay đổi với mọi ngôi',
      'Chỉ dùng trong câu phủ định',
      'Không cần trợ động từ',
    ];

    final options = <String>[correctRule, ...wrongRules.take(3)];
    options.shuffle();

    return Quiz(
      question: question,
      correctAnswer: correctRule,
      options: options,
      type: 'multiple_choice',
      hint: grammar.description,
      grammarId: grammar.id,
      category: 'grammar',
    );
  }

  /// Helper: Dịch loại cấu trúc sang tiếng Việt
  static String _translateStructureType(String type) {
    switch (type.toLowerCase()) {
      case 'affirmative':
        return 'khẳng định';
      case 'negative':
        return 'phủ định';
      case 'question':
        return 'nghi vấn';
      default:
        return type;
    }
  }
}
