package ml.jufa.backend.mobilemoney.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "mobile_money_operations", indexes = {
    @Index(name = "idx_momo_user", columnList = "user_id"),
    @Index(name = "idx_momo_status", columnList = "status"),
    @Index(name = "idx_momo_reference", columnList = "reference"),
    @Index(name = "idx_momo_provider_ref", columnList = "provider_reference")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MobileMoneyOperation extends BaseEntity {

    @Column(nullable = false, unique = true, length = 50)
    private String reference;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MobileMoneyOperationType operationType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MobileMoneyProvider provider;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MobileMoneyOperationStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 20)
    private String phoneNumber;

    @Column(nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(precision = 18, scale = 2)
    private BigDecimal fee;

    @Column(length = 3)
    @Builder.Default
    private String currency = "XOF";

    @Column(length = 100)
    private String providerReference;

    @Column(length = 100)
    private String providerTransactionId;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String failureReason;

    private LocalDateTime completedAt;

    private LocalDateTime expiresAt;

    public void markAsProcessing() {
        this.status = MobileMoneyOperationStatus.PROCESSING;
    }

    public void markAsAwaitingConfirmation(String providerRef) {
        this.status = MobileMoneyOperationStatus.AWAITING_CONFIRMATION;
        this.providerReference = providerRef;
    }

    public void complete(String providerTransactionId) {
        this.status = MobileMoneyOperationStatus.COMPLETED;
        this.providerTransactionId = providerTransactionId;
        this.completedAt = LocalDateTime.now();
    }

    public void fail(String reason) {
        this.status = MobileMoneyOperationStatus.FAILED;
        this.failureReason = reason;
    }

    public void cancel() {
        this.status = MobileMoneyOperationStatus.CANCELLED;
    }

    public void expire() {
        this.status = MobileMoneyOperationStatus.EXPIRED;
    }

    public BigDecimal getTotalAmount() {
        return amount.add(fee != null ? fee : BigDecimal.ZERO);
    }
}
