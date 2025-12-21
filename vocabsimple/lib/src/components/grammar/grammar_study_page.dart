import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/grammar.dart';
import 'package:vocabsimple/src/services/grammar_service.dart';
import 'package:vocabsimple/src/services/progress_service.dart';
import 'dart:math';

enum ExerciseType { matching, arrangeWords, arrangeSentence }

class GrammarStudyPage extends StatefulWidget {
  final Grammar grammar;
  final List<Grammar>? allGrammarTopics;

  const GrammarStudyPage({
    super.key,
    required this.grammar,
    this.allGrammarTopics,
  });

  @override
  State<GrammarStudyPage> createState() => _GrammarStudyPageState();
}

class _GrammarStudyPageState extends State<GrammarStudyPage> {
  bool _showDescription = false;
  bool _showStructure = false;
  bool _showRules = false;
  bool _showExamples = false;
  bool _showPractice = false;

  // Exercise state
  ExerciseType _currentExerciseType = ExerciseType.matching;
  int _currentExerciseIndex = 0;

  // Matching exercise state
  List<String> _quizParts = [];
  List<int> _selectedPartsIndexes =
      []; // Lưu index thay vì value để tránh trùng lặp
  String? _correctAnswer;
  String? _currentStructureKey;

  // Arrange words exercise state
  List<String> _arrangeWords = []; // Các từ bị xáo trộn
  List<int> _selectedWordsIndexes = []; // Các từ đã chọn (theo index)
  String? _correctWordsSentence; // Câu đúng
  String? _arrangeWordsHint; // Gợi ý (cấu trúc ngữ pháp)

  // Arrange sentence exercise state
  List<String> _arrangeSentenceParts = []; // Các cụm từ bị xáo trộn
  List<int> _selectedSentenceIndexes = []; // Các cụm từ đã chọn (theo index)
  String? _correctSentence; // Câu đúng
  String? _arrangeSentenceHint; // Gợi ý

  // General state
  bool? _isCorrect;
  int _score = 0;
  int _attempts = 0;
  bool _isCompleted = false;
  int _currentStructureIndex = 0;

  List<Grammar>? _allGrammarTopics;

  @override
  void initState() {
    super.initState();
    _allGrammarTopics = widget.allGrammarTopics;
    _loadAllGrammarIfNeeded();
    _generateExercise();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAllGrammarIfNeeded() async {
    if (_allGrammarTopics == null) {
      _allGrammarTopics = await GrammarService.loadGrammar();
      setState(() {});
    }
  }

  void _generateExercise() {
    setState(() {
      _isCorrect = null;
      _selectedPartsIndexes = [];
      _selectedWordsIndexes = [];
      _selectedSentenceIndexes = [];

      switch (_currentExerciseType) {
        case ExerciseType.matching:
          _generateMatchingExercise();
          break;
        case ExerciseType.arrangeWords:
          _generateArrangeWordsExercise();
          break;
        case ExerciseType.arrangeSentence:
          _generateArrangeSentenceExercise();
          break;
      }
    });
  }

  void _generateMatchingExercise() {
    if (widget.grammar.structure.isEmpty) return;

    final random = Random();
    _currentStructureIndex = random.nextInt(widget.grammar.structure.length);
    final structureEntry = widget.grammar.structure.entries.elementAt(
      _currentStructureIndex,
    );

    _currentStructureKey = structureEntry.key;
    _correctAnswer = structureEntry.value;
    _quizParts = structureEntry.value.split(RegExp(r'\s+'));
    _quizParts.shuffle();
  }

  void _generateArrangeWordsExercise() {
    if (widget.grammar.examples.isEmpty) return;

    final random = Random();
    final example =
        widget.grammar.examples[random.nextInt(widget.grammar.examples.length)];

    _correctWordsSentence = example.en;
    _arrangeWordsHint = example.vi; // Dịch tiếng Việt làm gợi ý

    // Tách câu thành các từ và xáo trộn
    _arrangeWords = example.en.split(RegExp(r'\s+'));
    _arrangeWords.shuffle();
  }

  void _generateArrangeSentenceExercise() {
    if (widget.grammar.examples.isEmpty) return;

    final random = Random();
    final example =
        widget.grammar.examples[random.nextInt(widget.grammar.examples.length)];

    _correctSentence = example.en;
    _arrangeSentenceHint = example.vi; // Dịch tiếng Việt làm gợi ý

    // Tách câu thành các cụm từ (2-3 từ) và xáo trộn
    List<String> words = example.en.split(RegExp(r'\s+'));
    _arrangeSentenceParts = [];

    // Nhóm các từ thành cụm 2-3 từ
    for (int i = 0; i < words.length; i += 2) {
      if (i + 1 < words.length) {
        _arrangeSentenceParts.add('${words[i]} ${words[i + 1]}');
      } else {
        _arrangeSentenceParts.add(words[i]);
      }
    }

    _arrangeSentenceParts.shuffle();
  }

  void _checkAnswer() {
    setState(() {
      _attempts++;

      switch (_currentExerciseType) {
        case ExerciseType.matching:
          String userAnswer = _selectedPartsIndexes
              .map((i) => _quizParts[i])
              .join(' ')
              .replaceAll(RegExp(r'\s+'), ' ');
          String correctAnswerClean = _correctAnswer!.replaceAll(
            RegExp(r'\s+'),
            ' ',
          );
          _isCorrect = userAnswer.trim() == correctAnswerClean.trim();
          break;

        case ExerciseType.arrangeWords:
          String userSentence = _selectedWordsIndexes
              .map((i) => _arrangeWords[i])
              .join(' ')
              .toLowerCase()
              .replaceAll(RegExp(r'[.,!?]'), '')
              .trim();
          String correctClean = _correctWordsSentence!
              .toLowerCase()
              .replaceAll(RegExp(r'[.,!?]'), '')
              .trim();
          _isCorrect = userSentence == correctClean;
          break;

        case ExerciseType.arrangeSentence:
          String userSentence = _selectedSentenceIndexes
              .map((i) => _arrangeSentenceParts[i])
              .join(' ')
              .toLowerCase()
              .replaceAll(RegExp(r'[.,!?]'), '')
              .trim();
          String correctClean = _correctSentence!
              .toLowerCase()
              .replaceAll(RegExp(r'[.,!?]'), '')
              .trim();
          _isCorrect = userSentence == correctClean;
          break;
      }

      if (_isCorrect!) {
        _score++;
      }

      if (_attempts >= 5 && _score >= 4) {
        _isCompleted = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          _showCompletionDialog();
        });
      }
    });
  }

  void _nextQuestion() {
    _generateExercise();
  }

  void _changeExerciseType(ExerciseType newType) {
    setState(() {
      _currentExerciseType = newType;
      _currentExerciseIndex = 0;
      _generateExercise();
    });
  }

  void _switchToNextTopic() {
    if (_allGrammarTopics == null || _allGrammarTopics!.isEmpty) return;

    int currentIndex = _allGrammarTopics!.indexWhere(
      (g) => g.id == widget.grammar.id,
    );
    int nextIndex = (currentIndex + 1) % _allGrammarTopics!.length;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GrammarStudyPage(
          grammar: _allGrammarTopics![nextIndex],
          allGrammarTopics: _allGrammarTopics,
        ),
      ),
    );
  }

  void _switchToPreviousTopic() {
    if (_allGrammarTopics == null || _allGrammarTopics!.isEmpty) return;

    int currentIndex = _allGrammarTopics!.indexWhere(
      (g) => g.id == widget.grammar.id,
    );
    int prevIndex = currentIndex - 1;
    if (prevIndex < 0) prevIndex = _allGrammarTopics!.length - 1;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GrammarStudyPage(
          grammar: _allGrammarTopics![prevIndex],
          allGrammarTopics: _allGrammarTopics,
        ),
      ),
    );
  }

  void _showCompletionDialog() async {
    final progressService = ProgressService();
    await progressService.markGrammarAsCompleted(widget.grammar.id);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Chúc mừng!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn đã hoàn thành bài học "${widget.grammar.title}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Điểm: $_score/$_attempts',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '✓ Tiến trình đã được lưu',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Đóng', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _attempts = 0;
                _isCompleted = false;
                _generateExercise();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
            ),
            child: Text('Học tiếp', style: GoogleFonts.inter()),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.grammar.title,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Level: ${widget.grammar.level}',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.purple[700]),
            onPressed: _switchToPreviousTopic,
            tooltip: 'Chủ đề trước',
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.purple[700]),
            onPressed: _switchToNextTopic,
            tooltip: 'Chủ đề tiếp theo',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ: $_attempts/5 câu',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Đúng: $_score',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mô tả
            _buildCollapsibleSection(
              title: 'Mô tả',
              icon: Icons.description,
              isExpanded: _showDescription,
              onTap: () => setState(() => _showDescription = !_showDescription),
              child: Text(
                widget.grammar.description,
                style: GoogleFonts.inter(fontSize: 14, height: 1.6),
              ),
            ),

            const SizedBox(height: 16),

            // Quy tắc
            _buildCollapsibleSection(
              title: 'Quy tắc (${widget.grammar.rules.length})',
              icon: Icons.rule,
              isExpanded: _showRules,
              onTap: () => setState(() => _showRules = !_showRules),
              child: Column(
                children: widget.grammar.rules.asMap().entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Công thức
            _buildCollapsibleSection(
              title: 'Công thức (${widget.grammar.structure.length})',
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
              title: 'Ví dụ (${widget.grammar.examples.length})',
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
                  // Exercise type selector
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn dạng bài tập:',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[900],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildExerciseTypeChip(
                              'Ghép cấu trúc',
                              Icons.swap_horiz,
                              ExerciseType.matching,
                            ),
                            _buildExerciseTypeChip(
                              'Sắp xếp từ',
                              Icons.sort,
                              ExerciseType.arrangeWords,
                            ),
                            _buildExerciseTypeChip(
                              'Ghép câu',
                              Icons.create,
                              ExerciseType.arrangeSentence,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Exercise content
                  if (_currentExerciseType == ExerciseType.matching)
                    _buildMatchingExercise()
                  else if (_currentExerciseType == ExerciseType.arrangeWords)
                    _buildArrangeWordsExercise()
                  else if (_currentExerciseType == ExerciseType.arrangeSentence)
                    _buildArrangeSentenceExercise(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTypeChip(
    String label,
    IconData icon,
    ExerciseType type,
  ) {
    bool isSelected = _currentExerciseType == type;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.purple[700],
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _changeExerciseType(type);
      },
      selectedColor: Colors.purple[600],
      backgroundColor: Colors.white,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : Colors.purple[700],
      ),
    );
  }

  Widget _buildMatchingExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghép các phần sau để tạo cấu trúc ${_currentStructureKey ?? ""}:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.purple[900],
          ),
        ),
        const SizedBox(height: 16),

        // Selected parts
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedPartsIndexes.isEmpty
                  ? Colors.grey[300]!
                  : Colors.purple[300]!,
              width: 2,
            ),
          ),
          child: _selectedPartsIndexes.isEmpty
              ? Center(
                  child: Text(
                    'Chọn các phần để ghép công thức',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedPartsIndexes.asMap().entries.map((entry) {
                    int selectedIndex = entry.key;
                    int partIndex = entry.value;
                    return Chip(
                      label: Text(_quizParts[partIndex]),
                      onDeleted: () {
                        setState(() {
                          _selectedPartsIndexes.removeAt(selectedIndex);
                        });
                      },
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 16),

        // Quiz parts
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _quizParts.asMap().entries.map((entry) {
            final index = entry.key;
            final part = entry.value;
            final isSelected = _selectedPartsIndexes.contains(index);
            return GestureDetector(
              onTap: _isCorrect == null
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _selectedPartsIndexes.remove(index);
                        } else {
                          _selectedPartsIndexes.add(index);
                        }
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple[100] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.purple[600]! : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Text(
                  part,
                  style: GoogleFonts.robotoMono(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.purple[900] : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

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
                      color: _isCorrect! ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedPartsIndexes.isEmpty || _isCorrect != null
                    ? null
                    : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
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
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect!
                        ? Colors.green[600]
                        : Colors.orange[600],
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
    );
  }

  Widget _buildArrangeWordsExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hint (Vietnamese translation)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gợi ý: $_arrangeWordsHint',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Sắp xếp các từ sau thành câu hoàn chỉnh:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.purple[900],
          ),
        ),
        const SizedBox(height: 16),

        // Selected words area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedWordsIndexes.isEmpty
                  ? Colors.grey[300]!
                  : Colors.purple[300]!,
              width: 2,
            ),
          ),
          child: _selectedWordsIndexes.isEmpty
              ? Center(
                  child: Text(
                    'Chọn các từ để tạo câu',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedWordsIndexes.asMap().entries.map((entry) {
                    int selectedIndex = entry.key;
                    int wordIndex = entry.value;
                    return Chip(
                      label: Text(_arrangeWords[wordIndex]),
                      onDeleted: () {
                        setState(() {
                          _selectedWordsIndexes.removeAt(selectedIndex);
                        });
                      },
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 16),

        // Available words
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _arrangeWords.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            final isSelected = _selectedWordsIndexes.contains(index);
            return GestureDetector(
              onTap: _isCorrect == null
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _selectedWordsIndexes.remove(index);
                        } else {
                          _selectedWordsIndexes.add(index);
                        }
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple[100] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.purple[600]! : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Text(
                  word,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.purple[900] : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

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
                        ? 'Chính xác! Bạn đã sắp xếp đúng câu.'
                        : 'Chưa đúng. Đáp án: $_correctWordsSentence',
                    style: GoogleFonts.inter(
                      color: _isCorrect! ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedWordsIndexes.isEmpty || _isCorrect != null
                    ? null
                    : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
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
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect!
                        ? Colors.green[600]
                        : Colors.orange[600],
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
    );
  }

  Widget _buildArrangeSentenceExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hint (Vietnamese translation)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[50]!, Colors.green[100]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gợi ý: $_arrangeSentenceHint',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Ghép các cụm từ sau thành câu hoàn chỉnh:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.purple[900],
          ),
        ),
        const SizedBox(height: 16),

        // Selected sentence parts area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedSentenceIndexes.isEmpty
                  ? Colors.grey[300]!
                  : Colors.purple[300]!,
              width: 2,
            ),
          ),
          child: _selectedSentenceIndexes.isEmpty
              ? Center(
                  child: Text(
                    'Chọn các cụm từ để ghép câu',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedSentenceIndexes.asMap().entries.map((
                    entry,
                  ) {
                    int selectedIndex = entry.key;
                    int partIndex = entry.value;
                    return Chip(
                      label: Text(_arrangeSentenceParts[partIndex]),
                      onDeleted: () {
                        setState(() {
                          _selectedSentenceIndexes.removeAt(selectedIndex);
                        });
                      },
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 16),

        // Available sentence parts
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _arrangeSentenceParts.asMap().entries.map((entry) {
            final index = entry.key;
            final part = entry.value;
            final isSelected = _selectedSentenceIndexes.contains(index);
            return GestureDetector(
              onTap: _isCorrect == null
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _selectedSentenceIndexes.remove(index);
                        } else {
                          _selectedSentenceIndexes.add(index);
                        }
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple[100] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.purple[600]! : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Text(
                  part,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.purple[900] : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

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
                        ? 'Tuyệt vời! Bạn đã ghép đúng câu.'
                        : 'Chưa đúng. Đáp án: $_correctSentence',
                    style: GoogleFonts.inter(
                      color: _isCorrect! ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _selectedSentenceIndexes.isEmpty || _isCorrect != null
                    ? null
                    : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
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
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect!
                        ? Colors.green[600]
                        : Colors.orange[600],
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: Colors.purple[700], size: 24),
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
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.purple[700],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
