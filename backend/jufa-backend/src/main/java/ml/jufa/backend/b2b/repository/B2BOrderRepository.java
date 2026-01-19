package ml.jufa.backend.b2b.repository;

import ml.jufa.backend.b2b.entity.B2BOrder;
import ml.jufa.backend.b2b.entity.OrderStatus;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface B2BOrderRepository extends JpaRepository<B2BOrder, UUID> {

    Optional<B2BOrder> findByReference(String reference);

    Page<B2BOrder> findByWholesalerOrderByCreatedAtDesc(MerchantProfile wholesaler, Pageable pageable);

    Page<B2BOrder> findByRetailerOrderByCreatedAtDesc(MerchantProfile retailer, Pageable pageable);

    Page<B2BOrder> findByWholesalerAndStatusOrderByCreatedAtDesc(
            MerchantProfile wholesaler, OrderStatus status, Pageable pageable);

    Page<B2BOrder> findByRetailerAndStatusOrderByCreatedAtDesc(
            MerchantProfile retailer, OrderStatus status, Pageable pageable);

    List<B2BOrder> findByWholesalerAndStatusIn(MerchantProfile wholesaler, List<OrderStatus> statuses);

    @Query("SELECT COUNT(o) FROM B2BOrder o WHERE o.wholesaler = :wholesaler AND o.status = :status")
    long countByWholesalerAndStatus(
            @Param("wholesaler") MerchantProfile wholesaler, 
            @Param("status") OrderStatus status);

    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM B2BOrder o WHERE o.wholesaler = :wholesaler " +
           "AND o.status = 'DELIVERED' AND o.createdAt >= :since")
    BigDecimal sumDeliveredOrdersAmount(
            @Param("wholesaler") MerchantProfile wholesaler, 
            @Param("since") LocalDateTime since);

    @Query("SELECT COUNT(o) FROM B2BOrder o WHERE o.retailer = :retailer " +
           "AND o.wholesaler = :wholesaler AND o.status NOT IN ('CANCELLED', 'REFUNDED')")
    long countActiveOrdersBetween(
            @Param("retailer") MerchantProfile retailer,
            @Param("wholesaler") MerchantProfile wholesaler);
}
