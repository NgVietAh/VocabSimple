import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/services/progress_service.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final ProgressService _progressService = ProgressService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProgressData();
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
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

                    const SizedBox(height: 24),

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
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                                      topic['image'] as String? ?? 'assets/images/vocabulary.png',
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

                    const SizedBox(height: 32),
                  ],
                ),
              ),
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