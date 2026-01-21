package ml.jufa.backend.b2b.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.merchant.entity.MerchantProfile;

import java.math.BigDecimal;

@Entity
@Table(name = "products", indexes = {
    @Index(name = "idx_product_wholesaler", columnList = "wholesaler_id"),
    @Index(name = "idx_product_category", columnList = "category_id"),
    @Index(name = "idx_product_sku", columnList = "sku")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wholesaler_id", nullable = false)
    private MerchantProfile wholesaler;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private ProductCategory category;

    @Column(nullable = false, length = 50)
    private String sku;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private ProductUnit unit = ProductUnit.PIECE;

    @Column(name = "unit_price", nullable = false, precision = 18, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "wholesale_price", precision = 18, scale = 2)
    private BigDecimal wholesalePrice;

    @Column(name = "min_order_quantity")
    @Builder.Default
    private Integer minOrderQuantity = 1;

    @Column(name = "stock_quantity")
    @Builder.Default
    private Integer stockQuantity = 0;

    @Column(name = "low_stock_threshold")
    @Builder.Default
    private Integer lowStockThreshold = 10;

    @Column(name = "image_url", columnDefinition = "TEXT")
    private String imageUrl;

    @Builder.Default
    private Boolean active = true;

    @Builder.Default
    private Boolean featured = false;

    public boolean isInStock() {
        return stockQuantity > 0;
    }

    public boolean isLowStock() {
        return stockQuantity <= lowStockThreshold;
    }

    public BigDecimal getEffectivePrice(BigDecimal discountRate) {
        BigDecimal basePrice = wholesalePrice != null ? wholesalePrice : unitPrice;
        if (discountRate != null && discountRate.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal discount = basePrice.multiply(discountRate).divide(new BigDecimal("100"));
            return basePrice.subtract(discount);
        }
        return basePrice;
    }
}
