package ml.jufa.backend.config;

import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.entity.UserStatus;
import ml.jufa.backend.user.entity.UserType;
import ml.jufa.backend.user.entity.KycLevel;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.util.UUID;

@TestConfiguration
public class TestConfig {

    @Bean
    @Primary
    public PasswordEncoder testPasswordEncoder() {
        return new BCryptPasswordEncoder(4);
    }

    public static User createTestUser() {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setPhone("+22370000001");
        user.setPasswordHash("$2a$04$test");
        user.setUserType(UserType.INDIVIDUAL);
        user.setStatus(UserStatus.ACTIVE);
        user.setKycLevel(KycLevel.LEVEL_1);
        return user;
    }

    public static User createTestMerchant() {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setPhone("+22370000002");
        user.setPasswordHash("$2a$04$test");
        user.setUserType(UserType.MERCHANT);
        user.setStatus(UserStatus.ACTIVE);
        user.setKycLevel(KycLevel.LEVEL_2);
        return user;
    }

    public static User createTestAgent() {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setPhone("+22370000003");
        user.setPasswordHash("$2a$04$test");
        user.setUserType(UserType.AGENT);
        user.setStatus(UserStatus.ACTIVE);
        user.setKycLevel(KycLevel.LEVEL_2);
        return user;
    }

    public static Wallet createTestWallet(User user, WalletType type) {
        Wallet wallet = Wallet.builder()
                .user(user)
                .walletType(type)
                .build();
        wallet.setId(UUID.randomUUID());
        return wallet;
    }

    public static Wallet createTestWalletWithBalance(User user, WalletType type, BigDecimal balance) {
        Wallet wallet = createTestWallet(user, type);
        wallet.credit(balance);
        return wallet;
    }
}
