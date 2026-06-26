import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/notification_service.dart';
import '../../services/socket_service.dart';
import '../../models/notification_model.dart';
import '../../theme/typography.dart';
import '../../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Color darkNavy = const Color(0xFF1E40AF);
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _connectSocketListener();
  }

  @override
  void dispose() {
    SocketService().off('NEW_NOTIFICATION', _onNewNotification);
    super.dispose();
  }

  void _connectSocketListener() {
    SocketService().on('NEW_NOTIFICATION', _onNewNotification);
  }

  void _onNewNotification(dynamic data) {
    if (data == null) return;
    try {
      final newNotif = NotificationModel.fromJson(Map<String, dynamic>.from(data as Map));
      if (mounted) {
        setState(() {
          _notifications.insert(0, newNotif);
          _unreadCount++;
        });
      }
    } catch (e) {
      debugPrint('Error parsing realtime notification: $e');
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final list = await NotificationService.instance.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _unreadCount = list.where((n) => !n.isRead).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsRead(String id, int index) async {
    if (_notifications[index].isRead) return;
    
    final success = await NotificationService.instance.markAsRead(id);
    if (success && mounted) {
      setState(() {
        final current = _notifications[index];
        _notifications[index] = NotificationModel(
          id: current.id,
          userId: current.userId,
          title: current.title,
          message: current.message,
          type: current.type,
          isRead: true,
          createdAt: current.createdAt,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
      });
    }
  }

  Future<void> _markAllRead() async {
    if (_unreadCount == 0) return;
    final success = await NotificationService.instance.markAllRead();
    if (success && mounted) {
      showToast(context, 'All marked as read');
      setState(() {
        _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        )).toList();
        _unreadCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E40AF)))
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: _notifications.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: EdgeInsets.all(16.r),
                            itemCount: _notifications.length,
                            itemBuilder: (context, i) => _buildNotificationItem(_notifications[i], i),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: darkNavy,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10.h,
          bottom: 20.h,
          left: 20.w,
          right: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 24.sp),
                  onPressed: () => Navigator.pop(context)),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications',
                      style: AppTypography.h4.copyWith(color: Colors.white)),
                  Text('$_unreadCount unread alerts',
                      style: AppTypography.small
                          .copyWith(color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ],
          ),
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _markAllRead,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Mark all read',
                  style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 150.h),
        Center(
          child: Column(
            children: [
              Icon(Icons.notifications_off_outlined, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'No notifications found',
                style: AppTypography.bodyLarge.copyWith(color: Colors.grey.shade600),
              ),
              SizedBox(height: 8.h),
              Text(
                'You will receive realtime alerts here',
                style: AppTypography.caption.copyWith(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationModel item, int index) {
    Color typeColor = Colors.grey;
    if (item.type == 'ALERT' || item.type == 'OVERDUE') {
      typeColor = Colors.red;
    } else if (item.type == 'ACADEMIC') {
      typeColor = Colors.blue;
    } else if (item.type == 'FEE') {
      typeColor = Colors.orange;
    } else if (item.type == 'SUCCESS') {
      typeColor = Colors.green;
    } else if (item.type == 'QUIZ') {
      typeColor = Colors.purple;
    }

    final diff = DateTime.now().difference(item.createdAt);
    String timeText = 'Just now';
    if (diff.inDays > 0) {
      timeText = '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      timeText = '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      timeText = '${diff.inMinutes} minutes ago';
    }

    return GestureDetector(
      onTap: () => _markAsRead(item.id, index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16.r),
          border: item.isRead ? null : Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.small.copyWith(
                      color: const Color(0xFF1E3A8A),
                      fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.message,
                    style: AppTypography.small.copyWith(color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    timeText,
                    style: AppTypography.caption.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
