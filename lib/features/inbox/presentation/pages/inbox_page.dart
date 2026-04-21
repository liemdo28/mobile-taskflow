import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as du;
import '../../../../shared/providers.dart';
import '../../../../shared/models/models.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          notifs.whenData((result) => result.unreadCount > 0
            ? TextButton.icon(
                icon: const Icon(Icons.done_all, size: 20),
                label: const Text('Đọc hết'),
                onPressed: () async {
                  await ref.read(apiServiceProvider).markAllRead();
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(unreadCountProvider);
                },
              )
            : const SizedBox(),
          ).value ?? const SizedBox(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
          ),
        ],
      ),
      body: notifs.when(
        data: (result) {
          if (result.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('Không có thông báo nào', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: result.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final notif = result.notifications[i];
                return _NotificationTile(notification: notif);
              },
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(height: 8),
              Text('Error: $e', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Retry'),
                onPressed: () => ref.invalidate(notificationsProvider)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('notif_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.success,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      onDismissed: (_) {},
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? AppColors.bgTertiary
              : AppColors.primary.withOpacity(0.15),
          child: Icon(_iconForType(notification.type),
            color: notification.isRead ? AppColors.textTertiary : AppColors.primary,
            size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.message != null && notification.message!.isNotEmpty)
              Text(
                notification.message!,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              du.DateUtils.timeAgo(notification.createdAt),
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            // Mark as read (sẽ update khi có API)
          }
          if (notification.taskId != null) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => TaskDetailPage(taskId: notification.taskId!),
            ));
          }
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'task_assigned' => Icons.person_add_outlined,
      'task_completed' => Icons.check_circle_outline,
      'task_comment' => Icons.comment_outlined,
      'task_due_soon' => Icons.schedule_outlined,
      'task_overdue' => Icons.warning_amber_rounded,
      _ => Icons.notifications_outlined,
    };
  }
}
