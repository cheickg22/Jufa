package ml.jufa.backend.mobilemoney.repository;

import ml.jufa.backend.mobilemoney.entity.MobileMoneyOperation;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyOperationStatus;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyOperationType;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MobileMoneyOperationRepository extends JpaRepository<MobileMoneyOperation, UUID> {

    Optional<MobileMoneyOperation> findByReference(String reference);

    Optional<MobileMoneyOperation> findByProviderReference(String providerReference);

    Page<MobileMoneyOperation> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);

    Page<MobileMoneyOperation> findByUserAndOperationTypeOrderByCreatedAtDesc(
            User user, MobileMoneyOperationType operationType, Pageable pageable);

    List<MobileMoneyOperation> findByStatusAndExpiresAtBefore(
            MobileMoneyOperationStatus status, LocalDateTime dateTime);

    @Query("SELECT m FROM MobileMoneyOperation m WHERE m.user = :user AND m.status = :status")
    List<MobileMoneyOperation> findPendingOperations(
            @Param("user") User user, 
            @Param("status") MobileMoneyOperationStatus status);

    @Query("SELECT COUNT(m) FROM MobileMoneyOperation m WHERE m.user = :user " +
           "AND m.operationType = :type AND m.status = 'COMPLETED' " +
           "AND m.createdAt >= :startDate")
    long countCompletedOperationsSince(
            @Param("user") User user,
            @Param("type") MobileMoneyOperationType type,
            @Param("startDate") LocalDateTime startDate);

    @Query("SELECT COALESCE(SUM(m.amount), 0) FROM MobileMoneyOperation m WHERE m.user = :user " +
           "AND m.operationType = :type AND m.status = 'COMPLETED' " +
           "AND m.createdAt >= :startDate")
    java.math.BigDecimal sumCompletedAmountSince(
            @Param("user") User user,
            @Param("type") MobileMoneyOperationType type,
            @Param("startDate") LocalDateTime startDate);
}
