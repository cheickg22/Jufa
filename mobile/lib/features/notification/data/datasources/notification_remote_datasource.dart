import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource(this._apiClient);

  Future<List<NotificationModel>> getNotifications({
    int page = 0,
    int size = 20,
    bool? unreadOnly,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      if (unreadOnly != null) 'unreadOnly': unreadOnly.toString(),
    };

    final response = await _apiClient.get(
      ApiConstants.notifications,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'];
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiConstants.notificationsUnreadCount);
    return response['data']['count'] as int;
  }

  Future<NotificationModel> markAsRead(String notificationId) async {
    final response = await _apiClient.post(
      ApiConstants.notificationMarkRead(notificationId),
    );
    return NotificationModel.fromJson(response['data']);
  }

  Future<int> markAllAsRead() async {
    final response = await _apiClient.post(ApiConstants.notificationsReadAll);
    return response['data']['markedCount'] as int;
  }

  Future<void> registerFcmToken(String fcmToken) async {
    await _apiClient.post(
      ApiConstants.notificationsFcmToken,
      data: {'fcmToken': fcmToken},
    );
  }
}
