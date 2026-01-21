package ml.jufa.backend.notification.repository;

import ml.jufa.backend.notification.entity.Notification;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    Page<Notification> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);

    Page<Notification> findByUserAndReadOrderByCreatedAtDesc(User user, boolean read, Pageable pageable);

    long countByUserAndRead(User user, boolean read);

    @Modifying
    @Query("UPDATE Notification n SET n.read = true, n.readAt = CURRENT_TIMESTAMP WHERE n.user = :user AND n.read = false")
    int markAllAsRead(@Param("user") User user);
}
