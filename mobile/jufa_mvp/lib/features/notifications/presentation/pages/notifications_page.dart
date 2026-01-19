import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_notification_service.dart';
import '../../../../core/l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ApiNotificationService _notificationService = ApiNotificationService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;
  bool _isSelectionMode = false;
  Set<int> _selectedNotifications = {};

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _notificationService.getNotifications();
      final unreadCount = await _notificationService.getUnreadCount();
      
      if (mounted) {
        setState(() {
          _notifications = data;
          _unreadCount = unreadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('error')}: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      if (mounted) {
        setState(() {
          _notifications[index]['is_read'] = true;
          if (_unreadCount > 0) _unreadCount--;
        });
      }
    } catch (e) {
      print('Erreur lors du marquage comme lu: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      if (mounted) {
        setState(() {
          for (var notification in _notifications) {
            notification['is_read'] = true;
          }
          _unreadCount = 0;
        });
        
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('all_notifications_marked_read')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('error')}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(int notificationId, int index) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      if (mounted) {
        setState(() {
          if (_notifications[index]['is_read'] == false && _unreadCount > 0) {
            _unreadCount--;
          }
          _notifications.removeAt(index);
        });
        
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('notification_deleted')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('error')}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteSelectedNotifications() async {
    if (_selectedNotifications.isEmpty) return;

    try {
      // Supprimer toutes les notifications sélectionnées
      for (final notificationId in _selectedNotifications) {
        await _notificationService.deleteNotification(notificationId);
      }

      if (mounted) {
        setState(() {
          _notifications.removeWhere((notification) => 
            _selectedNotifications.contains(notification['id']));
          _selectedNotifications.clear();
          _isSelectionMode = false;
        });

        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('notifications_deleted')),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Recharger pour mettre à jour le compteur
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('error')}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _toggleSelection(int notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
        if (_selectedNotifications.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNotifications.add(notificationId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedNotifications.length == _notifications.length) {
        _selectedNotifications.clear();
        _isSelectionMode = false;
      } else {
        _selectedNotifications = _notifications
            .map((n) => n['id'] as int)
            .toSet();
      }
    });
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'transfer_received':
        return Icons.arrow_downward;
      case 'transfer_sent':
        return Icons.arrow_upward;
      case 'payment':
        return Icons.payment;
      case 'security':
        return Icons.security;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'transfer_received':
        return AppColors.success;
      case 'transfer_sent':
        return AppColors.primary;
      case 'payment':
        return AppColors.warning;
      case 'security':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(String dateString) {
    final l10n = AppLocalizations.of(context);
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return l10n.translate('just_now');
      } else if (difference.inHours < 1) {
        return l10n.translate('minutes_ago').replaceAll('{minutes}', difference.inMinutes.toString());
      } else if (difference.inDays < 1) {
        return l10n.translate('hours_ago').replaceAll('{hours}', difference.inHours.toString());
      } else if (difference.inDays < 7) {
        return l10n.translate('days_ago').replaceAll('{days}', difference.inDays.toString());
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text(l10n.translate('selected_count').replaceAll('{count}', _selectedNotifications.length.toString()))
            : Text(l10n.translate('notifications')),
        leading: _isSelectionMode
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedNotifications.clear();
                  });
                },
              )
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: Icon(
                _selectedNotifications.length == _notifications.length
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
              ),
              onPressed: _selectAll,
              tooltip: l10n.translate('select_all'),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _selectedNotifications.isEmpty
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.translate('confirm_deletion')),
                          content: Text(
                            l10n.translate('delete_notifications_confirm').replaceAll('{count}', _selectedNotifications.length.toString()),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.translate('cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: Text(l10n.translate('delete')),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        _deleteSelectedNotifications();
                      }
                    },
              tooltip: l10n.translate('delete'),
            ),
          ] else ...[
            if (_notifications.isNotEmpty)
              IconButton(
                icon: Icon(Icons.checklist),
                onPressed: () {
                  setState(() => _isSelectionMode = true);
                },
                tooltip: l10n.translate('select'),
              ),
            if (_unreadCount > 0)
              TextButton(
                onPressed: _markAllAsRead,
                child: Text(l10n.translate('mark_all_as_read')),
              ),
          ],
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('no_notifications'),
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['is_read'] ?? false;
                      final type = notification['type'] ?? '';
                      final title = notification['title'] ?? '';
                      final message = notification['message'] ?? '';
                      final createdAt = notification['created_at'] ?? '';
                      final notificationId = notification['id'];

                      return Dismissible(
                        key: Key('notification_$notificationId'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          _deleteNotification(notificationId, index);
                        },
                        child: InkWell(
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelection(notificationId);
                            } else if (!isRead) {
                              _markAsRead(notificationId, index);
                            }
                          },
                          onLongPress: () {
                            if (!_isSelectionMode) {
                              setState(() {
                                _isSelectionMode = true;
                                _selectedNotifications.add(notificationId);
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.inputBackground,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Checkbox en mode sélection
                                  if (_isSelectionMode)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Checkbox(
                                        value: _selectedNotifications.contains(notificationId),
                                        onChanged: (value) {
                                          _toggleSelection(notificationId);
                                        },
                                      ),
                                    ),
                                  // Icône
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getNotificationColor(type).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getNotificationIcon(type),
                                      color: _getNotificationColor(type),
                                      size: 24,
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 12),
                                  
                                  // Contenu
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          message,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
