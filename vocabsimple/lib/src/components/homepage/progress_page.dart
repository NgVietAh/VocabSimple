import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/topic_voca.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with AutomaticKeepAliveClientMixin {
  List<TopicVoca> topics = [];
  bool isLoading = true;
  int totalWords = 0;
  int totalLearned = 0;
  double overallProgress = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadProgressData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data mỗi khi trang được hiển thị
    if (mounted) {
      loadProgressData();
    }
  }

  Future<void> loadProgressData() async {
    final rawTopics = await LocalDatabaseService.getTopics();
    final topicList = rawTopics.map((e) => TopicVoca.fromMap(e['topic'], e)).toList();

    int totalW = 0;
    int totalL = 0;

    for (var topic in topicList) {
      final learnedCount = await LocalDatabaseService.countLearnedWords(topic.topic);
      totalW += topic.length;
      totalL += learnedCount;
    }

    setState(() {
      topics = topicList;
      totalWords = totalW;
      totalLearned = totalL;
      overallProgress = totalW > 0 ? (totalL / totalW) : 0.0;
      isLoading = false;
    });
  }

  Widget buildTopicProgressCard(TopicVoca topic) {
    final progress = topic.percent / 100.0;
    final Color progressColor = progress == 0
        ? Colors.grey[400]!
        : progress < 0.5
            ? Colors.orange[600]!
            : progress < 1.0
                ? Colors.blue[600]!
                : Colors.green[600]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    topic.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${topic.length} từ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge % với background màu đậm
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${topic.percent}%',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshProgress() async {
    setState(() {
      isLoading = true;
    });
    await loadProgressData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshProgress,
                child: Column(
                children: [
                  // Header with overall progress
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
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
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: overallProgress,
                                strokeWidth: 12,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(overallProgress * 100).round()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '$totalLearned/$totalWords từ',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          overallProgress == 0
                              ? 'Bắt đầu học ngay nào! 📚'
                              : overallProgress < 0.5
                                  ? 'Đang tiến bộ tốt! 💪'
                                  : overallProgress < 1.0
                                      ? 'Sắp hoàn thành rồi! 🚀'
                                      : 'Xuất sắc! Bạn đã học hết! 🎉',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          'Chi tiết theo chủ đề',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Topic list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: topics.length,
                      itemBuilder: (context, index) => buildTopicProgressCard(topics[index]),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

