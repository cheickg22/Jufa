package ml.jufa.backend.merchant.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MerchantDashboardResponse {
    private MerchantProfileResponse profile;
    private int activeRelations;
    private int pendingRelations;
    private BigDecimal totalCreditGiven;
    private BigDecimal totalCreditUsed;
    private BigDecimal availableCredit;
}
