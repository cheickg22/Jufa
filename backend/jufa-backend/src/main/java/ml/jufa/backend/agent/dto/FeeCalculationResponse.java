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
public class FeeCalculationResponse {

    private BigDecimal amount;
    private BigDecimal fee;
    private BigDecimal totalAmount;
    private BigDecimal agentCommission;
    private String feeDescription;
}
