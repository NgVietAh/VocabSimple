class Quiz {
  String question;
  String correctAnswer;
  List<String> options;
  String? userAnswer;
  String
  type; // 'multiple_choice', 'fill_blank', 'grammar_structure', 'grammar_sentence'
  String? hint;
  String? grammarId; // ID của ngữ pháp (nếu là câu hỏi ngữ pháp)
  String? category; // 'vocabulary' hoặc 'grammar'

  Quiz({
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.userAnswer,
    required this.type,
    this.hint,
    this.grammarId,
    this.category = 'vocabulary',
  });

  bool get isCorrect {
    if (userAnswer == null) return false;

    // So sánh không phân biệt hoa thường và loại bỏ khoảng trắng thừa
    final trimmedUserAnswer = userAnswer!.trim().toLowerCase();
    final trimmedCorrectAnswer = correctAnswer.trim().toLowerCase();

    return trimmedUserAnswer == trimmedCorrectAnswer;
  }
}

class TestResult {
  int totalQuestions;
  int correctAnswers;
  int wrongAnswers;
  int skippedAnswers;
  double score;
  Duration timeTaken;

  TestResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.score,
    required this.timeTaken,
  });

  String get grade {
    if (score >= 90) return 'Xuất sắc';
    if (score >= 80) return 'Tốt';
    if (score >= 70) return 'Khá';
    if (score >= 60) return 'Trung bình';
    return 'Cần cố gắng';
  }
}
