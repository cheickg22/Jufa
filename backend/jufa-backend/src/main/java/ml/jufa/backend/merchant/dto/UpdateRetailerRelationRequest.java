package ml.jufa.backend.merchant.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class UpdateRetailerRelationRequest {
    private BigDecimal creditLimit;
    private Integer paymentTermsDays;
    private BigDecimal discountRate;
}
