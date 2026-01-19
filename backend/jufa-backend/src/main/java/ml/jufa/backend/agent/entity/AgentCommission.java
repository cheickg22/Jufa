package ml.jufa.backend.agent.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "agent_commissions", indexes = {
    @Index(name = "idx_commission_agent", columnList = "agent_id"),
    @Index(name = "idx_commission_date", columnList = "commission_date"),
    @Index(name = "idx_commission_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgentCommission extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private User agent;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transaction_id", nullable = false)
    private AgentTransaction transaction;

    @Column(name = "commission_date", nullable = false)
    private LocalDate commissionDate;

    @Column(nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(name = "commission_rate", precision = 5, scale = 2)
    private BigDecimal commissionRate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private CommissionStatus status = CommissionStatus.PENDING;

    @Column(columnDefinition = "TEXT")
    private String description;

    public enum CommissionStatus {
        PENDING("En attente"),
        CREDITED("Créditée"),
        PAID("Payée");

        private final String displayName;

        CommissionStatus(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    public void credit() {
        this.status = CommissionStatus.CREDITED;
    }

    public void markAsPaid() {
        this.status = CommissionStatus.PAID;
    }
}
