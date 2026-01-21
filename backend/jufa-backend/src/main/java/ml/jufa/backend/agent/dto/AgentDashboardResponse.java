package ml.jufa.backend.agent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentDashboardResponse {

    private BigDecimal walletBalance;
    private BigDecimal commissionBalance;
    private BigDecimal todayVolume;
    private Integer todayTransactions;
    private BigDecimal todayCommission;
    private BigDecimal todayDeposits;
    private BigDecimal todayWithdrawals;
    private BigDecimal weekVolume;
    private Integer weekTransactions;
    private BigDecimal weekCommission;
    private BigDecimal monthVolume;
    private Integer monthTransactions;
    private BigDecimal monthCommission;
    private BigDecimal totalCommissionEarned;
    private Integer pendingTransactions;
    private BigDecimal depositCommissionRate;
    private BigDecimal withdrawalCommissionRate;
    private String agentCode;
    private String fullName;
    private Boolean hasSecretCode;
}
