import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/entities/notification_entity.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRemoteDataSource(apiClient);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepository(remoteDataSource);
});

final notificationsProvider = FutureProvider.autoDispose<List<NotificationEntity>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getNotifications();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (notifications) => notifications,
  );
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getUnreadCount();
  return result.fold(
    (failure) => 0,
    (count) => count,
  );
});

class NotificationState {
  final bool isLoading;
  final String? error;
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationState({
    this.isLoading = false,
    this.error,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? error,
    List<NotificationEntity>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const NotificationState());

  Future<void> loadNotifications({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getNotifications();
    final countResult = await _repository.getUnreadCount();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (notifications) {
        final unread = countResult.fold((f) => 0, (c) => c);
        state = state.copyWith(
          isLoading: false,
          notifications: notifications,
          unreadCount: unread,
        );
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);
    result.fold(
      (failure) {},
      (notification) {
        final updated = state.notifications.map((n) {
          if (n.id == notificationId) {
            return notification;
          }
          return n;
        }).toList();
        state = state.copyWith(
          notifications: updated,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    result.fold(
      (failure) {},
      (count) {
        loadNotifications(refresh: true);
      },
    );
  }
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return FcmService(repository);
});

class FcmService {
  final NotificationRepository _repository;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  FcmService(this._repository);

  Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _registerToken();
    _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
      },
    );

    const androidChannel = AndroidNotificationChannel(
      'jufa_notifications',
      'JUFA Notifications',
      description: 'Notifications de transactions et alertes JUFA',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _repository.registerFcmToken(token);
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        await _repository.registerFcmToken(newToken);
      });
    } catch (e) {
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessageTap(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'jufa_notifications',
      'JUFA Notifications',
      channelDescription: 'Notifications de transactions et alertes JUFA',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
  }
}
