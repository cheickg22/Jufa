package ml.jufa.backend.kyc.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.user.entity.KycLevel;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KycStatusResponse {
    
    private KycLevel currentLevel;
    private KycLevel nextLevel;
    private List<String> requiredDocuments;
    private List<KycDocumentResponse> submittedDocuments;
    private int approvedCount;
    private int pendingCount;
    private int rejectedCount;
    private BigDecimal dailyLimit;
    private BigDecimal monthlyLimit;
    
    public static KycLimits getLimits(KycLevel level) {
        return switch (level) {
            case LEVEL_0 -> new KycLimits(BigDecimal.valueOf(50000), BigDecimal.valueOf(200000));
            case LEVEL_1 -> new KycLimits(BigDecimal.valueOf(500000), BigDecimal.valueOf(2000000));
            case LEVEL_2 -> new KycLimits(BigDecimal.valueOf(2000000), BigDecimal.valueOf(10000000));
            case LEVEL_3 -> new KycLimits(BigDecimal.valueOf(50000000), BigDecimal.valueOf(200000000));
        };
    }
    
    @Data
    @AllArgsConstructor
    public static class KycLimits {
        private BigDecimal dailyLimit;
        private BigDecimal monthlyLimit;
    }
}
