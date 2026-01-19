package ml.jufa.backend.b2b.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import ml.jufa.backend.b2b.entity.ProductUnit;

import java.math.BigDecimal;
import java.util.UUID;

@Data
public class ProductRequest {

    private UUID categoryId;

    @NotBlank(message = "SKU is required")
    @Size(max = 50)
    private String sku;

    @NotBlank(message = "Product name is required")
    private String name;

    private String description;

    private ProductUnit unit = ProductUnit.PIECE;

    @NotNull(message = "Unit price is required")
    @DecimalMin(value = "0", message = "Price must be positive")
    private BigDecimal unitPrice;

    @DecimalMin(value = "0", message = "Price must be positive")
    private BigDecimal wholesalePrice;

    @Min(value = 1, message = "Minimum order quantity must be at least 1")
    private Integer minOrderQuantity = 1;

    @Min(value = 0, message = "Stock quantity cannot be negative")
    private Integer stockQuantity = 0;

    @Min(value = 0)
    private Integer lowStockThreshold = 10;

    private String imageUrl;

    private Boolean active = true;

    private Boolean featured = false;
}
