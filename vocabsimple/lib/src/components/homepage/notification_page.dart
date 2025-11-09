import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabsimple/src/components/model/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Dữ liệu mẫu thông báo
  List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: 'Hôm nay bạn chưa làm bài nhi !',
      timeAgo: '2h ago',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Hôm nay bạn chưa làm bài test !',
      timeAgo: '2h ago',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'Một ngày đẹp trời để làm từ trùm ing lịch',
      timeAgo: '2h ago',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: '4',
      title: 'Đã có tiến triển tuyệt vời trước đó của bạn',
      timeAgo: '2h ago',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
  ];

  // Nhóm thông báo theo thời gian
  Map<String, List<NotificationModel>> _groupNotifications() {
    Map<String, List<NotificationModel>> grouped = {
      'Today': [],
      'This Week': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    for (var notification in notifications) {
      final notifDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notifDate.isAtSameMomentAs(today)) {
        grouped['Today']!.add(notification);
      } else if (notifDate.isAfter(weekAgo)) {
        grouped['This Week']!.add(notification);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thông báo',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có thông báo',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Today Section
                if (groupedNotifications['Today']!.isNotEmpty) ...[
                  Text(
                    'Today',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...groupedNotifications['Today']!.map(
                    (notification) => _buildNotificationItem(notification),
                  ),
                  const SizedBox(height: 24),
                ],

                // This Week Section
                if (groupedNotifications['This Week']!.isNotEmpty) ...[
                  Text(
                    'This Week',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...groupedNotifications['This Week']!.map(
                    (notification) => _buildNotificationItem(notification),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.blue[100]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator dot
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: notification.isRead ? Colors.grey[300] : Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: notification.isRead
                        ? FontWeight.w400
                        : FontWeight.w500,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.timeAgo,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
