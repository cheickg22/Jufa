package ml.jufa.backend.user.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.user.dto.UpdateProfileRequest;
import ml.jufa.backend.user.dto.UserResponse;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(
            @AuthenticationPrincipal User user) {
        UserResponse response = userService.getCurrentUser(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/me/profile")
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @Valid @RequestBody UpdateProfileRequest request,
            @AuthenticationPrincipal User user) {
        UserResponse response = userService.updateProfile(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Profile updated successfully"));
    }
}
