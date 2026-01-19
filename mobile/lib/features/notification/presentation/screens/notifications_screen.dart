import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationNotifierProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationNotifierProvider.notifier).markAllAsRead(),
              child: Text(
                'Tout lire',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(NotificationState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(state.error!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => ref.read(notificationNotifierProvider.notifier).loadNotifications(refresh: true),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.md),
            Text('Aucune notification', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationNotifierProvider.notifier).loadNotifications(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return _NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationEntity notification) {
    if (!notification.read) {
      ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isToday = DateUtils.isSameDay(notification.createdAt, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: notification.read ? AppColors.surface : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getIconColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(_getIcon(), color: _getIconColor(), size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: notification.read ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            isToday
                                ? timeFormat.format(notification.createdAt)
                                : dateFormat.format(notification.createdAt),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!notification.read)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.transactionReceived:
        return Icons.arrow_downward;
      case NotificationType.transactionSent:
        return Icons.arrow_upward;
      case NotificationType.transactionFailed:
        return Icons.error_outline;
      case NotificationType.kycApproved:
        return Icons.verified;
      case NotificationType.kycRejected:
        return Icons.cancel_outlined;
      case NotificationType.kycDocumentRequired:
        return Icons.description;
      case NotificationType.limitWarning:
      case NotificationType.limitReached:
        return Icons.warning_amber;
      case NotificationType.qrPaymentReceived:
        return Icons.qr_code;
      case NotificationType.merchantRelationRequest:
      case NotificationType.merchantRelationApproved:
        return Icons.handshake;
      case NotificationType.systemAlert:
        return Icons.info_outline;
      case NotificationType.promotional:
        return Icons.local_offer;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.transactionReceived:
      case NotificationType.qrPaymentReceived:
        return AppColors.success;
      case NotificationType.transactionSent:
        return AppColors.primary;
      case NotificationType.transactionFailed:
      case NotificationType.kycRejected:
        return AppColors.error;
      case NotificationType.kycApproved:
      case NotificationType.merchantRelationApproved:
        return AppColors.success;
      case NotificationType.kycDocumentRequired:
      case NotificationType.merchantRelationRequest:
        return AppColors.info;
      case NotificationType.limitWarning:
      case NotificationType.limitReached:
        return AppColors.warning;
      case NotificationType.systemAlert:
        return AppColors.textSecondary;
      case NotificationType.promotional:
        return AppColors.primary;
    }
  }
}
