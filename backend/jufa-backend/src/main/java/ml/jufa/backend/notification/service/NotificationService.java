package ml.jufa.backend.notification.service;

import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.notification.dto.NotificationResponse;
import ml.jufa.backend.notification.entity.Notification;
import ml.jufa.backend.notification.repository.NotificationRepository;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public List<NotificationResponse> getNotifications(User user, int page, int size, Boolean unreadOnly) {
        PageRequest pageRequest = PageRequest.of(page, size);
        Page<Notification> notifications;

        if (unreadOnly != null && unreadOnly) {
            notifications = notificationRepository.findByUserAndReadOrderByCreatedAtDesc(user, false, pageRequest);
        } else {
            notifications = notificationRepository.findByUserOrderByCreatedAtDesc(user, pageRequest);
        }

        return notifications.getContent().stream()
                .map(NotificationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public long getUnreadCount(User user) {
        return notificationRepository.countByUserAndRead(user, false);
    }

    @Transactional
    public NotificationResponse markAsRead(User user, UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new JufaException("JUFA-NOTIF-001", "Notification not found"));

        if (!notification.getUser().getId().equals(user.getId())) {
            throw new JufaException("JUFA-NOTIF-002", "Not authorized to access this notification");
        }

        notification.markAsRead();
        notification = notificationRepository.save(notification);

        return NotificationResponse.fromEntity(notification);
    }

    @Transactional
    public int markAllAsRead(User user) {
        return notificationRepository.markAllAsRead(user);
    }
}
