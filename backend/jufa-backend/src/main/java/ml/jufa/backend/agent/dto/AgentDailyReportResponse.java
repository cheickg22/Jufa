package ml.jufa.backend.agent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.agent.entity.AgentDailyReport;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentDailyReportResponse {

    private String id;
    private LocalDate reportDate;
    private Integer cashInCount;
    private BigDecimal cashInAmount;
    private Integer cashOutCount;
    private BigDecimal cashOutAmount;
    private Integer totalTransactions;
    private BigDecimal totalVolume;
    private BigDecimal totalCommission;
    private BigDecimal totalFees;

    public static AgentDailyReportResponse fromEntity(AgentDailyReport report) {
        return AgentDailyReportResponse.builder()
                .id(report.getId().toString())
                .reportDate(report.getReportDate())
                .cashInCount(report.getCashInCount())
                .cashInAmount(report.getCashInAmount())
                .cashOutCount(report.getCashOutCount())
                .cashOutAmount(report.getCashOutAmount())
                .totalTransactions(report.getTotalTransactions())
                .totalVolume(report.getTotalVolume())
                .totalCommission(report.getTotalCommission())
                .totalFees(report.getTotalFees())
                .build();
    }
}
