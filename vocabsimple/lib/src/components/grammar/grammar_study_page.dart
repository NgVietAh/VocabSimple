import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/grammar.dart';
import 'dart:math';

class GrammarStudyPage extends StatefulWidget {
  final Grammar grammar;

  const GrammarStudyPage({super.key, required this.grammar});

  @override
  State<GrammarStudyPage> createState() => _GrammarStudyPageState();
}

class _GrammarStudyPageState extends State<GrammarStudyPage> {
  bool _showDescription = false;
  bool _showStructure = false;
  bool _showExamples = false;
  bool _showPractice = false;

  // Quiz state
  List<String> _quizParts = [];
  List<String> _selectedParts = [];
  String? _correctAnswer;
  bool? _isCorrect;
  int _score = 0;
  int _attempts = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  void _generateQuiz() {
    // Tạo câu hỏi từ structure
    if (widget.grammar.structure.isNotEmpty) {
      final structureEntry = widget.grammar.structure.entries.first;
      _correctAnswer = structureEntry.value;

      // Tách các phần của công thức
      List<String> parts = _correctAnswer!.split(RegExp(r'\s+'));

      // Xáo trộn các phần
      _quizParts = List.from(parts)..shuffle(Random());
      _selectedParts = [];
    }
  }

  void _checkAnswer() {
    setState(() {
      _attempts++;
      String userAnswer = _selectedParts.join(' ');
      _isCorrect = userAnswer == _correctAnswer;

      if (_isCorrect!) {
        _score++;
        if (_attempts >= 3 && _score >= 2) {
          _isCompleted = true;
          _showCompletionDialog();
        }
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _selectedParts = [];
      _isCorrect = null;
    });
  }

  void _nextQuestion() {
    _generateQuiz();
    setState(() {
      _selectedParts = [];
      _isCorrect = null;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green[600], size: 32),
            const SizedBox(width: 12),
            Text(
              'Hoàn thành!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        content: Text(
          'Chúc mừng! Bạn đã hoàn thành bài học ngữ pháp này.\n\nĐiểm số: $_score/$_attempts',
          style: GoogleFonts.inter(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return true để báo đã hoàn thành
            },
            child: Text(
              'Hoàn tất',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Học: ${widget.grammar.title}',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.purple[600]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiến độ',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$_score/$_attempts câu đúng',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_isCompleted)
                    Icon(Icons.check_circle, color: Colors.white, size: 48),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mô tả
            _buildCollapsibleSection(
              title: 'Mô tả',
              icon: Icons.description_outlined,
              isExpanded: _showDescription,
              onTap: () => setState(() => _showDescription = !_showDescription),
              child: Text(
                widget.grammar.description,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Công thức
            _buildCollapsibleSection(
              title: 'Công thức',
              icon: Icons.format_list_bulleted,
              isExpanded: _showStructure,
              onTap: () => setState(() => _showStructure = !_showStructure),
              child: Column(
                children: widget.grammar.structure.entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.key.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.purple[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          e.value,
                          style: GoogleFonts.robotoMono(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Ví dụ
            _buildCollapsibleSection(
              title: 'Ví dụ',
              icon: Icons.lightbulb_outline,
              isExpanded: _showExamples,
              onTap: () => setState(() => _showExamples = !_showExamples),
              child: Column(
                children: widget.grammar.examples.map((ex) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.en,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ex.vi,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Thực hành
            _buildCollapsibleSection(
              title: 'Thực hành',
              icon: Icons.quiz,
              isExpanded: _showPractice,
              onTap: () => setState(() => _showPractice = !_showPractice),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sắp xếp các phần sau để tạo thành công thức đúng:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Selected parts area
                  Container(
                    constraints: const BoxConstraints(minHeight: 60),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCorrect == null
                            ? Colors.grey[300]!
                            : _isCorrect!
                            ? Colors.green
                            : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedParts.isEmpty
                          ? [
                              Text(
                                'Chọn các phần từ dưới lên...',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ]
                          : _selectedParts.map((part) {
                              return GestureDetector(
                                onTap: () {
                                  if (_isCorrect == null) {
                                    setState(() {
                                      _selectedParts.remove(part);
                                      _quizParts.add(part);
                                    });
                                  }
                                },
                                child: Chip(
                                  label: Text(part),
                                  backgroundColor: Colors.purple[100],
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: _isCorrect == null
                                      ? () {
                                          setState(() {
                                            _selectedParts.remove(part);
                                            _quizParts.add(part);
                                          });
                                        }
                                      : null,
                                ),
                              );
                            }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Available parts
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quizParts.map((part) {
                      return GestureDetector(
                        onTap: _isCorrect == null
                            ? () {
                                setState(() {
                                  _quizParts.remove(part);
                                  _selectedParts.add(part);
                                });
                              }
                            : null,
                        child: Chip(
                          label: Text(part),
                          backgroundColor: Colors.blue[50],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Feedback
                  if (_isCorrect != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isCorrect! ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isCorrect! ? Icons.check_circle : Icons.cancel,
                            color: _isCorrect! ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isCorrect!
                                  ? 'Chính xác! Bạn đã ghép đúng công thức.'
                                  : 'Chưa đúng. Hãy thử lại!',
                              style: GoogleFonts.inter(
                                color: _isCorrect!
                                    ? Colors.green[900]
                                    : Colors.red[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _selectedParts.isEmpty || _isCorrect != null
                              ? null
                              : _checkAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Kiểm tra',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_isCorrect != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCorrect! ? _nextQuestion : _resetQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isCorrect! ? 'Tiếp theo' : 'Thử lại',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: Colors.purple[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
