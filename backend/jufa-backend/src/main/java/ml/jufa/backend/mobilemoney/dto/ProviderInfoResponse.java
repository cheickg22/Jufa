package ml.jufa.backend.mobilemoney.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyProvider;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProviderInfoResponse {
    private MobileMoneyProvider provider;
    private String name;
    private String code;
    private boolean depositEnabled;
    private boolean withdrawalEnabled;
    private BigDecimal minDeposit;
    private BigDecimal maxDeposit;
    private BigDecimal minWithdrawal;
    private BigDecimal maxWithdrawal;
    private BigDecimal depositFeePercent;
    private BigDecimal withdrawalFeePercent;
}
