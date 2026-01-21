package ml.jufa.backend.auth.service;

import ml.jufa.backend.auth.dto.*;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.config.TestConfig;
import ml.jufa.backend.security.jwt.JwtTokenProvider;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.entity.UserStatus;
import ml.jufa.backend.user.entity.UserType;
import ml.jufa.backend.user.repository.UserRepository;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.repository.WalletRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("AuthService Tests")
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;
    
    @Mock
    private WalletRepository walletRepository;
    
    @Mock
    private PasswordEncoder passwordEncoder;
    
    @Mock
    private JwtTokenProvider jwtTokenProvider;
    
    @Mock
    private AuthenticationManager authenticationManager;

    @InjectMocks
    private AuthService authService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = TestConfig.createTestUser();
    }

    @Nested
    @DisplayName("register")
    class RegisterTests {

        @Test
        @DisplayName("should register new user successfully")
        void shouldRegisterNewUserSuccessfully() {
            RegisterRequest request = new RegisterRequest();
            request.setPhone("+22370001234");
            request.setPassword("password123");
            request.setUserType(UserType.INDIVIDUAL);

            when(userRepository.existsByPhone(request.getPhone())).thenReturn(false);
            when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
            when(userRepository.save(any(User.class))).thenAnswer(inv -> {
                User u = inv.getArgument(0);
                u.setId(UUID.randomUUID());
                return u;
            });

            Map<String, Object> result = authService.register(request);

            assertThat(result).containsKey("userId");
            assertThat(result).containsEntry("phone", "+22370001234");
            assertThat(result).containsEntry("message", "OTP sent via SMS");
            
            ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
            verify(userRepository).save(userCaptor.capture());
            assertThat(userCaptor.getValue().getStatus()).isEqualTo(UserStatus.PENDING);
        }

        @Test
        @DisplayName("should throw exception when phone already registered")
        void shouldThrowExceptionWhenPhoneAlreadyRegistered() {
            RegisterRequest request = new RegisterRequest();
            request.setPhone("+22370001234");
            request.setPassword("password123");

            when(userRepository.existsByPhone(request.getPhone())).thenReturn(true);

            assertThatThrownBy(() -> authService.register(request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("already registered");
            
            verify(userRepository, never()).save(any());
        }
    }

    @Nested
    @DisplayName("login")
    class LoginTests {

        @Test
        @DisplayName("should login successfully with valid credentials")
        void shouldLoginSuccessfully() {
            LoginRequest request = new LoginRequest();
            request.setPhone("+22370000001");
            request.setPassword("password123");

            when(userRepository.findByPhone(request.getPhone())).thenReturn(Optional.of(testUser));
            when(jwtTokenProvider.generateAccessToken(testUser)).thenReturn("access-token");
            when(jwtTokenProvider.generateRefreshToken(testUser)).thenReturn("refresh-token");
            when(jwtTokenProvider.getAccessTokenExpiration()).thenReturn(900000L);

            AuthResponse result = authService.login(request);

            assertThat(result.getAccessToken()).isEqualTo("access-token");
            assertThat(result.getRefreshToken()).isEqualTo("refresh-token");
            assertThat(result.getUser().getPhone()).isEqualTo("+22370000001");
            
            verify(authenticationManager).authenticate(any(UsernamePasswordAuthenticationToken.class));
        }

        @Test
        @DisplayName("should throw exception when credentials are invalid")
        void shouldThrowExceptionWhenCredentialsInvalid() {
            LoginRequest request = new LoginRequest();
            request.setPhone("+22370000001");
            request.setPassword("wrongPassword");

            doThrow(new BadCredentialsException("Bad credentials"))
                    .when(authenticationManager).authenticate(any());

            assertThatThrownBy(() -> authService.login(request))
                    .isInstanceOf(BadCredentialsException.class);
        }

        @Test
        @DisplayName("should throw exception when account is not active")
        void shouldThrowExceptionWhenAccountNotActive() {
            testUser.setStatus(UserStatus.SUSPENDED);
            
            LoginRequest request = new LoginRequest();
            request.setPhone("+22370000001");
            request.setPassword("password123");

            when(userRepository.findByPhone(request.getPhone())).thenReturn(Optional.of(testUser));

            assertThatThrownBy(() -> authService.login(request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("not active");
        }
    }

    @Nested
    @DisplayName("verifyOtp")
    class VerifyOtpTests {

        @Test
        @DisplayName("should verify OTP and activate user")
        void shouldVerifyOtpAndActivateUser() throws Exception {
            RegisterRequest registerRequest = new RegisterRequest();
            registerRequest.setPhone("+22370009999");
            registerRequest.setPassword("password123");
            registerRequest.setUserType(UserType.INDIVIDUAL);
            
            User pendingUser = new User();
            pendingUser.setId(UUID.randomUUID());
            pendingUser.setPhone(registerRequest.getPhone());
            pendingUser.setStatus(UserStatus.PENDING);
            pendingUser.setUserType(UserType.INDIVIDUAL);

            when(userRepository.existsByPhone(anyString())).thenReturn(false);
            when(passwordEncoder.encode(anyString())).thenReturn("encoded");
            when(userRepository.save(any(User.class))).thenAnswer(inv -> {
                User u = inv.getArgument(0);
                u.setId(pendingUser.getId());
                return u;
            });
            
            Map<String, Object> registerResult = authService.register(registerRequest);
            UUID userId = (UUID) registerResult.get("userId");

            when(userRepository.findById(userId)).thenReturn(Optional.of(pendingUser));
            when(walletRepository.save(any(Wallet.class))).thenAnswer(inv -> inv.getArgument(0));
            when(jwtTokenProvider.generateAccessToken(any())).thenReturn("access-token");
            when(jwtTokenProvider.generateRefreshToken(any())).thenReturn("refresh-token");
            when(jwtTokenProvider.getAccessTokenExpiration()).thenReturn(900000L);

            VerifyOtpRequest otpRequest = new VerifyOtpRequest();
            otpRequest.setUserId(userId);
            
            java.lang.reflect.Field otpField = AuthService.class.getDeclaredField("otpStorage");
            otpField.setAccessible(true);
            @SuppressWarnings("unchecked")
            Map<UUID, String> otpStorage = (Map<UUID, String>) otpField.get(authService);
            otpStorage.put(userId, "123456");
            otpRequest.setOtp("123456");

            AuthResponse result = authService.verifyOtp(otpRequest);

            assertThat(result.getAccessToken()).isEqualTo("access-token");
            assertThat(pendingUser.getStatus()).isEqualTo(UserStatus.ACTIVE);
            verify(walletRepository).save(any(Wallet.class));
        }

        @Test
        @DisplayName("should throw exception for invalid OTP")
        void shouldThrowExceptionForInvalidOtp() {
            VerifyOtpRequest request = new VerifyOtpRequest();
            request.setUserId(UUID.randomUUID());
            request.setOtp("000000");

            assertThatThrownBy(() -> authService.verifyOtp(request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Invalid or expired OTP");
        }
    }

    @Nested
    @DisplayName("verifyPin")
    class VerifyPinTests {

        @Test
        @DisplayName("should verify PIN successfully")
        void shouldVerifyPinSuccessfully() {
            testUser.setPinHash("encodedPin");
            VerifyPinRequest request = new VerifyPinRequest();
            request.setPin("1234");

            when(passwordEncoder.matches("1234", "encodedPin")).thenReturn(true);

            Map<String, Object> result = authService.verifyPin(testUser, request);

            assertThat(result).containsKey("tempToken");
            assertThat(result).containsEntry("expiresIn", 300);
        }

        @Test
        @DisplayName("should throw exception when PIN not set")
        void shouldThrowExceptionWhenPinNotSet() {
            testUser.setPinHash(null);
            VerifyPinRequest request = new VerifyPinRequest();
            request.setPin("1234");

            assertThatThrownBy(() -> authService.verifyPin(testUser, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("PIN not set");
        }

        @Test
        @DisplayName("should throw exception for invalid PIN")
        void shouldThrowExceptionForInvalidPin() {
            testUser.setPinHash("encodedPin");
            VerifyPinRequest request = new VerifyPinRequest();
            request.setPin("0000");

            when(passwordEncoder.matches("0000", "encodedPin")).thenReturn(false);

            assertThatThrownBy(() -> authService.verifyPin(testUser, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Invalid PIN");
        }
    }

    @Nested
    @DisplayName("refreshToken")
    class RefreshTokenTests {

        @Test
        @DisplayName("should refresh token successfully")
        void shouldRefreshTokenSuccessfully() {
            RefreshTokenRequest request = new RefreshTokenRequest();
            request.setRefreshToken("valid-refresh-token");

            when(jwtTokenProvider.validateToken("valid-refresh-token")).thenReturn(true);
            when(jwtTokenProvider.getTokenType("valid-refresh-token")).thenReturn("refresh");
            when(jwtTokenProvider.getUserIdFromToken("valid-refresh-token")).thenReturn(testUser.getId().toString());
            when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
            when(jwtTokenProvider.generateAccessToken(testUser)).thenReturn("new-access-token");
            when(jwtTokenProvider.getAccessTokenExpiration()).thenReturn(900000L);

            AuthResponse result = authService.refreshToken(request);

            assertThat(result.getAccessToken()).isEqualTo("new-access-token");
        }

        @Test
        @DisplayName("should throw exception for invalid refresh token")
        void shouldThrowExceptionForInvalidRefreshToken() {
            RefreshTokenRequest request = new RefreshTokenRequest();
            request.setRefreshToken("invalid-token");

            when(jwtTokenProvider.validateToken("invalid-token")).thenReturn(false);

            assertThatThrownBy(() -> authService.refreshToken(request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Invalid refresh token");
        }
    }
}
