import 'package:vocabsimple/src/services/local_database_service.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  // Cache để lưu trữ tiến trình hiện tại
  Map<String, int> _topicProgress = {};
  int _overallProgress = 0;
  int _totalWords = 0;
  int _learnedWords = 0;

  // Getters
  Map<String, int> get topicProgress => _topicProgress;
  int get overallProgress => _overallProgress;
  int get totalWords => _totalWords;
  int get learnedWords => _learnedWords;

  /// Load toàn bộ tiến trình từ database
  Future<void> loadAllProgress() async {
    print('🔄 Đang load tiến trình từ database...');
    
    // Load danh sách chủ đề
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
      final learnedInTopic = await LocalDatabaseService.countLearnedWords(topicName);
      totalLearned += learnedInTopic;
      
      print('📊 $topicName: $topicPercent% ($learnedInTopic/$topicLength từ)');
    }
    
    // Tính tiến trình tổng quát
    _totalWords = totalWords;
    _learnedWords = totalLearned;
    _overallProgress = totalWords > 0 ? ((totalLearned / totalWords) * 100).round() : 0;
    
    print('✅ Tiến trình tổng quát: $_overallProgress% ($_learnedWords/$_totalWords từ)');
  }

  /// Cập nhật tiến trình của một chủ đề cụ thể
  Future<void> updateTopicProgress(String topic) async {
    print('🔄 Đang cập nhật tiến trình cho chủ đề: $topic');
    
    // Đếm số từ đã học trong chủ đề
    final learnedCount = await LocalDatabaseService.countLearnedWords(topic);
    
    // Lấy tổng số từ trong chủ đề
    final words = await LocalDatabaseService.getWordsByTopic(topic);
    final totalCount = words.length;
    
    // Tính phần trăm
    final percent = totalCount > 0 ? ((learnedCount / totalCount) * 100).round() : 0;
    
    // Cập nhật trong database
    await LocalDatabaseService.updateTopicPercent(topic, percent);
    
    // Cập nhật cache
    _topicProgress[topic] = percent;
    
    print('📊 Cập nhật $topic: $percent% ($learnedCount/$totalCount từ)');
    
    // Reload toàn bộ tiến trình để đồng bộ
    await loadAllProgress();
  }

  /// Cập nhật tiến trình khi học một từ mới
  Future<void> markWordAsLearned(String topic, String wordName) async {
    print('📝 Đánh dấu từ "$wordName" trong chủ đề "$topic" đã học');
    
    // Đánh dấu từ đã học trong database
    await LocalDatabaseService.markWordAsLearned(wordName);
    
    // Cập nhật tiến trình của chủ đề
    await updateTopicProgress(topic);
    
    print('✅ Đã cập nhật tiến trình cho chủ đề $topic');
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
    print('🔄 Đang reset toàn bộ tiến trình...');
    
    // Xóa tất cả dữ liệu
    await LocalDatabaseService.clearAll();
    
    // Reset cache
    _topicProgress.clear();
    _overallProgress = 0;
    _totalWords = 0;
    _learnedWords = 0;
    
    print('✅ Đã reset toàn bộ tiến trình');
  }

  /// Force refresh toàn bộ tiến trình
  Future<void> forceRefresh() async {
    print('🔄 Force refresh tiến trình...');
    await loadAllProgress();
  }
}
