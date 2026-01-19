package ml.jufa.backend.notification.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterFcmTokenRequest {
    @NotBlank(message = "FCM token is required")
    private String fcmToken;
}
