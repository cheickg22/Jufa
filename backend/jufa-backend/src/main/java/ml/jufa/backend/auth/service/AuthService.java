package ml.jufa.backend.auth.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.auth.dto.*;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import ml.jufa.backend.merchant.entity.MerchantType;
import ml.jufa.backend.merchant.repository.MerchantProfileRepository;
import ml.jufa.backend.security.jwt.JwtTokenProvider;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.entity.UserStatus;
import ml.jufa.backend.user.entity.UserType;
import ml.jufa.backend.user.repository.UserRepository;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import ml.jufa.backend.wallet.repository.WalletRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final MerchantProfileRepository merchantProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;
    
    private final Map<UUID, String> otpStorage = new ConcurrentHashMap<>();
    private final Map<UUID, String> pinTokenStorage = new ConcurrentHashMap<>();

    @Transactional
    public Map<String, Object> register(RegisterRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new JufaException("JUFA-AUTH-006", "Phone number already registered");
        }

        User user = User.builder()
            .phone(request.getPhone())
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .userType(request.getUserType())
            .status(UserStatus.PENDING)
            .build();

        user = userRepository.save(user);

        String otp = generateOtp();
        otpStorage.put(user.getId(), otp);
        
        log.info("OTP for user {}: {}", user.getPhone(), otp);

        return Map.of(
            "userId", user.getId(),
            "phone", user.getPhone(),
            "message", "OTP sent via SMS"
        );
    }

    @Transactional
    public AuthResponse verifyOtp(VerifyOtpRequest request) {
        String storedOtp = otpStorage.get(request.getUserId());
        
        if (storedOtp == null || !storedOtp.equals(request.getOtp())) {
            throw new JufaException("JUFA-AUTH-002", "Invalid or expired OTP");
        }

        User user = userRepository.findById(request.getUserId())
            .orElseThrow(() -> new JufaException("JUFA-USER-001", "User not found"));

        user.setStatus(UserStatus.ACTIVE);
        userRepository.save(user);

        createDefaultWallet(user);

        if (user.getUserType() == UserType.WHOLESALER || user.getUserType() == UserType.RETAILER) {
            createMerchantProfile(user);
        }

        otpStorage.remove(request.getUserId());

        return buildAuthResponse(user);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.getPhone(), request.getPassword())
        );

        User user = userRepository.findByPhone(request.getPhone())
            .orElseThrow(() -> new JufaException("JUFA-AUTH-001", "Invalid credentials"));

        if (user.getStatus() != UserStatus.ACTIVE) {
            throw new JufaException("JUFA-AUTH-005", "Account is not active");
        }

        return buildAuthResponse(user);
    }

    public AuthResponse refreshToken(RefreshTokenRequest request) {
        if (!jwtTokenProvider.validateToken(request.getRefreshToken())) {
            throw new JufaException("JUFA-AUTH-003", "Invalid refresh token");
        }

        String tokenType = jwtTokenProvider.getTokenType(request.getRefreshToken());
        if (!"refresh".equals(tokenType)) {
            throw new JufaException("JUFA-AUTH-003", "Invalid token type");
        }

        String userId = jwtTokenProvider.getUserIdFromToken(request.getRefreshToken());
        User user = userRepository.findById(UUID.fromString(userId))
            .orElseThrow(() -> new JufaException("JUFA-USER-001", "User not found"));

        String newAccessToken = jwtTokenProvider.generateAccessToken(user);

        return AuthResponse.builder()
            .accessToken(newAccessToken)
            .expiresIn(jwtTokenProvider.getAccessTokenExpiration() / 1000)
            .build();
    }

    public Map<String, Object> verifyPin(User user, VerifyPinRequest request) {
        if (user.getPinHash() == null) {
            throw new JufaException("JUFA-AUTH-007", "PIN not set");
        }

        if (!passwordEncoder.matches(request.getPin(), user.getPinHash())) {
            throw new JufaException("JUFA-AUTH-004", "Invalid PIN");
        }

        String tempToken = UUID.randomUUID().toString();
        pinTokenStorage.put(user.getId(), tempToken);

        return Map.of(
            "tempToken", tempToken,
            "expiresIn", 300
        );
    }

    public boolean validatePinToken(UUID userId, String tempToken) {
        String stored = pinTokenStorage.get(userId);
        return stored != null && stored.equals(tempToken);
    }

    private void createDefaultWallet(User user) {
        WalletType walletType = switch (user.getUserType()) {
            case MERCHANT, WHOLESALER, RETAILER -> WalletType.B2B;
            case AGENT -> WalletType.AGENT;
            default -> WalletType.B2C;
        };

        Wallet wallet = Wallet.builder()
            .user(user)
            .walletType(walletType)
            .build();

        walletRepository.save(wallet);
        log.info("Wallet created for user {} with type {}", user.getPhone(), walletType);
    }

    private void createMerchantProfile(User user) {
        MerchantType merchantType = user.getUserType() == UserType.WHOLESALER 
            ? MerchantType.WHOLESALER 
            : MerchantType.RETAILER;
        
        MerchantProfile profile = MerchantProfile.builder()
            .user(user)
            .merchantType(merchantType)
            .businessName(user.getPhone())
            .verified(false)
            .build();
        
        merchantProfileRepository.save(profile);
        log.info("Merchant profile created for user {} as {}", user.getPhone(), merchantType);
    }

    private AuthResponse buildAuthResponse(User user) {
        String accessToken = jwtTokenProvider.generateAccessToken(user);
        String refreshToken = jwtTokenProvider.generateRefreshToken(user);

        return AuthResponse.builder()
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .expiresIn(jwtTokenProvider.getAccessTokenExpiration() / 1000)
            .user(AuthResponse.UserDto.builder()
                .id(user.getId())
                .phone(user.getPhone())
                .email(user.getEmail())
                .userType(user.getUserType())
                .status(user.getStatus())
                .kycLevel(user.getKycLevel())
                .build())
            .build();
    }

    private String generateOtp() {
        SecureRandom random = new SecureRandom();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}
