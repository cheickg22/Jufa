package ml.jufa.backend.notification.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.notification.dto.NotificationResponse;
import ml.jufa.backend.notification.dto.RegisterFcmTokenRequest;
import ml.jufa.backend.notification.service.NotificationService;
import ml.jufa.backend.notification.service.PushNotificationService;
import ml.jufa.backend.user.entity.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final PushNotificationService pushNotificationService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> getNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Boolean unreadOnly,
            @AuthenticationPrincipal User user) {
        List<NotificationResponse> notifications = notificationService.getNotifications(user, page, size, unreadOnly);
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUnreadCount(
            @AuthenticationPrincipal User user) {
        long count = notificationService.getUnreadCount(user);
        return ResponseEntity.ok(ApiResponse.success(Map.of("count", count)));
    }

    @PostMapping("/{notificationId}/read")
    public ResponseEntity<ApiResponse<NotificationResponse>> markAsRead(
            @PathVariable UUID notificationId,
            @AuthenticationPrincipal User user) {
        NotificationResponse notification = notificationService.markAsRead(user, notificationId);
        return ResponseEntity.ok(ApiResponse.success(notification, "Notification marked as read"));
    }

    @PostMapping("/read-all")
    public ResponseEntity<ApiResponse<Map<String, Integer>>> markAllAsRead(
            @AuthenticationPrincipal User user) {
        int count = notificationService.markAllAsRead(user);
        return ResponseEntity.ok(ApiResponse.success(Map.of("markedCount", count), "All notifications marked as read"));
    }

    @PostMapping("/fcm-token")
    public ResponseEntity<ApiResponse<Void>> registerFcmToken(
            @Valid @RequestBody RegisterFcmTokenRequest request,
            @AuthenticationPrincipal User user) {
        pushNotificationService.registerFcmToken(user, request.getFcmToken());
        return ResponseEntity.ok(ApiResponse.success(null, "FCM token registered successfully"));
    }
}
