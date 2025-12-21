import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/quiz.dart';
import 'package:vocabsimple/src/services/quiz_service.dart';
import 'package:vocabsimple/src/components/test/test_result_page.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';
import 'package:vocabsimple/src/services/progress_service.dart';

class GrammarTestPage extends StatefulWidget {
  final int questionCount;

  const GrammarTestPage({super.key, required this.questionCount});

  @override
  State<GrammarTestPage> createState() => _GrammarTestPageState();
}

class _GrammarTestPageState extends State<GrammarTestPage> {
  List<Quiz> quizzes = [];
  bool isLoading = true;
  int currentQuestionIndex = 0;
  TextEditingController fillBlankController = TextEditingController();
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    loadGrammarQuizzes();
    startTime = DateTime.now();
  }

  @override
  void dispose() {
    fillBlankController.dispose();
    super.dispose();
  }

  Future<void> loadGrammarQuizzes() async {
    final loadedQuizzes = await QuizService.generateGrammarQuiz(
      count: widget.questionCount,
    );

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
                'Bạn chưa học ngữ pháp nào để làm bài test này',
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

    final totalQuestions = quizzes.length;
    final score = (correct / totalQuestions * 100);

    // Lưu kết quả test vào database
    await LocalDatabaseService.saveTestResult(
      testName: 'Test ngữ pháp',
      totalQuestions: totalQuestions,
      correctAnswers: correct,
      wrongAnswers: wrong,
      skippedAnswers: skipped,
      score: score,
      timeTakenSeconds: timeTaken.inSeconds,
    );

    // Lưu thống kê test ngữ pháp riêng
    await ProgressService.saveGrammarTestResult(score);

    final result = TestResult(
      totalQuestions: totalQuestions,
      correctAnswers: correct,
      wrongAnswers: wrong,
      skippedAnswers: skipped,
      score: score,
      timeTaken: timeTaken,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TestResultPage(result: result, quizzes: quizzes),
        ),
      );
    }
  }

  Widget buildMultipleChoiceQuestion(Quiz quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grammar Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book, size: 16, color: Colors.purple[700]),
              const SizedBox(width: 6),
              Text(
                'Ngữ pháp',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
        ),

        // Câu hỏi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple[200]!),
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

        // Hint
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
                Expanded(
                  child: Text(
                    quiz.hint!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Đáp án
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
                color: isSelected ? Colors.purple[100] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.purple[700]! : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple[700] : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
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
        // Grammar Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book, size: 16, color: Colors.purple[700]),
              const SizedBox(width: 6),
              Text(
                'Ngữ pháp',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
        ),

        // Câu hỏi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple[200]!),
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
            hintText: 'Nhập đáp án...',
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
              borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
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
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.purple[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nhập đáp án (không phân biệt hoa thường)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.purple[700],
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
            icon: Icon(Icons.arrow_back_ios, color: Colors.purple[700]),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Test ngữ pháp',
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
            icon: Icon(Icons.arrow_back_ios, color: Colors.purple[700]),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Không có câu hỏi nào')),
      );
    }

    final currentQuiz = quizzes[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple[700]),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Thoát bài test?',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Tiến trình của bạn sẽ không được lưu',
                  style: GoogleFonts.inter(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Ở lại', style: GoogleFonts.inter()),
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
          'Test ngữ pháp',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${currentQuestionIndex + 1}/${quizzes.length}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / quizzes.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
            minHeight: 6,
          ),

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
                  offset: const Offset(0, -5),
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
                        side: BorderSide(color: Colors.purple[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Câu trước',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[700],
                        ),
                      ),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: currentQuiz.userAnswer != null
                        ? nextQuestion
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex == quizzes.length - 1
                          ? 'Hoàn thành'
                          : 'Tiếp theo',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
