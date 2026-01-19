package ml.jufa.backend.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.user.entity.KycLevel;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.entity.UserStatus;
import ml.jufa.backend.user.entity.UserType;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    
    private UUID id;
    private String phone;
    private String email;
    private UserType userType;
    private UserStatus status;
    private KycLevel kycLevel;
    private ProfileDto profile;
    private LocalDateTime createdAt;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProfileDto {
        private String firstName;
        private String lastName;
        private String businessName;
        private String city;
        private String address;
        private String profilePhotoUrl;
    }
    
    public static UserResponse fromEntity(User user) {
        UserResponseBuilder builder = UserResponse.builder()
            .id(user.getId())
            .phone(user.getPhone())
            .email(user.getEmail())
            .userType(user.getUserType())
            .status(user.getStatus())
            .kycLevel(user.getKycLevel())
            .createdAt(user.getCreatedAt());
        
        if (user.getProfile() != null) {
            builder.profile(ProfileDto.builder()
                .firstName(user.getProfile().getFirstName())
                .lastName(user.getProfile().getLastName())
                .businessName(user.getProfile().getBusinessName())
                .city(user.getProfile().getCity())
                .address(user.getProfile().getAddress())
                .profilePhotoUrl(user.getProfile().getProfilePhotoUrl())
                .build());
        }
        
        return builder.build();
    }
}
