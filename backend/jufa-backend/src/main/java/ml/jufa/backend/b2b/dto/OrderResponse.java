package ml.jufa.backend.b2b.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.b2b.entity.B2BOrder;
import ml.jufa.backend.b2b.entity.OrderStatus;
import ml.jufa.backend.b2b.entity.PaymentStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderResponse {

    private String id;
    private String reference;
    private String wholesalerId;
    private String wholesalerName;
    private String retailerId;
    private String retailerName;
    private OrderStatus status;
    private String statusName;
    private PaymentStatus paymentStatus;
    private String paymentStatusName;
    private List<OrderItemResponse> items;
    private int itemCount;
    private BigDecimal subtotal;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private BigDecimal amountPaid;
    private BigDecimal amountDue;
    private Boolean useCredit;
    private String notes;
    private String deliveryAddress;
    private LocalDate expectedDeliveryDate;
    private LocalDateTime createdAt;
    private LocalDateTime confirmedAt;
    private LocalDateTime shippedAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime cancelledAt;
    private String cancellationReason;

    public static OrderResponse fromEntity(B2BOrder order) {
        return OrderResponse.builder()
                .id(order.getId().toString())
                .reference(order.getReference())
                .wholesalerId(order.getWholesaler().getId().toString())
                .wholesalerName(order.getWholesaler().getBusinessName())
                .retailerId(order.getRetailer().getId().toString())
                .retailerName(order.getRetailer().getBusinessName())
                .status(order.getStatus())
                .statusName(order.getStatus().getDisplayName())
                .paymentStatus(order.getPaymentStatus())
                .paymentStatusName(order.getPaymentStatus().getDisplayName())
                .items(order.getItems().stream()
                        .map(OrderItemResponse::fromEntity)
                        .collect(Collectors.toList()))
                .itemCount(order.getItems().size())
                .subtotal(order.getSubtotal())
                .discountAmount(order.getDiscountAmount())
                .totalAmount(order.getTotalAmount())
                .amountPaid(order.getAmountPaid())
                .amountDue(order.getAmountDue())
                .useCredit(order.getUseCredit())
                .notes(order.getNotes())
                .deliveryAddress(order.getDeliveryAddress())
                .expectedDeliveryDate(order.getExpectedDeliveryDate())
                .createdAt(order.getCreatedAt())
                .confirmedAt(order.getConfirmedAt())
                .shippedAt(order.getShippedAt())
                .deliveredAt(order.getDeliveredAt())
                .cancelledAt(order.getCancelledAt())
                .cancellationReason(order.getCancellationReason())
                .build();
    }
}
