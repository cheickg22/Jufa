package ml.jufa.backend.auth.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.auth.dto.*;
import ml.jufa.backend.auth.service.AuthService;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.user.entity.User;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Map<String, Object>>> register(@Valid @RequestBody RegisterRequest request) {
        Map<String, Object> result = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(result));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        AuthResponse response = authService.verifyOtp(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/verify-pin")
    public ResponseEntity<ApiResponse<Map<String, Object>>> verifyPin(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody VerifyPinRequest request) {
        Map<String, Object> result = authService.verifyPin(user, request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(null, "Logged out successfully"));
    }
}
