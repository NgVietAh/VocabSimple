class Quiz {
  String question;
  String correctAnswer;
  List<String> options;
  String? userAnswer;
  String type; // 'multiple_choice', 'fill_blank'
  String? hint;

  Quiz({
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.userAnswer,
    required this.type,
    this.hint,
  });

  bool get isCorrect => userAnswer != null && userAnswer == correctAnswer;
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

