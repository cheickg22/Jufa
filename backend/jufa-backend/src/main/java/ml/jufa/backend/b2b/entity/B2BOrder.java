package ml.jufa.backend.b2b.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import ml.jufa.backend.merchant.entity.WholesalerRetailer;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "b2b_orders", indexes = {
    @Index(name = "idx_order_wholesaler", columnList = "wholesaler_id"),
    @Index(name = "idx_order_retailer", columnList = "retailer_id"),
    @Index(name = "idx_order_reference", columnList = "reference"),
    @Index(name = "idx_order_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class B2BOrder extends BaseEntity {

    @Column(nullable = false, unique = true, length = 50)
    private String reference;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wholesaler_id", nullable = false)
    private MerchantProfile wholesaler;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "retailer_id", nullable = false)
    private MerchantProfile retailer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "relation_id")
    private WholesalerRetailer relation;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private OrderStatus status = OrderStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false)
    @Builder.Default
    private PaymentStatus paymentStatus = PaymentStatus.PENDING;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<OrderItem> items = new ArrayList<>();

    @Column(name = "subtotal", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal subtotal = BigDecimal.ZERO;

    @Column(name = "discount_amount", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal totalAmount = BigDecimal.ZERO;

    @Column(name = "amount_paid", precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal amountPaid = BigDecimal.ZERO;

    @Column(name = "use_credit")
    @Builder.Default
    private Boolean useCredit = false;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "delivery_address", columnDefinition = "TEXT")
    private String deliveryAddress;

    @Column(name = "expected_delivery_date")
    private LocalDate expectedDeliveryDate;

    @Column(name = "confirmed_at")
    private LocalDateTime confirmedAt;

    @Column(name = "shipped_at")
    private LocalDateTime shippedAt;

    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;

    @Column(name = "cancelled_at")
    private LocalDateTime cancelledAt;

    @Column(name = "cancellation_reason")
    private String cancellationReason;

    public void addItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);
        recalculateTotals();
    }

    public void removeItem(OrderItem item) {
        items.remove(item);
        item.setOrder(null);
        recalculateTotals();
    }

    public void recalculateTotals() {
        this.subtotal = items.stream()
                .map(OrderItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        this.totalAmount = subtotal.subtract(discountAmount != null ? discountAmount : BigDecimal.ZERO);
    }

    public BigDecimal getAmountDue() {
        return totalAmount.subtract(amountPaid != null ? amountPaid : BigDecimal.ZERO);
    }

    public void confirm() {
        this.status = OrderStatus.CONFIRMED;
        this.confirmedAt = LocalDateTime.now();
    }

    public void ship() {
        this.status = OrderStatus.SHIPPED;
        this.shippedAt = LocalDateTime.now();
    }

    public void deliver() {
        this.status = OrderStatus.DELIVERED;
        this.deliveredAt = LocalDateTime.now();
    }

    public void cancel(String reason) {
        this.status = OrderStatus.CANCELLED;
        this.cancelledAt = LocalDateTime.now();
        this.cancellationReason = reason;
    }
}
