package ml.jufa.backend.notification.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications", indexes = {
    @Index(name = "idx_notification_user_read", columnList = "user_id, read"),
    @Index(name = "idx_notification_created", columnList = "created_at DESC")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String body;

    @Column(columnDefinition = "TEXT")
    private String data;

    @Column(name = "read", nullable = false)
    @Builder.Default
    private boolean read = false;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    @Column(name = "push_sent")
    @Builder.Default
    private boolean pushSent = false;

    @Column(name = "push_sent_at")
    private LocalDateTime pushSentAt;

    @Column(name = "reference_id")
    private String referenceId;

    public void markAsRead() {
        this.read = true;
        this.readAt = LocalDateTime.now();
    }
}
