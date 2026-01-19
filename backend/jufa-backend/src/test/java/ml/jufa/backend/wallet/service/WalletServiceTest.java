package ml.jufa.backend.wallet.service;

import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.config.TestConfig;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.wallet.dto.WalletResponse;
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

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("WalletService Tests")
class WalletServiceTest {

    @Mock
    private WalletRepository walletRepository;

    @InjectMocks
    private WalletService walletService;

    private User testUser;
    private Wallet testWallet;

    @BeforeEach
    void setUp() {
        testUser = TestConfig.createTestUser();
        testWallet = TestConfig.createTestWalletWithBalance(testUser, WalletType.B2C, new BigDecimal("10000"));
    }

    @Nested
    @DisplayName("getUserWallets")
    class GetUserWalletsTests {

        @Test
        @DisplayName("should return all wallets for user")
        void shouldReturnAllWalletsForUser() {
            Wallet wallet1 = TestConfig.createTestWallet(testUser, WalletType.B2C);
            Wallet wallet2 = TestConfig.createTestWallet(testUser, WalletType.B2B);
            
            when(walletRepository.findByUser(testUser)).thenReturn(List.of(wallet1, wallet2));

            List<WalletResponse> result = walletService.getUserWallets(testUser);

            assertThat(result).hasSize(2);
            verify(walletRepository).findByUser(testUser);
        }

        @Test
        @DisplayName("should return empty list when no wallets")
        void shouldReturnEmptyListWhenNoWallets() {
            when(walletRepository.findByUser(testUser)).thenReturn(List.of());

            List<WalletResponse> result = walletService.getUserWallets(testUser);

            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("getWalletById")
    class GetWalletByIdTests {

        @Test
        @DisplayName("should return wallet when found and user is owner")
        void shouldReturnWalletWhenFoundAndUserIsOwner() {
            when(walletRepository.findById(testWallet.getId())).thenReturn(Optional.of(testWallet));

            WalletResponse result = walletService.getWalletById(testWallet.getId(), testUser);

            assertThat(result).isNotNull();
            assertThat(result.getWalletType()).isEqualTo(WalletType.B2C);
        }

        @Test
        @DisplayName("should throw exception when wallet not found")
        void shouldThrowExceptionWhenWalletNotFound() {
            UUID walletId = UUID.randomUUID();
            when(walletRepository.findById(walletId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> walletService.getWalletById(walletId, testUser))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Wallet not found");
        }

        @Test
        @DisplayName("should throw exception when user is not owner")
        void shouldThrowExceptionWhenUserIsNotOwner() {
            User otherUser = TestConfig.createTestUser();
            when(walletRepository.findById(testWallet.getId())).thenReturn(Optional.of(testWallet));

            assertThatThrownBy(() -> walletService.getWalletById(testWallet.getId(), otherUser))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Access denied");
        }
    }

    @Nested
    @DisplayName("createWallet")
    class CreateWalletTests {

        @Test
        @DisplayName("should create wallet successfully")
        void shouldCreateWalletSuccessfully() {
            when(walletRepository.findByUserAndWalletType(testUser, WalletType.B2B))
                    .thenReturn(Optional.empty());
            when(walletRepository.save(any(Wallet.class)))
                    .thenAnswer(inv -> inv.getArgument(0));

            Wallet result = walletService.createWallet(testUser, WalletType.B2B);

            assertThat(result).isNotNull();
            assertThat(result.getWalletType()).isEqualTo(WalletType.B2B);
            assertThat(result.getUser()).isEqualTo(testUser);
            verify(walletRepository).save(any(Wallet.class));
        }

        @Test
        @DisplayName("should throw exception when wallet type already exists")
        void shouldThrowExceptionWhenWalletTypeAlreadyExists() {
            when(walletRepository.findByUserAndWalletType(testUser, WalletType.B2C))
                    .thenReturn(Optional.of(testWallet));

            assertThatThrownBy(() -> walletService.createWallet(testUser, WalletType.B2C))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("already exists");
        }
    }

    @Nested
    @DisplayName("creditWallet")
    class CreditWalletTests {

        @Test
        @DisplayName("should credit wallet successfully")
        void shouldCreditWalletSuccessfully() {
            BigDecimal creditAmount = new BigDecimal("5000");
            BigDecimal expectedBalance = testWallet.getBalance().add(creditAmount);
            
            when(walletRepository.findWithLockById(testWallet.getId()))
                    .thenReturn(Optional.of(testWallet));
            when(walletRepository.save(any(Wallet.class)))
                    .thenAnswer(inv -> inv.getArgument(0));

            WalletResponse result = walletService.creditWallet(testWallet.getId(), creditAmount, testUser);

            assertThat(result.getBalance()).isEqualByComparingTo(expectedBalance);
            verify(walletRepository).save(testWallet);
        }

        @Test
        @DisplayName("should throw exception when wallet is not active")
        void shouldThrowExceptionWhenWalletNotActive() {
            testWallet.setStatus(Wallet.WalletStatus.FROZEN);
            when(walletRepository.findWithLockById(testWallet.getId()))
                    .thenReturn(Optional.of(testWallet));

            assertThatThrownBy(() -> walletService.creditWallet(testWallet.getId(), new BigDecimal("1000"), testUser))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("not active");
        }
    }

    @Nested
    @DisplayName("debitWallet")
    class DebitWalletTests {

        @Test
        @DisplayName("should debit wallet successfully when balance sufficient")
        void shouldDebitWalletSuccessfully() {
            BigDecimal debitAmount = new BigDecimal("3000");
            BigDecimal expectedBalance = testWallet.getBalance().subtract(debitAmount);
            
            when(walletRepository.findWithLockById(testWallet.getId()))
                    .thenReturn(Optional.of(testWallet));
            when(walletRepository.save(any(Wallet.class)))
                    .thenAnswer(inv -> inv.getArgument(0));

            WalletResponse result = walletService.debitWallet(testWallet.getId(), debitAmount, testUser);

            assertThat(result.getBalance()).isEqualByComparingTo(expectedBalance);
        }

        @Test
        @DisplayName("should throw exception when insufficient balance")
        void shouldThrowExceptionWhenInsufficientBalance() {
            BigDecimal debitAmount = new BigDecimal("50000");
            
            when(walletRepository.findWithLockById(testWallet.getId()))
                    .thenReturn(Optional.of(testWallet));

            assertThatThrownBy(() -> walletService.debitWallet(testWallet.getId(), debitAmount, testUser))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("Insufficient balance");
        }

        @Test
        @DisplayName("should throw exception when wallet is frozen")
        void shouldThrowExceptionWhenWalletFrozen() {
            testWallet.setStatus(Wallet.WalletStatus.FROZEN);
            
            when(walletRepository.findWithLockById(testWallet.getId()))
                    .thenReturn(Optional.of(testWallet));

            assertThatThrownBy(() -> walletService.debitWallet(testWallet.getId(), new BigDecimal("1000"), testUser))
                    .isInstanceOf(JufaException.class)
                    .hasMessageContaining("not active");
        }
    }

    @Nested
    @DisplayName("getTotalBalance")
    class GetTotalBalanceTests {

        @Test
        @DisplayName("should calculate total balance from all wallets")
        void shouldCalculateTotalBalance() {
            Wallet wallet1 = TestConfig.createTestWalletWithBalance(testUser, WalletType.B2C, new BigDecimal("5000"));
            Wallet wallet2 = TestConfig.createTestWalletWithBalance(testUser, WalletType.B2B, new BigDecimal("3000"));
            
            when(walletRepository.findByUser(testUser)).thenReturn(List.of(wallet1, wallet2));

            BigDecimal result = walletService.getTotalBalance(testUser);

            assertThat(result).isEqualByComparingTo(new BigDecimal("8000"));
        }

        @Test
        @DisplayName("should return zero when no wallets")
        void shouldReturnZeroWhenNoWallets() {
            when(walletRepository.findByUser(testUser)).thenReturn(List.of());

            BigDecimal result = walletService.getTotalBalance(testUser);

            assertThat(result).isEqualByComparingTo(BigDecimal.ZERO);
        }
    }
}
