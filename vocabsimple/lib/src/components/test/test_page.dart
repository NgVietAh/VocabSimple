import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/quiz.dart';
import 'package:vocabsimple/src/services/quiz_service.dart';
import 'package:vocabsimple/src/components/test/test_result_page.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';

class TestPage extends StatefulWidget {
  final String testTitle;
  final String? topic;
  final int questionCount;

  const TestPage({
    super.key,
    required this.testTitle,
    this.topic,
    required this.questionCount,
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<Quiz> quizzes = [];
  bool isLoading = true;
  int currentQuestionIndex = 0;
  TextEditingController fillBlankController = TextEditingController();
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    loadQuizzes();
    startTime = DateTime.now();
  }

  @override
  void dispose() {
    fillBlankController.dispose();
    super.dispose();
  }

  Future<void> loadQuizzes() async {
    List<Quiz> loadedQuizzes;

    if (widget.topic == null) {
      // Test tổng hợp - lấy từ tất cả chủ đề
      loadedQuizzes = await QuizService.generateMixedQuiz(
        count: widget.questionCount,
      );
    } else {
      // Test theo chủ đề
      loadedQuizzes = await QuizService.generateQuizFromTopic(
        widget.topic!,
        count: widget.questionCount,
      );
    }

    setState(() {
      quizzes = loadedQuizzes;
      isLoading = false;
    });

    // Nếu không có câu hỏi nào
    if (quizzes.isEmpty) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bạn chưa học từ nào để làm bài test này',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        }
      });
    }
  }

  void submitAnswer(String answer) {
    setState(() {
      quizzes[currentQuestionIndex].userAnswer = answer;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < quizzes.length - 1) {
      setState(() {
        currentQuestionIndex++;
        fillBlankController.clear();
      });
    } else {
      // Hoàn thành bài test
      finishTest();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        fillBlankController.clear();
      });
    }
  }

  void finishTest() async {
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(startTime!);

    int correct = quizzes.where((q) => q.isCorrect).length;
    int wrong = quizzes
        .where((q) => q.userAnswer != null && !q.isCorrect)
        .length;
    int skipped = quizzes.where((q) => q.userAnswer == null).length;
    double score = (correct / quizzes.length) * 100;

    final result = TestResult(
      totalQuestions: quizzes.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      skippedAnswers: skipped,
      score: score,
      timeTaken: timeTaken,
    );

    // Lưu kết quả vào database
    await LocalDatabaseService.saveTestResult(
      testName: widget.testTitle,
      totalQuestions: quizzes.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      skippedAnswers: skipped,
      score: score,
      timeTakenSeconds: timeTaken.inSeconds,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultPage(result: result, quizzes: quizzes),
      ),
    );
  }

  Widget buildMultipleChoiceQuestion(Quiz quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Câu hỏi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            quiz.question,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Hint (nếu có)
        if (quiz.hint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  quiz.hint!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // Các đáp án
        ...quiz.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = quiz.userAnswer == option;

          return GestureDetector(
            onTap: () => submitAnswer(option),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[100] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[700] : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget buildFillBlankQuestion(Quiz quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Câu hỏi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz.question,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (quiz.hint != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange[700],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quiz.hint!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Ô nhập đáp án
        TextField(
          controller: fillBlankController,
          onChanged: (value) {
            submitAnswer(value.toLowerCase().trim());
          },
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Nhập từ tiếng Anh...',
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 16),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Gợi ý
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nhập từ tiếng Anh (không phân biệt hoa thường)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.green[700]),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.testTitle,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.green[700]),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.testTitle,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuiz = quizzes[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.green[700]),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Thoát bài test?',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Bạn có chắc muốn thoát? Kết quả sẽ không được lưu.',
                  style: GoogleFonts.inter(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Hủy', style: GoogleFonts.inter()),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Thoát',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          widget.testTitle,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Câu ${currentQuestionIndex + 1}/${quizzes.length}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${((currentQuestionIndex + 1) / quizzes.length * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / quizzes.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green[600]!,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Nội dung câu hỏi
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: currentQuiz.type == 'multiple_choice'
                  ? buildMultipleChoiceQuestion(currentQuiz)
                  : buildFillBlankQuestion(currentQuiz),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Câu trước',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: currentQuestionIndex > 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: currentQuiz.userAnswer != null
                        ? nextQuestion
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[600],
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      currentQuestionIndex < quizzes.length - 1
                          ? 'Tiếp theo'
                          : 'Hoàn thành',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
