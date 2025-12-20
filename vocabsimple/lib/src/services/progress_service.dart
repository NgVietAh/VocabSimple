import 'package:vocabsimple/src/services/local_database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  // Cache để lưu trữ tiến trình hiện tại
  Map<String, int> _topicProgress = {};
  int _overallProgress = 0;
  int _totalWords = 0;
  int _learnedWords = 0;

  // Grammar progress
  Map<String, bool> _grammarProgress = {}; // grammar_id -> completed
  int _completedGrammarCount = 0;
  int _totalGrammarCount = 0;

  // Getters
  Map<String, int> get topicProgress => _topicProgress;
  int get overallProgress => _overallProgress;
  int get totalWords => _totalWords;
  int get learnedWords => _learnedWords;
  Map<String, bool> get grammarProgress => _grammarProgress;
  int get completedGrammarCount => _completedGrammarCount;
  int get totalGrammarCount => _totalGrammarCount;

  /// Load toàn bộ tiến trình từ database
  Future<void> loadAllProgress() async {
    // Load vocabulary progress
    final topics = await LocalDatabaseService.getTopics();
    _topicProgress.clear();

    int totalLearned = 0;
    int totalWords = 0;

    for (var topic in topics) {
      final topicName = topic['topic'] as String;
      final topicPercent = topic['percent'] as int? ?? 0;
      final topicLength = topic['length'] as int? ?? 0;

      _topicProgress[topicName] = topicPercent;
      totalWords += topicLength;

      // Tính số từ đã học trong chủ đề này
      final learnedInTopic = await LocalDatabaseService.countLearnedWords(
        topicName,
      );
      totalLearned += learnedInTopic;
    }

    // Tính tiến trình tổng quát
    _totalWords = totalWords;
    _learnedWords = totalLearned;
    _overallProgress = totalWords > 0
        ? ((totalLearned / totalWords) * 100).round()
        : 0;

    // Load grammar progress
    await loadGrammarProgress();
  }

  /// Load tiến trình ngữ pháp
  Future<void> loadGrammarProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final grammarKeys = prefs
        .getKeys()
        .where((key) => key.startsWith('grammar_'))
        .toList();

    _grammarProgress.clear();
    _completedGrammarCount = 0;

    for (var key in grammarKeys) {
      final grammarId = key.replaceFirst('grammar_', '');
      final isCompleted = prefs.getBool(key) ?? false;
      _grammarProgress[grammarId] = isCompleted;
      if (isCompleted) _completedGrammarCount++;
    }
  }

  /// Đánh dấu bài ngữ pháp đã hoàn thành
  Future<void> markGrammarAsCompleted(String grammarId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('grammar_$grammarId', true);

    _grammarProgress[grammarId] = true;
    _completedGrammarCount = _grammarProgress.values.where((v) => v).length;
  }

  /// Kiểm tra xem bài ngữ pháp đã hoàn thành chưa
  bool isGrammarCompleted(String grammarId) {
    return _grammarProgress['grammar_$grammarId'] ?? false;
  }

  /// Cập nhật tổng số bài ngữ pháp
  void setTotalGrammarCount(int count) {
    _totalGrammarCount = count;
  }

  /// Lấy phần trăm hoàn thành ngữ pháp
  int getGrammarProgressPercent() {
    if (_totalGrammarCount == 0) return 0;
    return ((_completedGrammarCount / _totalGrammarCount) * 100).round();
  }

  /// Cập nhật tiến trình của một chủ đề cụ thể
  Future<void> updateTopicProgress(String topic) async {
    // Đếm số từ đã học trong chủ đề
    final learnedCount = await LocalDatabaseService.countLearnedWords(topic);

    // Lấy tổng số từ trong chủ đề
    final words = await LocalDatabaseService.getWordsByTopic(topic);
    final totalCount = words.length;

    // Tính phần trăm
    final percent = totalCount > 0
        ? ((learnedCount / totalCount) * 100).round()
        : 0;

    // Cập nhật trong database
    await LocalDatabaseService.updateTopicPercent(topic, percent);

    // Cập nhật cache
    _topicProgress[topic] = percent;

    // Reload toàn bộ tiến trình để đồng bộ
    await loadAllProgress();
  }

  /// Cập nhật tiến trình khi học một từ mới
  Future<void> markWordAsLearned(String topic, String wordName) async {
    // Đánh dấu từ đã học trong database
    await LocalDatabaseService.markWordAsLearned(wordName);

    // Cập nhật tiến trình của chủ đề
    await updateTopicProgress(topic);
  }

  /// Lấy tiến trình của một chủ đề cụ thể
  int getTopicProgress(String topic) {
    return _topicProgress[topic] ?? 0;
  }

  /// Lấy số từ đã học trong một chủ đề
  Future<int> getLearnedWordsInTopic(String topic) async {
    return await LocalDatabaseService.countLearnedWords(topic);
  }

  /// Lấy tổng số từ trong một chủ đề
  Future<int> getTotalWordsInTopic(String topic) async {
    final words = await LocalDatabaseService.getWordsByTopic(topic);
    return words.length;
  }

  /// Reset toàn bộ tiến trình
  Future<void> resetAllProgress() async {
    // Xóa tất cả dữ liệu vocabulary
    await LocalDatabaseService.clearAll();

    // Xóa grammar progress
    final prefs = await SharedPreferences.getInstance();
    final grammarKeys = prefs
        .getKeys()
        .where((key) => key.startsWith('grammar_'))
        .toList();
    for (var key in grammarKeys) {
      await prefs.remove(key);
    }

    // Reset cache
    _topicProgress.clear();
    _overallProgress = 0;
    _totalWords = 0;
    _learnedWords = 0;
    _grammarProgress.clear();
    _completedGrammarCount = 0;
  }

  /// Force refresh toàn bộ tiến trình
  Future<void> forceRefresh() async {
    await loadAllProgress();
  }
}
