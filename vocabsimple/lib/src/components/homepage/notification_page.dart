import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/notification_model.dart';
import 'package:vocabsimple/src/services/notification_service.dart';
import 'package:vocabsimple/src/services/progress_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    _generateDailyGreeting();
    _generateCompletedTopicNotifications();
    _generateCompletedGrammarNotifications();
  }

  /// Tạo thông báo cho các bài ngữ pháp đã hoàn thành
void _generateCompletedGrammarNotifications() async {
  final learnedGrammarIds = await ProgressService.getLearnedGrammarIds();
  for (var grammarId in learnedGrammarIds) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "📘 Bạn đã hoàn thành bài ngữ pháp: $grammarId",
      timeAgo: "Vừa xong",
      createdAt: DateTime.now(),
    );
    NotificationService.addNotification(notification);
  }
}

  /// Tạo thông báo chào ngày mới
  void _generateDailyGreeting() {
    final now = DateTime.now();
    const weekdays = [
      'Thứ hai', 'Thứ ba', 'Thứ tư',
      'Thứ năm', 'Thứ sáu', 'Thứ bảy', 'Chủ nhật'
    ];
    final dayName = weekdays[now.weekday - 1];

    final greeting = NotificationModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: "Chào buổi sáng $dayName 🌞! Hãy bắt đầu học tập thật hăng say!",
      timeAgo: "Hôm nay",
      createdAt: now,
    );

    NotificationService.addNotification(greeting);
  }

  /// Tạo thông báo cho các topic đã hoàn thành
  void _generateCompletedTopicNotifications() {
    final completedTopics = _progressService.getCompletedTopics();
    for (var topic in completedTopics) {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "🎉 Bạn đã hoàn thành chủ đề: $topic",
        timeAgo: "Vừa xong",
        createdAt: DateTime.now(),
      );
      NotificationService.addNotification(notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService.getAllNotifications();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Thông báo",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "Chưa có thông báo nào",
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.isRead ? Colors.grey[200] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: Colors.blue,
                    ),
                    title: Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      item.timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      NotificationService.markAsRead(item.id);
                      setState(() {}); // refresh UI
                    },
                  ),
                );
              },
            ),
    );
  }
}
