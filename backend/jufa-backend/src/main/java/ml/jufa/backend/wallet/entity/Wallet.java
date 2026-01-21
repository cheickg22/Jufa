package ml.jufa.backend.wallet.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;

@Entity
@Table(name = "wallets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Wallet extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "wallet_type", nullable = false)
    private WalletType walletType;

    @Column(length = 3)
    @Builder.Default
    private String currency = "XOF";

    @Column(precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal balance = BigDecimal.ZERO;

    @Column(name = "available_balance", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal availableBalance = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private WalletStatus status = WalletStatus.ACTIVE;

    public enum WalletStatus {
        ACTIVE,
        FROZEN,
        CLOSED
    }

    public void credit(BigDecimal amount) {
        this.balance = this.balance.add(amount);
        this.availableBalance = this.availableBalance.add(amount);
    }

    public void debit(BigDecimal amount) {
        if (this.availableBalance.compareTo(amount) < 0) {
            throw new IllegalStateException("Insufficient balance");
        }
        this.balance = this.balance.subtract(amount);
        this.availableBalance = this.availableBalance.subtract(amount);
    }

    public void hold(BigDecimal amount) {
        if (this.availableBalance.compareTo(amount) < 0) {
            throw new IllegalStateException("Insufficient available balance");
        }
        this.availableBalance = this.availableBalance.subtract(amount);
    }

    public void release(BigDecimal amount) {
        this.availableBalance = this.availableBalance.add(amount);
    }
}
