package ml.jufa.backend.qrpayment.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.transaction.entity.Transaction;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "qr_payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QrPayment extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "qr_code_id", nullable = false)
    private QrCode qrCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payer_id", nullable = false)
    private User payer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "merchant_id", nullable = false)
    private User merchant;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transaction_id")
    private Transaction transaction;

    @Column(precision = 18, scale = 2, nullable = false)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private QrPaymentStatus status = QrPaymentStatus.PENDING;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(length = 255)
    private String failureReason;

    public void complete(Transaction transaction) {
        this.transaction = transaction;
        this.status = QrPaymentStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
    }

    public void cancel(String reason) {
        this.status = QrPaymentStatus.CANCELLED;
        this.failureReason = reason;
    }
}
