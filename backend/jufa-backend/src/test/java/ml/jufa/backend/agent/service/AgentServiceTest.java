package ml.jufa.backend.agent.service;

import ml.jufa.backend.agent.dto.*;
import ml.jufa.backend.agent.entity.*;
import ml.jufa.backend.agent.repository.*;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.config.TestConfig;
import ml.jufa.backend.notification.service.PushNotificationService;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.repository.UserRepository;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import ml.jufa.backend.wallet.repository.WalletRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("AgentService Tests")
class AgentServiceTest {

    @Mock
    private AgentTransactionRepository transactionRepository;
    @Mock
    private AgentCommissionRepository commissionRepository;
    @Mock
    private AgentDailyReportRepository reportRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private WalletRepository walletRepository;
    @Mock
    private PushNotificationService pushNotificationService;
    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AgentService agentService;

    private User agent;
    private User customer;
    private Wallet agentWallet;
    private Wallet customerWallet;
    private Wallet commissionWallet;

    @BeforeEach
    void setUp() {
        agent = TestConfig.createTestAgent();
        customer = TestConfig.createTestUser();
        agentWallet = TestConfig.createTestWalletWithBalance(agent, WalletType.AGENT, new BigDecimal("100000"));
        customerWallet = TestConfig.createTestWalletWithBalance(customer, WalletType.B2C, new BigDecimal("50000"));
        commissionWallet = TestConfig.createTestWallet(agent, WalletType.COMMISSION);
    }

    private void mockTransactionSaveWithId() {
        when(transactionRepository.save(any())).thenAnswer(inv -> {
            AgentTransaction tx = inv.getArgument(0);
            if (tx.getId() == null) {
                try {
                    java.lang.reflect.Field idField = tx.getClass().getSuperclass().getDeclaredField("id");
                    idField.setAccessible(true);
                    idField.set(tx, UUID.randomUUID());
                } catch (Exception ignored) {}
            }
            return tx;
        });
    }

    @Nested
    @DisplayName("processCashIn")
    class ProcessCashInTests {

        @Test
        @DisplayName("should process cash-in successfully")
        void shouldProcessCashInSuccessfully() {
            CashInRequest request = new CashInRequest();
            request.setCustomerPhone(customer.getPhone());
            request.setAmount(new BigDecimal("10000"));

            when(userRepository.findByPhone(customer.getPhone())).thenReturn(Optional.of(customer));
            when(walletRepository.findByUserAndWalletType(customer, WalletType.B2C))
                    .thenReturn(Optional.of(customerWallet));
            when(walletRepository.findWithLockById(customerWallet.getId()))
                    .thenReturn(Optional.of(customerWallet));
            when(walletRepository.findByUserAndWalletType(agent, WalletType.COMMISSION))
                    .thenReturn(Optional.of(commissionWallet));
            when(walletRepository.findWithLockById(commissionWallet.getId()))
                    .thenReturn(Optional.of(commissionWallet));
            mockTransactionSaveWithId();
            when(walletRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
            when(commissionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
            when(reportRepository.findByAgentAndReportDate(any(), any())).thenReturn(Optional.empty());
            when(reportRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

            AgentTransactionResponse result = agentService.processCashIn(agent, request);

            assertThat(result).isNotNull();
            assertThat(result.getAmount()).isEqualByComparingTo(new BigDecimal("10000"));
            assertThat(result.getTransactionType()).isEqualTo(AgentTransactionType.CASH_IN);
            assertThat(result.getStatus()).isEqualTo(AgentTransactionStatus.COMPLETED);
            
            verify(walletRepository, times(2)).save(any(Wallet.class));
            verify(pushNotificationService).sendTransactionReceived(eq(customer), any(), any(), any());
        }

        @Test
        @DisplayName("should throw exception when user is not an agent")
        void shouldThrowExceptionWhenNotAgent() {
            User notAgent = TestConfig.createTestUser();
            CashInRequest request = new CashInRequest();
            request.setAmount(new BigDecimal("10000"));

            assertThatThrownBy(() -> agentService.processCashIn(notAgent, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("réservé aux agents");
        }

        @Test
        @DisplayName("should throw exception when amount is below minimum")
        void shouldThrowExceptionWhenAmountBelowMinimum() {
            CashInRequest request = new CashInRequest();
            request.setAmount(new BigDecimal("50"));

            assertThatThrownBy(() -> agentService.processCashIn(agent, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Montant minimum");
        }

        @Test
        @DisplayName("should throw exception when amount exceeds maximum")
        void shouldThrowExceptionWhenAmountExceedsMaximum() {
            CashInRequest request = new CashInRequest();
            request.setAmount(new BigDecimal("10000000"));

            assertThatThrownBy(() -> agentService.processCashIn(agent, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Montant maximum");
        }

        @Test
        @DisplayName("should throw exception when customer not found")
        void shouldThrowExceptionWhenCustomerNotFound() {
            CashInRequest request = new CashInRequest();
            request.setCustomerPhone("+22399999999");
            request.setAmount(new BigDecimal("10000"));

            when(userRepository.findByPhone(request.getCustomerPhone())).thenReturn(Optional.empty());

            assertThatThrownBy(() -> agentService.processCashIn(agent, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Client non trouvé");
        }
    }

    @Nested
    @DisplayName("processCashOut")
    class ProcessCashOutTests {

        @Test
        @DisplayName("should process cash-out successfully")
        void shouldProcessCashOutSuccessfully() {
            customer.setPinHash("encodedPin");
            
            CashOutRequest request = new CashOutRequest();
            request.setCustomerPhone(customer.getPhone());
            request.setAmount(new BigDecimal("5000"));
            request.setCustomerPin("1234");

            when(userRepository.findByPhone(customer.getPhone())).thenReturn(Optional.of(customer));
            when(passwordEncoder.matches("1234", "encodedPin")).thenReturn(true);
            when(walletRepository.findByUserAndWalletType(agent, WalletType.AGENT))
                    .thenReturn(Optional.of(agentWallet));
            when(walletRepository.findByUserAndWalletType(customer, WalletType.B2C))
                    .thenReturn(Optional.of(customerWallet));
            when(walletRepository.findWithLockById(customerWallet.getId()))
                    .thenReturn(Optional.of(customerWallet));
            when(walletRepository.findByUserAndWalletType(agent, WalletType.COMMISSION))
                    .thenReturn(Optional.of(commissionWallet));
            when(walletRepository.findWithLockById(commissionWallet.getId()))
                    .thenReturn(Optional.of(commissionWallet));
            mockTransactionSaveWithId();
            when(walletRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
            when(commissionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
            when(reportRepository.findByAgentAndReportDate(any(), any())).thenReturn(Optional.empty());
            when(reportRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

            AgentTransactionResponse result = agentService.processCashOut(agent, request);

            assertThat(result).isNotNull();
            assertThat(result.getTransactionType()).isEqualTo(AgentTransactionType.CASH_OUT);
            assertThat(result.getStatus()).isEqualTo(AgentTransactionStatus.COMPLETED);
        }

        @Test
        @DisplayName("should throw exception when PIN is incorrect")
        void shouldThrowExceptionWhenPinIncorrect() {
            customer.setPinHash("encodedPin");
            
            CashOutRequest request = new CashOutRequest();
            request.setCustomerPhone(customer.getPhone());
            request.setAmount(new BigDecimal("5000"));
            request.setCustomerPin("0000");

            when(userRepository.findByPhone(customer.getPhone())).thenReturn(Optional.of(customer));
            when(passwordEncoder.matches("0000", "encodedPin")).thenReturn(false);

            assertThatThrownBy(() -> agentService.processCashOut(agent, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("PIN incorrect");
        }

        @Test
        @DisplayName("should throw exception when agent balance insufficient")
        void shouldThrowExceptionWhenAgentBalanceInsufficient() {
            customer.setPinHash("encodedPin");
            agentWallet = TestConfig.createTestWalletWithBalance(agent, WalletType.AGENT, new BigDecimal("1000"));
            
            CashOutRequest request = new CashOutRequest();
            request.setCustomerPhone(customer.getPhone());
            request.setAmount(new BigDecimal("500000"));
            request.setCustomerPin("1234");

            when(userRepository.findByPhone(customer.getPhone())).thenReturn(Optional.of(customer));
            when(passwordEncoder.matches("1234", "encodedPin")).thenReturn(true);
            when(walletRepository.findByUserAndWalletType(agent, WalletType.AGENT))
                    .thenReturn(Optional.of(agentWallet));

            assertThatThrownBy(() -> agentService.processCashOut(agent, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Solde agent insuffisant");
        }

        @Test
        @DisplayName("should throw exception when customer balance insufficient")
        void shouldThrowExceptionWhenCustomerBalanceInsufficient() {
            customer.setPinHash("encodedPin");
            customerWallet = TestConfig.createTestWalletWithBalance(customer, WalletType.B2C, new BigDecimal("1000"));
            
            CashOutRequest request = new CashOutRequest();
            request.setCustomerPhone(customer.getPhone());
            request.setAmount(new BigDecimal("50000"));
            request.setCustomerPin("1234");

            when(userRepository.findByPhone(customer.getPhone())).thenReturn(Optional.of(customer));
            when(passwordEncoder.matches("1234", "encodedPin")).thenReturn(true);
            when(walletRepository.findByUserAndWalletType(agent, WalletType.AGENT))
                    .thenReturn(Optional.of(agentWallet));
            when(walletRepository.findByUserAndWalletType(customer, WalletType.B2C))
                    .thenReturn(Optional.of(customerWallet));

            assertThatThrownBy(() -> agentService.processCashOut(agent, request))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Solde client insuffisant");
        }
    }

    @Nested
    @DisplayName("calculateFees")
    class CalculateFeesTests {

        @Test
        @DisplayName("should calculate cash-in fees correctly (1%)")
        void shouldCalculateCashInFeesCorrectly() {
            FeeCalculationResponse result = agentService.calculateCashInFees(new BigDecimal("10000"));

            assertThat(result.getAmount()).isEqualByComparingTo(new BigDecimal("10000"));
            assertThat(result.getFee()).isEqualByComparingTo(new BigDecimal("100"));
            assertThat(result.getAgentCommission()).isEqualByComparingTo(new BigDecimal("70"));
        }

        @Test
        @DisplayName("should calculate cash-out fees correctly (1.5%)")
        void shouldCalculateCashOutFeesCorrectly() {
            FeeCalculationResponse result = agentService.calculateCashOutFees(new BigDecimal("10000"));

            assertThat(result.getAmount()).isEqualByComparingTo(new BigDecimal("10000"));
            assertThat(result.getFee()).isEqualByComparingTo(new BigDecimal("150"));
            assertThat(result.getTotalAmount()).isEqualByComparingTo(new BigDecimal("10150"));
            assertThat(result.getAgentCommission()).isEqualByComparingTo(new BigDecimal("105"));
        }
    }

    @Nested
    @DisplayName("getDashboard")
    class GetDashboardTests {

        @Test
        @DisplayName("should return dashboard with statistics")
        void shouldReturnDashboardWithStatistics() {
            when(walletRepository.findByUserAndWalletType(agent, WalletType.AGENT))
                    .thenReturn(Optional.of(agentWallet));
            when(walletRepository.findByUserAndWalletType(agent, WalletType.COMMISSION))
                    .thenReturn(Optional.of(commissionWallet));
            when(transactionRepository.sumAmountByAgentAndTypeAndDateAfter(any(), any(), any()))
                    .thenReturn(new BigDecimal("50000"));
            when(transactionRepository.countCompletedByAgentAfter(any(), any())).thenReturn(10L);
            when(transactionRepository.sumCommissionByAgentAfter(any(), any()))
                    .thenReturn(new BigDecimal("500"));
            when(commissionRepository.sumTotalCommissionByAgent(agent))
                    .thenReturn(new BigDecimal("5000"));
            when(transactionRepository.countByAgentAndStatus(agent, AgentTransactionStatus.PENDING))
                    .thenReturn(0L);

            AgentDashboardResponse result = agentService.getDashboard(agent);

            assertThat(result).isNotNull();
            assertThat(result.getWalletBalance()).isEqualByComparingTo(new BigDecimal("100000"));
            assertThat(result.getTotalCommissionEarned()).isEqualByComparingTo(new BigDecimal("5000"));
        }

        @Test
        @DisplayName("should throw exception when not agent")
        void shouldThrowExceptionWhenNotAgent() {
            User notAgent = TestConfig.createTestUser();

            assertThatThrownBy(() -> agentService.getDashboard(notAgent))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("réservé aux agents");
        }
    }
}
