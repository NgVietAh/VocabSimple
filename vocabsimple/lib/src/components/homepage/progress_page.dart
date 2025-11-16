import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/services/progress_service.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  final ProgressService _progressService = ProgressService();
  late TabController _tabController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadProgressData() async {
    setState(() {
      isLoading = true;
    });

    await _progressService.loadAllProgress();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header với TabBar
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Text(
                          'Tiến trình học',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: loadProgressData,
                          icon: Icon(Icons.refresh, color: Colors.blue[700]),
                          tooltip: 'Làm mới',
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue[700],
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Colors.blue[700],
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Từ vựng'),
                      Tab(text: 'Ngữ pháp'),
                      Tab(text: 'Kiểm tra'),
                    ],
                  ),
                ],
              ),
            ),

            // TabBarView
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildVocabularyTab(),
                        _buildGrammarTab(),
                        _buildTestTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab Từ vựng
  Widget _buildVocabularyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiến độ tổng quát
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Tiến độ tổng quát',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Circular progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: _progressService.overallProgress / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${_progressService.overallProgress}%',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${_progressService.learnedWords}/${_progressService.totalWords} từ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Motivational message
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getMotivationalMessage(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getMotivationalEmoji(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Chi tiết theo chủ đề
          Text(
            'Chi tiết theo chủ đề',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // List of topics
          FutureBuilder<List<Map<String, dynamic>>>(
            future: LocalDatabaseService.getTopics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có dữ liệu',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.map((topic) {
                  final topicName = topic['name'] as String;
                  final topicKey = topic['topic'] as String;
                  final progress = _progressService.getTopicProgress(topicKey);
                  final totalWords = topic['length'] as int? ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Topic image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            topic['image'] as String? ??
                                'assets/images/vocabulary.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Topic info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topicName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalWords từ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Progress badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getProgressColor(progress),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$progress%',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Tab Ngữ pháp
  Widget _buildGrammarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coming soon card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[600]!, Colors.purple[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.book_outlined, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Tiến độ Ngữ pháp',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Theo dõi quá trình học ngữ pháp của bạn',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '0/10 bài học',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Danh sách bài học',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildGrammarPlaceholder(),
        ],
      ),
    );
  }

  // Tab Kiểm tra
  Widget _buildTestTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: LocalDatabaseService.getTestHistory(),
      builder: (context, snapshot) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test score card
              FutureBuilder<Map<String, dynamic>>(
                future: _getTestStats(),
                builder: (context, statsSnapshot) {
                  final totalTests = statsSnapshot.data?['total'] ?? 0;
                  final avgScore = statsSnapshot.data?['average'] ?? 0.0;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange[600]!, Colors.orange[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lịch sử kiểm tra',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Điểm trung bình: ${avgScore.toStringAsFixed(1)}%',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '$totalTests bài đã làm',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Lịch sử bài test',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (!snapshot.hasData || snapshot.data!.isEmpty)
                _buildTestPlaceholder()
              else
                Column(
                  children: snapshot.data!.map((test) {
                    final score = (test['score'] as num).toDouble();
                    final completedAt = DateTime.parse(
                      test['completed_at'] as String,
                    );
                    final timeTaken = test['time_taken'] as int;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      test['test_name'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(completedAt),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(score),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${score.toStringAsFixed(0)}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildTestStat(
                                Icons.check_circle,
                                '${test['correct_answers']}',
                                Colors.green,
                              ),
                              const SizedBox(width: 16),
                              _buildTestStat(
                                Icons.cancel,
                                '${test['wrong_answers']}',
                                Colors.red,
                              ),
                              const SizedBox(width: 16),
                              _buildTestStat(
                                Icons.help_outline,
                                '${test['skipped_answers']}',
                                Colors.grey,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(timeTaken),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getTestStats() async {
    final total = await LocalDatabaseService.countCompletedTests();
    final average = await LocalDatabaseService.getAverageScore();
    return {'total': total, 'average': average};
  }

  Widget _buildTestStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green[600]!;
    if (score >= 80) return Colors.blue[600]!;
    if (score >= 70) return Colors.orange[600]!;
    if (score >= 60) return Colors.amber[600]!;
    return Colors.red[600]!;
  }

  Widget _buildGrammarPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu ngữ pháp',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hoàn thành các bài học ngữ pháp để xem tiến độ',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTestPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có bài kiểm tra nào',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Làm các bài kiểm tra để xem điểm số ở đây',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress == 0) return Colors.grey[400]!;
    if (progress < 30) return Colors.orange[600]!;
    if (progress < 70) return Colors.blue[600]!;
    return Colors.green[600]!;
  }

  String _getMotivationalMessage() {
    final progress = _progressService.overallProgress;
    if (progress == 0) return 'Bắt đầu hành trình học tập';
    if (progress < 25) return 'Đang tiến bộ tốt';
    if (progress < 50) return 'Tiến bộ ổn định';
    if (progress < 75) return 'Gần hoàn thành';
    if (progress < 100) return 'Sắp hoàn thành';
    return 'Hoàn thành xuất sắc';
  }

  String _getMotivationalEmoji() {
    final progress = _progressService.overallProgress;
    if (progress == 0) return '🚀';
    if (progress < 25) return '💪';
    if (progress < 50) return '🔥';
    if (progress < 75) return '⭐';
    if (progress < 100) return '🎯';
    return '🏆';
  }
}
