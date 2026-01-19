import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepository(this._remoteDataSource);

  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 0,
    int size = 20,
    bool? unreadOnly,
  }) async {
    try {
      final models = await _remoteDataSource.getNotifications(
        page: page,
        size: size,
        unreadOnly: unreadOnly,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await _remoteDataSource.getUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, NotificationEntity>> markAsRead(String notificationId) async {
    try {
      final model = await _remoteDataSource.markAsRead(notificationId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> markAllAsRead() async {
    try {
      final count = await _remoteDataSource.markAllAsRead();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> registerFcmToken(String fcmToken) async {
    try {
      await _remoteDataSource.registerFcmToken(fcmToken);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
