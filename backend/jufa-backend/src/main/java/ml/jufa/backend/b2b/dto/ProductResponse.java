package ml.jufa.backend.b2b.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.b2b.entity.Product;
import ml.jufa.backend.b2b.entity.ProductUnit;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {

    private String id;
    private String categoryId;
    private String categoryName;
    private String sku;
    private String name;
    private String description;
    private ProductUnit unit;
    private String unitName;
    private BigDecimal unitPrice;
    private BigDecimal wholesalePrice;
    private BigDecimal effectivePrice;
    private Integer minOrderQuantity;
    private Integer stockQuantity;
    private boolean inStock;
    private boolean lowStock;
    private String imageUrl;
    private boolean active;
    private boolean featured;

    public static ProductResponse fromEntity(Product product) {
        return fromEntity(product, null);
    }

    public static ProductResponse fromEntity(Product product, BigDecimal discountRate) {
        return ProductResponse.builder()
                .id(product.getId().toString())
                .categoryId(product.getCategory() != null ? product.getCategory().getId().toString() : null)
                .categoryName(product.getCategory() != null ? product.getCategory().getName() : null)
                .sku(product.getSku())
                .name(product.getName())
                .description(product.getDescription())
                .unit(product.getUnit())
                .unitName(product.getUnit().getDisplayName())
                .unitPrice(product.getUnitPrice())
                .wholesalePrice(product.getWholesalePrice())
                .effectivePrice(product.getEffectivePrice(discountRate))
                .minOrderQuantity(product.getMinOrderQuantity())
                .stockQuantity(product.getStockQuantity())
                .inStock(product.isInStock())
                .lowStock(product.isLowStock())
                .imageUrl(product.getImageUrl())
                .active(product.getActive())
                .featured(product.getFeatured())
                .build();
    }
}
