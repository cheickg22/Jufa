package ml.jufa.backend.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.user.entity.KycLevel;
import ml.jufa.backend.user.entity.UserStatus;
import ml.jufa.backend.user.entity.UserType;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    
    private String accessToken;
    private String refreshToken;
    private long expiresIn;
    private UserDto user;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserDto {
        private UUID id;
        private String phone;
        private String email;
        private UserType userType;
        private UserStatus status;
        private KycLevel kycLevel;
    }
}
