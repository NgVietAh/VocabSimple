# Kiến trúc và Mô hình Dự án VocabSimple

## 📋 Tổng quan dự án
VocabSimple là ứng dụng học tiếng Anh tập trung vào từ vựng, ngữ pháp và kiểm tra, được xây dựng bằng Flutter với Firebase.

---

## 🏗️ 1. Các Mô Hình Thiết Kế (Design Patterns) Đã Sử Dụng

### 1.1. **BLoC Pattern (Business Logic Component)**
- **Vị trí:** `lib/src/blocs/auth_bloc.dart`
- **Mục đích:** Quản lý logic xác thực người dùng
- **Chức năng:**
  - Xử lý đăng nhập/đăng ký
  - Validation email và password theo thời gian thực
  - Tích hợp Firebase Authentication (Email/Password, Google, Facebook)
  
**Ví dụ:**
```dart
class AuthBloc {
  final _emailController = StreamController<String>.broadcast();
  final _passController = StreamController<String>.broadcast();

  Stream<String> get emailStream => _emailController.stream;
  Stream<String> get passStream => _passController.stream;

  void emailChanged(String email) {
    if (!Validations.isValidEmail(email)) {
      _emailController.sink.addError('Email không hợp lệ');
    } else {
      _emailController.sink.add(email);
    }
  }
}
```

### 1.2. **Singleton Pattern**
- **Vị trí:** `lib/src/services/progress_service.dart`
- **Mục đích:** Đảm bảo chỉ có 1 instance duy nhất của ProgressService
- **Lợi ích:** Chia sẻ dữ liệu tiến trình học tập xuyên suốt ứng dụng

**Ví dụ:**
```dart
class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();
  
  Map<String, int> _topicProgress = {};
  int _overallProgress = 0;
}
```

### 1.3. **Factory Pattern**
- **Vị trí:** Các model classes (`Grammar`, `Quiz`, `NotificationModel`)
- **Mục đích:** Tạo đối tượng từ JSON data
- **Lợi ích:** Dễ dàng parse dữ liệu từ JSON files và API

**Ví dụ:**
```dart
class Grammar {
  factory Grammar.fromJson(Map<String, dynamic> json) {
    return Grammar(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      level: json['level'] ?? 'basic',
      // ...
    );
  }
}
```

### 1.4. **Service Layer Pattern**
- **Vị trí:** `lib/src/services/`
- **Mục đích:** Tách biệt business logic khỏi UI
- **Các services:**
  - `LocalDatabaseService`: Quản lý SQLite database
  - `ProgressService`: Theo dõi tiến trình học
  - `QuizService`: Tạo và quản lý câu hỏi test
  - `GrammarService`: Load dữ liệu ngữ pháp
  - `FirebaseAuthService`: Xác thực với Firebase

### 1.5. **Repository Pattern (Implicit)**
- Kết hợp trong `LocalDatabaseService`
- Trừu tượng hóa data source (SQLite)
- Cung cấp API thống nhất để truy cập dữ liệu

### 1.6. **State Management Pattern**
- **StatefulWidget + setState()**: Quản lý local state
- **GlobalKey**: Giao tiếp giữa các widget (ProgressPage reload)
- **StreamBuilder**: Reactive UI với BLoC pattern

### 1.7. **Observer Pattern**
- Sử dụng qua `StreamController` trong BLoC
- UI lắng nghe thay đổi từ Stream và tự động cập nhật

---

## 🗂️ 2. Cấu Trúc Thư Mục (Architecture Layers)

```
lib/src/
├── blocs/              # Business Logic Components
│   └── auth_bloc.dart  # Xử lý authentication logic
│
├── components/         # UI Components (Presentation Layer)
│   ├── dialog/         # Reusable dialogs
│   ├── grammar/        # Grammar learning screens
│   ├── homepage/       # Main app screens
│   ├── model/          # Data models
│   ├── test/           # Test/quiz screens
│   ├── user/           # User authentication screens
│   └── widgets/        # Reusable widgets
│
├── firebase/           # Firebase Integration Layer
│   └── firebase_auth_service.dart
│
├── services/           # Business Logic & Data Layer
│   ├── local_database_service.dart
│   ├── progress_service.dart
│   ├── quiz_service.dart
│   └── grammar_service.dart
│
└── validators/         # Validation Logic
    └── Validations.dart
```

---

## 📊 3. Data Models (Domain Models)

### 3.1. **Grammar Model**
```dart
class Grammar {
  String id;
  String title;
  String level;
  String description;
  Map<String, String> structure;
  List<String> rules;
  List<GrammarExample> examples;
  List<String> notes;
}
```

### 3.2. **Quiz Model**
```dart
class Quiz {
  String question;
  String correctAnswer;
  List<String> options;
  String? userAnswer;
  String type; // 'multiple_choice', 'fill_blank'
  String? hint;
  
  bool get isCorrect; // Computed property
}
```

### 3.3. **TestResult Model**
```dart
class TestResult {
  int totalQuestions;
  int correctAnswers;
  int wrongAnswers;
  int skippedAnswers;
  double score;
  Duration timeTaken;
  
  String get grade; // Computed property
}
```

### 3.4. **NotificationModel**
```dart
class NotificationModel {
  final String id;
  final String title;
  final String timeAgo;
  final DateTime createdAt;
  final bool isRead;
}
```

---

## 🔄 4. Data Flow Architecture

```
┌─────────────────┐
│   UI Layer      │ ← StatefulWidget với setState()
│  (Components)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   BLoC Layer    │ ← Stream-based state management
│  (auth_bloc)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Service Layer   │ ← Business logic & data operations
│  (Services)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Data Layer     │ ← SQLite, Firebase, JSON files
│ (Database/API)  │
└─────────────────┘
```

---

## 💾 5. Data Persistence

### 5.1. **SQLite Database**
- Lưu trữ từ vựng, tiến trình học, lịch sử test
- Quản lý qua `LocalDatabaseService`
- Tables:
  - `topics`: Danh sách chủ đề
  - `words`: Từ vựng và trạng thái học
  - `test_history`: Lịch sử làm bài test

### 5.2. **Firebase**
- Authentication: Email/Password, Google, Facebook
- Cloud storage cho user data (future feature)

### 5.3. **JSON Assets**
- `assets/data/vocabulary.json`: Dữ liệu từ vựng
- `assets/data/grammar.json`: Dữ liệu ngữ pháp

---

## 🎯 6. Chất Lượng Code (Quality Measures)

### 6.1. **Separation of Concerns**
✅ UI tách biệt khỏi business logic
✅ Services tách biệt khỏi data layer
✅ Validators riêng biệt cho validation logic

### 6.2. **Code Reusability**
✅ Reusable widgets (dialogs, cards, buttons)
✅ Service classes có thể dùng lại
✅ Shared models và utilities

### 6.3. **Error Handling**
✅ Try-catch trong async operations
✅ Validation trước khi xử lý data
✅ Error messages thân thiện với user

### 6.4. **Performance Optimization**
✅ Singleton pattern giảm memory usage
✅ Caching trong ProgressService
✅ Lazy loading data khi cần

### 6.5. **Maintainability**
✅ Clear folder structure
✅ Descriptive naming conventions
✅ Modular architecture dễ mở rộng

---

## 📱 7. Các Tính Năng Chính

### 7.1. **Học Từ Vựng**
- Flashcard system với flip animation
- Phát âm từ vựng (Text-to-Speech)
- Theo dõi tiến trình học theo chủ đề
- Đánh dấu từ đã học

### 7.2. **Học Ngữ Pháp**
- Hiển thị công thức, quy tắc, ví dụ
- Quiz tương tác (sắp xếp công thức)
- Collapsible sections để tiết kiệm không gian
- Theo dõi điểm và tiến độ

### 7.3. **Kiểm Tra**
- Multiple choice và fill-in-the-blank
- Test theo chủ đề hoặc tổng hợp
- Lưu lịch sử làm bài
- Thống kê điểm số và thời gian

### 7.4. **Theo Dõi Tiến Trình**
- Tab cho Từ vựng, Ngữ pháp, Kiểm tra
- Hiển thị phần trăm hoàn thành
- Circular và linear progress indicators
- Refresh manual để cập nhật

---

## 🔐 8. Security & Authentication

- Firebase Authentication
- Email verification
- Password reset functionality
- OAuth (Google, Facebook login)
- Local data encryption (future enhancement)

---

## 🚀 9. Future Enhancements

1. **Cloud Sync**: Đồng bộ tiến trình qua Firebase
2. **Spaced Repetition**: Thuật toán lặp lại ngắt quãng
3. **Gamification**: Huy hiệu, streak, leaderboard
4. **Offline Mode**: Full offline support
5. **AI Recommendations**: Gợi ý từ vựng cá nhân hóa
6. **Speech Recognition**: Luyện phát âm với AI

---

## 📝 10. Kết Luận

### ✅ Điểm Mạnh
- Architecture rõ ràng, dễ maintain
- Separation of concerns tốt
- Reusable components
- State management hiệu quả với BLoC + setState

### 🔄 Có Thể Cải Thiện
- Thêm unit tests và integration tests
- Documentation code chi tiết hơn
- Error handling toàn diện hơn
- Implement dependency injection
- Add logging và analytics

---

**Ngày cập nhật:** 16/11/2025  
**Version:** 1.0  
**Tác giả:** VocabSimple Team
