import 'api_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  // Fetch student or teacher notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await ApiService.instance.get('notifications');
      if (res != null && res['notifications'] != null) {
        final list = res['notifications'] as List;
        return list.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Mark a specific notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final res = await ApiService.instance.put('notifications/$notificationId/read');
      return res != null && res['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllRead() async {
    try {
      final res = await ApiService.instance.put('notifications/mark-all-read');
      return res != null && res['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
