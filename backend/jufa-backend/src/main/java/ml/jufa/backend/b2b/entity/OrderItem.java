package ml.jufa.backend.b2b.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;

import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private B2BOrder order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "product_name", nullable = false)
    private String productName;

    @Column(name = "product_sku", length = 50)
    private String productSku;

    @Column(nullable = false)
    private Integer quantity;

    @Column(name = "unit_price", nullable = false, precision = 18, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "discount_rate", precision = 5, scale = 2)
    @Builder.Default
    private BigDecimal discountRate = BigDecimal.ZERO;

    @Column(name = "line_total", nullable = false, precision = 18, scale = 2)
    private BigDecimal lineTotal;

    @PrePersist
    @PreUpdate
    public void calculateLineTotal() {
        if (unitPrice != null && quantity != null) {
            BigDecimal gross = unitPrice.multiply(new BigDecimal(quantity));
            if (discountRate != null && discountRate.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal discount = gross.multiply(discountRate).divide(new BigDecimal("100"));
                this.lineTotal = gross.subtract(discount);
            } else {
                this.lineTotal = gross;
            }
        }
    }

    public BigDecimal getLineTotal() {
        if (lineTotal == null) {
            calculateLineTotal();
        }
        return lineTotal != null ? lineTotal : BigDecimal.ZERO;
    }
}
