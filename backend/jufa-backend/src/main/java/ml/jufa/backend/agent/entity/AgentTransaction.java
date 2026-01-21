package ml.jufa.backend.agent.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "agent_transactions", indexes = {
    @Index(name = "idx_agent_tx_agent", columnList = "agent_id"),
    @Index(name = "idx_agent_tx_customer", columnList = "customer_id"),
    @Index(name = "idx_agent_tx_reference", columnList = "reference"),
    @Index(name = "idx_agent_tx_status", columnList = "status"),
    @Index(name = "idx_agent_tx_created", columnList = "created_at")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgentTransaction extends BaseEntity {

    @Column(unique = true, nullable = false, length = 50)
    private String reference;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private User agent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = false)
    private AgentTransactionType transactionType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private AgentTransactionStatus status = AgentTransactionStatus.PENDING;

    @Column(nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal fee = BigDecimal.ZERO;

    @Column(name = "agent_commission", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal agentCommission = BigDecimal.ZERO;

    @Column(name = "platform_fee", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal platformFee = BigDecimal.ZERO;

    @Column(name = "customer_phone", length = 20)
    private String customerPhone;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "cancelled_at")
    private LocalDateTime cancelledAt;

    @Column(name = "cancellation_reason")
    private String cancellationReason;

    public BigDecimal getTotalAmount() {
        return amount.add(fee);
    }

    public void complete() {
        this.status = AgentTransactionStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
    }

    public void cancel(String reason) {
        this.status = AgentTransactionStatus.CANCELLED;
        this.cancelledAt = LocalDateTime.now();
        this.cancellationReason = reason;
    }

    public void fail(String reason) {
        this.status = AgentTransactionStatus.FAILED;
        this.cancelledAt = LocalDateTime.now();
        this.cancellationReason = reason;
    }
}
