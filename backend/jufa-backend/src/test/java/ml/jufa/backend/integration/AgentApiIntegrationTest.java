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
@DisplayName("Agent API Integration Tests")
class AgentApiIntegrationTest {

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

    private static User agent;
    private static User customer;
    private static Wallet agentWallet;
    private static Wallet customerWallet;
    private static String agentToken;
    private static String customerToken;

    @BeforeAll
    static void setUpAll(@Autowired UserRepository userRepository,
                         @Autowired WalletRepository walletRepository,
                         @Autowired PasswordEncoder passwordEncoder,
                         @Autowired JwtTokenProvider jwtTokenProvider) {
        agent = User.builder()
                .phone("+22370005555")
                .passwordHash(passwordEncoder.encode("password123"))
                .pinHash(passwordEncoder.encode("1234"))
                .userType(UserType.AGENT)
                .status(UserStatus.ACTIVE)
                .build();
        agent = userRepository.save(agent);

        agentWallet = Wallet.builder()
                .user(agent)
                .walletType(WalletType.AGENT)
                .build();
        agentWallet.credit(new BigDecimal("500000"));
        agentWallet = walletRepository.save(agentWallet);

        customer = User.builder()
                .phone("+22370006666")
                .passwordHash(passwordEncoder.encode("password123"))
                .pinHash(passwordEncoder.encode("4321"))
                .userType(UserType.INDIVIDUAL)
                .status(UserStatus.ACTIVE)
                .build();
        customer = userRepository.save(customer);

        customerWallet = Wallet.builder()
                .user(customer)
                .walletType(WalletType.B2C)
                .build();
        customerWallet.credit(new BigDecimal("100000"));
        customerWallet = walletRepository.save(customerWallet);

        agentToken = jwtTokenProvider.generateAccessToken(agent);
        customerToken = jwtTokenProvider.generateAccessToken(customer);
    }

    @AfterAll
    static void tearDown(@Autowired WalletRepository walletRepository,
                         @Autowired UserRepository userRepository) {
        walletRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    @Order(1)
    @DisplayName("GET /v1/agent/dashboard - should return agent dashboard")
    void shouldReturnAgentDashboard() throws Exception {
        mockMvc.perform(get("/v1/agent/dashboard")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.walletBalance").exists());
    }

    @Test
    @Order(2)
    @DisplayName("GET /v1/agent/dashboard - should reject non-agent user")
    void shouldRejectNonAgentUser() throws Exception {
        mockMvc.perform(get("/v1/agent/dashboard")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("JUFA-AGENT-001"));
    }

    @Test
    @Order(3)
    @DisplayName("GET /v1/agent/fees/cash-in - should calculate cash-in fees")
    void shouldCalculateCashInFees() throws Exception {
        mockMvc.perform(get("/v1/agent/fees/cash-in")
                        .param("amount", "10000")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.amount").value(10000))
                .andExpect(jsonPath("$.data.fee").value(100))
                .andExpect(jsonPath("$.data.agentCommission").value(70));
    }

    @Test
    @Order(4)
    @DisplayName("GET /v1/agent/fees/cash-out - should calculate cash-out fees")
    void shouldCalculateCashOutFees() throws Exception {
        mockMvc.perform(get("/v1/agent/fees/cash-out")
                        .param("amount", "10000")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.amount").value(10000))
                .andExpect(jsonPath("$.data.fee").value(150))
                .andExpect(jsonPath("$.data.totalAmount").value(10150))
                .andExpect(jsonPath("$.data.agentCommission").value(105));
    }

    @Test
    @Order(5)
    @DisplayName("POST /v1/agent/cash-in - should process cash-in")
    void shouldProcessCashIn() throws Exception {
        String requestBody = """
            {
                "customerPhone": "%s",
                "amount": 5000,
                "description": "Test deposit"
            }
            """.formatted(customer.getPhone());

        mockMvc.perform(post("/v1/agent/cash-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.transactionType").value("CASH_IN"))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"))
                .andExpect(jsonPath("$.data.amount").value(5000));
    }

    @Test
    @Order(6)
    @DisplayName("POST /v1/agent/cash-in - should reject amount below minimum")
    void shouldRejectCashInBelowMinimum() throws Exception {
        String requestBody = """
            {
                "customerPhone": "%s",
                "amount": 50
            }
            """.formatted(customer.getPhone());

        mockMvc.perform(post("/v1/agent/cash-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("JUFA-AGENT-006"));
    }

    @Test
    @Order(7)
    @DisplayName("POST /v1/agent/cash-in - should reject non-existent customer")
    void shouldRejectNonExistentCustomer() throws Exception {
        String requestBody = """
            {
                "customerPhone": "+22399999999",
                "amount": 5000
            }
            """;

        mockMvc.perform(post("/v1/agent/cash-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("JUFA-AGENT-002"));
    }

    @Test
    @Order(8)
    @DisplayName("POST /v1/agent/cash-out - should process cash-out with valid PIN")
    void shouldProcessCashOut() throws Exception {
        String requestBody = """
            {
                "customerPhone": "%s",
                "amount": 1000,
                "customerPin": "4321",
                "description": "Test withdrawal"
            }
            """.formatted(customer.getPhone());

        mockMvc.perform(post("/v1/agent/cash-out")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.transactionType").value("CASH_OUT"))
                .andExpect(jsonPath("$.data.status").value("COMPLETED"));
    }

    @Test
    @Order(9)
    @DisplayName("POST /v1/agent/cash-out - should reject invalid PIN")
    void shouldRejectInvalidPin() throws Exception {
        String requestBody = """
            {
                "customerPhone": "%s",
                "amount": 1000,
                "customerPin": "0000"
            }
            """.formatted(customer.getPhone());

        mockMvc.perform(post("/v1/agent/cash-out")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody)
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("JUFA-AGENT-003"));
    }

    @Test
    @Order(10)
    @DisplayName("GET /v1/agent/transactions - should return transaction history")
    void shouldReturnTransactionHistory() throws Exception {
        mockMvc.perform(get("/v1/agent/transactions")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content").isArray());
    }

    @Test
    @Order(11)
    @DisplayName("GET /v1/agent/transactions/cash-in - should filter by cash-in type")
    void shouldFilterByCashInType() throws Exception {
        mockMvc.perform(get("/v1/agent/transactions/cash-in")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content").isArray());
    }

    @Test
    @Order(12)
    @DisplayName("GET /v1/agent/reports/last-30-days - should return daily reports")
    void shouldReturnDailyReports() throws Exception {
        mockMvc.perform(get("/v1/agent/reports/last-30-days")
                        .header("Authorization", "Bearer " + agentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data").isArray());
    }
}
