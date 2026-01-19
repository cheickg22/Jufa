package ml.jufa.backend.agent.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "agent_daily_reports", indexes = {
    @Index(name = "idx_report_agent", columnList = "agent_id"),
    @Index(name = "idx_report_date", columnList = "report_date")
}, uniqueConstraints = {
    @UniqueConstraint(name = "uk_agent_date", columnNames = {"agent_id", "report_date"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgentDailyReport extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private User agent;

    @Column(name = "report_date", nullable = false)
    private LocalDate reportDate;

    @Column(name = "cash_in_count")
    @Builder.Default
    private Integer cashInCount = 0;

    @Column(name = "cash_in_amount", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal cashInAmount = BigDecimal.ZERO;

    @Column(name = "cash_out_count")
    @Builder.Default
    private Integer cashOutCount = 0;

    @Column(name = "cash_out_amount", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal cashOutAmount = BigDecimal.ZERO;

    @Column(name = "total_commission", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal totalCommission = BigDecimal.ZERO;

    @Column(name = "total_fees", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal totalFees = BigDecimal.ZERO;

    public int getTotalTransactions() {
        return cashInCount + cashOutCount;
    }

    public BigDecimal getTotalVolume() {
        return cashInAmount.add(cashOutAmount);
    }

    public void addCashIn(BigDecimal amount, BigDecimal commission, BigDecimal fee) {
        this.cashInCount++;
        this.cashInAmount = this.cashInAmount.add(amount);
        this.totalCommission = this.totalCommission.add(commission);
        this.totalFees = this.totalFees.add(fee);
    }

    public void addCashOut(BigDecimal amount, BigDecimal commission, BigDecimal fee) {
        this.cashOutCount++;
        this.cashOutAmount = this.cashOutAmount.add(amount);
        this.totalCommission = this.totalCommission.add(commission);
        this.totalFees = this.totalFees.add(fee);
    }
}
