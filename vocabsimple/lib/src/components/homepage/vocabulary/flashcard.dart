import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/services/local_database_service.dart';

class FlashcardPage extends StatefulWidget {
  final String topic;
  final String name;

  const FlashcardPage({super.key, required this.topic, required this.name});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final List<Map<String, dynamic>> words = [];
  final FlutterTts flutterTts = FlutterTts();
  final PageController _pageController = PageController();
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadWordsFromSQLite();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void goToPreviousWord() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToNextWord() {
    if (currentIndex < words.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> loadWordsFromSQLite() async {
    final rawWords = await LocalDatabaseService.getWordsByTopic(widget.topic);
    setState(() {
      words.addAll(rawWords);
      isLoading = false;
    });
  }

  // Đếm số từ đã học
  int _countLearnedWords() {
    return words.where((word) => word['isLearned'] == 1).length;
  }

  // Tính phần trăm đã học
  int _getLearnedPercent() {
    if (words.isEmpty) return 0;
    return ((_countLearnedWords() / words.length) * 100).round();
  }

  // Màu sắc theo tiến độ
  Color _getProgressColor() {
    final percent = _getLearnedPercent();
    if (percent == 0) return Colors.grey;
    if (percent < 50) return Colors.orange;
    if (percent < 100) return Colors.blue;
    return Colors.green;
  }

  Future<void> markWordAsLearned(Map<String, dynamic> word) async {
    if (word['isLearned'] == 1) return; // Đã học rồi

    // Cập nhật trong database
    await LocalDatabaseService.markWordAsLearned(word['name']);

    // Cập nhật trong danh sách local
    setState(() {
      word['isLearned'] = 1;
    });

    // Tính lại phần trăm đã học
    final learnedCount = await LocalDatabaseService.countLearnedWords(widget.topic);
    final percent = ((learnedCount / words.length) * 100).round();
    await LocalDatabaseService.updateTopicPercent(widget.topic, percent);

    print('📊 Cập nhật tiến độ: ${widget.topic} - $learnedCount/${words.length} từ = $percent%');

    // Hiển thị thông báo
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Đã học "${word['name']}" - Tiến độ: $percent%',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget buildCard(Map<String, dynamic> word) {
    final isLearned = word['isLearned'] == 1;
    
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLearned 
                ? [Colors.green[300]!, Colors.green[500]!]
                : [Colors.blue[300]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isLearned ? Colors.green : Colors.blue).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Learned badge
            if (isLearned)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Đã học',
                        style: GoogleFonts.inter(
                          color: Colors.green[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    word['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Nhấn để xem nghĩa',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      back: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLearned 
                ? [Colors.green[300]!, Colors.green[500]!]
                : [Colors.purple[300]!, Colors.purple[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isLearned ? Colors.green : Colors.purple).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word['translate'],
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '/${word['phonetic']}/',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              
              // Phát âm button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isLearned ? Colors.green[700] : Colors.purple[700],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.volume_up),
                label: Text(
                  "Phát âm",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => flutterTts.speak(word['name']),
              ),
              
              const SizedBox(height: 12),
              
              // Đã học button
              if (!isLearned)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple[700],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    "Đã học",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => markWordAsLearned(word),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Đã hoàn thành",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.name,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress indicator với thanh bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    children: [
                      // Số từ hiện tại
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Từ ${currentIndex + 1} / ${words.length}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getProgressColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_getLearnedPercent()}%',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _getLearnedPercent() / 100,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Thông tin đã học
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Đã học: ${_countLearnedWords()} / ${words.length} từ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _getProgressColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_countLearnedWords() < words.length)
                            Text(
                              'Còn lại: ${words.length - _countLearnedWords()} từ',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Flashcards
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: words.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: buildCard(words[index]),
                    ),
                  ),
                ),
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      ElevatedButton.icon(
                        onPressed: currentIndex > 0 ? goToPreviousWord : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentIndex > 0 ? Colors.blue[600] : Colors.grey[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: currentIndex > 0 ? 4 : 0,
                        ),
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        label: Text(
                          'Trước',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      // Dots indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          words.length > 10 ? 5 : words.length,
                          (index) {
                            if (words.length > 10) {
                              // Show simplified dots for more than 10 words
                              if (index == 2) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Icon(
                                    Icons.more_horiz,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }
                            // Show all dots for 10 or fewer words
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: currentIndex == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: currentIndex == index
                                    ? Colors.blue[700]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Next button
                      ElevatedButton.icon(
                        onPressed: currentIndex < words.length - 1 ? goToNextWord : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentIndex < words.length - 1 
                              ? Colors.blue[600] 
                              : Colors.grey[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: currentIndex < words.length - 1 ? 4 : 0,
                        ),
                        icon: Text(
                          'Sau',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        label: const Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
