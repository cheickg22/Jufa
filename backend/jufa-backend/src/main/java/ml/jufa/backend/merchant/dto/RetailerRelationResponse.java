package ml.jufa.backend.merchant.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.merchant.entity.WholesalerRetailer;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RetailerRelationResponse {

    private UUID id;
    private MerchantProfileResponse retailer;
    private MerchantProfileResponse wholesaler;
    private WholesalerRetailer.RelationStatus status;
    private BigDecimal creditLimit;
    private BigDecimal creditUsed;
    private BigDecimal availableCredit;
    private Integer paymentTermsDays;
    private BigDecimal discountRate;
    private LocalDateTime approvedAt;
    private LocalDateTime createdAt;

    public static RetailerRelationResponse fromEntity(WholesalerRetailer relation) {
        return RetailerRelationResponse.builder()
                .id(relation.getId())
                .retailer(MerchantProfileResponse.fromEntity(relation.getRetailer()))
                .wholesaler(MerchantProfileResponse.fromEntity(relation.getWholesaler()))
                .status(relation.getStatus())
                .creditLimit(relation.getCreditLimit())
                .creditUsed(relation.getCreditUsed())
                .availableCredit(relation.getAvailableCredit())
                .paymentTermsDays(relation.getPaymentTermsDays())
                .discountRate(relation.getDiscountRate())
                .approvedAt(relation.getApprovedAt())
                .createdAt(relation.getCreatedAt())
                .build();
    }
}
