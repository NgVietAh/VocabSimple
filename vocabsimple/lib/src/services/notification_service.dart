import 'package:vocabsimple/src/components/model/notification_model.dart';

class NotificationService {
  static final List<NotificationModel> _notifications = [];

  /// Thêm thông báo mới
  static void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // thêm mới lên đầu
  }

  /// Lấy tất cả thông báo
  static List<NotificationModel> getAllNotifications() {
    return _notifications;
  }

  /// Đánh dấu thông báo là đã đọc
  static void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }
}
