package ml.jufa.backend.integration;

import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.entity.UserStatus;
import ml.jufa.backend.user.entity.UserType;
import ml.jufa.backend.user.repository.UserRepository;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import ml.jufa.backend.wallet.repository.WalletRepository;
import ml.jufa.backend.security.jwt.JwtTokenProvider;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.math.BigDecimal;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("Wallet API Integration Tests")
class WalletApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WalletRepository walletRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private static User testUser;
    private static Wallet testWallet;
    private static String accessToken;

    @BeforeAll
    static void setUpAll(@Autowired UserRepository userRepository,
                         @Autowired WalletRepository walletRepository,
                         @Autowired PasswordEncoder passwordEncoder,
                         @Autowired JwtTokenProvider jwtTokenProvider) {
        testUser = User.builder()
                .phone("+22370003333")
                .passwordHash(passwordEncoder.encode("password123"))
                .userType(UserType.INDIVIDUAL)
                .status(UserStatus.ACTIVE)
                .build();
        testUser = userRepository.save(testUser);

        testWallet = Wallet.builder()
                .user(testUser)
                .walletType(WalletType.B2C)
                .build();
        testWallet.credit(new BigDecimal("25000"));
        testWallet = walletRepository.save(testWallet);

        accessToken = jwtTokenProvider.generateAccessToken(testUser);
    }

    @AfterAll
    static void tearDown(@Autowired WalletRepository walletRepository,
                         @Autowired UserRepository userRepository) {
        walletRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    @Order(1)
    @DisplayName("GET /v1/wallets - should return user wallets")
    void shouldReturnUserWallets() throws Exception {
        mockMvc.perform(get("/v1/wallets")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data[0].walletType").value("B2C"))
                .andExpect(jsonPath("$.data[0].balance").value(25000));
    }

    @Test
    @Order(2)
    @DisplayName("GET /v1/wallets/{id} - should return wallet by id")
    void shouldReturnWalletById() throws Exception {
        mockMvc.perform(get("/v1/wallets/" + testWallet.getId())
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(testWallet.getId().toString()))
                .andExpect(jsonPath("$.data.balance").value(25000));
    }

    @Test
    @Order(3)
    @DisplayName("GET /v1/wallets - should reject unauthorized request")
    void shouldRejectUnauthorizedRequest() throws Exception {
        mockMvc.perform(get("/v1/wallets"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @Order(4)
    @DisplayName("GET /v1/wallets - should reject invalid token")
    void shouldRejectInvalidToken() throws Exception {
        mockMvc.perform(get("/v1/wallets")
                        .header("Authorization", "Bearer invalid-token"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @Order(5)
    @DisplayName("GET /v1/wallets/{id} - should reject access to other user wallet")
    void shouldRejectAccessToOtherUserWallet() throws Exception {
        User otherUser = User.builder()
                .phone("+22370004444")
                .passwordHash(passwordEncoder.encode("password123"))
                .userType(UserType.INDIVIDUAL)
                .status(UserStatus.ACTIVE)
                .build();
        otherUser = userRepository.save(otherUser);

        Wallet otherWallet = Wallet.builder()
                .user(otherUser)
                .walletType(WalletType.B2C)
                .build();
        otherWallet = walletRepository.save(otherWallet);

        mockMvc.perform(get("/v1/wallets/" + otherWallet.getId())
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("JUFA-WALLET-002"));
    }

    @Test
    @Order(6)
    @DisplayName("GET /v1/wallets/{id} - should return 400 for non-existent wallet")
    void shouldReturn400ForNonExistentWallet() throws Exception {
        mockMvc.perform(get("/v1/wallets/" + java.util.UUID.randomUUID())
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("JUFA-WALLET-001"));
    }
}
