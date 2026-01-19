package ml.jufa.backend.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.notification.entity.Notification;
import ml.jufa.backend.notification.entity.NotificationType;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {
    private UUID id;
    private NotificationType type;
    private String title;
    private String body;
    private String data;
    private boolean read;
    private LocalDateTime readAt;
    private String referenceId;
    private LocalDateTime createdAt;

    public static NotificationResponse fromEntity(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .type(notification.getType())
                .title(notification.getTitle())
                .body(notification.getBody())
                .data(notification.getData())
                .read(notification.isRead())
                .readAt(notification.getReadAt())
                .referenceId(notification.getReferenceId())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
