import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';
import 'package:vocabsimple/src/components/test/test_page.dart';

class TestListPage extends StatefulWidget {
  const TestListPage({super.key});

  @override
  State<TestListPage> createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  List<Map<String, dynamic>> topics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTopics();
  }

  Future<void> loadTopics() async {
    final data = await LocalDatabaseService.getTopics();
    setState(() {
      topics = data;
      isLoading = false;
    });
  }

  Widget buildTestCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.green[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Làm bài kiểm tra',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Test
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Bài test nhanh',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    buildTestCard(
                      title: 'Test tổng hợp',
                      description: 'Kiểm tra tất cả từ đã học',
                      icon: Icons.quiz_rounded,
                      color: Colors.green[600]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestPage(
                              testTitle: 'Test tổng hợp',
                              topic: null, // null = mixed test
                              questionCount: 15,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Test by Topic
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Test theo chủ đề',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    ...topics.map((topic) {
                      final percent = topic['percent'] ?? 0;
                      
                      return buildTestCard(
                        title: topic['name'],
                        description: percent > 0
                            ? 'Đã học $percent% - ${topic['length']} từ'
                            : 'Chưa học chủ đề này',
                        icon: Icons.topic_rounded,
                        color: percent > 0 ? Colors.blue[600]! : Colors.grey[400]!,
                        onTap: percent > 0
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TestPage(
                                      testTitle: 'Test ${topic['name']}',
                                      topic: topic['topic'],
                                      questionCount: 10,
                                    ),
                                  ),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Bạn chưa học từ nào trong chủ đề này'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                      );
                    }).toList(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

