package ml.jufa.backend.b2b.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.b2b.entity.OrderItem;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderItemResponse {

    private String id;
    private String productId;
    private String productName;
    private String productSku;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal discountRate;
    private BigDecimal lineTotal;

    public static OrderItemResponse fromEntity(OrderItem item) {
        return OrderItemResponse.builder()
                .id(item.getId().toString())
                .productId(item.getProduct().getId().toString())
                .productName(item.getProductName())
                .productSku(item.getProductSku())
                .quantity(item.getQuantity())
                .unitPrice(item.getUnitPrice())
                .discountRate(item.getDiscountRate())
                .lineTotal(item.getLineTotal())
                .build();
    }
}
