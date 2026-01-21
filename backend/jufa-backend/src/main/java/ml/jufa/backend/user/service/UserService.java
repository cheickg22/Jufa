package ml.jufa.backend.user.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.user.dto.UpdateProfileRequest;
import ml.jufa.backend.user.dto.UserResponse;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.entity.UserProfile;
import ml.jufa.backend.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;

    public UserResponse getCurrentUser(User user) {
        return UserResponse.fromEntity(user);
    }

    @Transactional
    public UserResponse updateProfile(User user, UpdateProfileRequest request) {
        UserProfile profile = user.getProfile();
        
        if (profile == null) {
            profile = new UserProfile();
            profile.setUser(user);
            user.setProfile(profile);
        }

        if (request.getFirstName() != null) {
            profile.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            profile.setLastName(request.getLastName());
        }
        if (request.getEmail() != null) {
            if (userRepository.existsByEmailAndIdNot(request.getEmail(), user.getId())) {
                throw new JufaException("JUFA-USER-002", "Email already in use");
            }
            user.setEmail(request.getEmail());
        }
        if (request.getBusinessName() != null) {
            profile.setBusinessName(request.getBusinessName());
        }
        if (request.getCity() != null) {
            profile.setCity(request.getCity());
        }
        if (request.getAddress() != null) {
            profile.setAddress(request.getAddress());
        }

        userRepository.save(user);
        
        log.info("Profile updated for user {}", user.getPhone());
        
        return UserResponse.fromEntity(user);
    }
}
