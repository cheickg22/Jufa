package ml.jufa.backend.merchant.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "wholesaler_retailers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WholesalerRetailer extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wholesaler_id", nullable = false)
    private MerchantProfile wholesaler;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "retailer_id", nullable = false)
    private MerchantProfile retailer;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RelationStatus status = RelationStatus.PENDING;

    @Column(name = "credit_limit", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal creditLimit = BigDecimal.ZERO;

    @Column(name = "credit_used", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal creditUsed = BigDecimal.ZERO;

    @Column(name = "payment_terms_days")
    @Builder.Default
    private Integer paymentTermsDays = 0;

    @Column(name = "discount_rate", precision = 5, scale = 2)
    @Builder.Default
    private BigDecimal discountRate = BigDecimal.ZERO;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    public BigDecimal getAvailableCredit() {
        return creditLimit.subtract(creditUsed);
    }

    public enum RelationStatus {
        PENDING,
        ACTIVE,
        SUSPENDED
    }
}
