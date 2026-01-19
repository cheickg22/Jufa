package ml.jufa.backend.qrpayment.repository;

import ml.jufa.backend.qrpayment.entity.QrPayment;
import ml.jufa.backend.qrpayment.entity.QrPaymentStatus;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface QrPaymentRepository extends JpaRepository<QrPayment, UUID> {

    List<QrPayment> findByPayerOrderByCreatedAtDesc(User payer, Pageable pageable);

    List<QrPayment> findByMerchantOrderByCreatedAtDesc(User merchant, Pageable pageable);

    @Query("SELECT qp FROM QrPayment qp WHERE (qp.payer = :user OR qp.merchant = :user) ORDER BY qp.createdAt DESC")
    List<QrPayment> findByPayerOrMerchantOrderByCreatedAtDesc(User user, Pageable pageable);

    List<QrPayment> findByMerchantAndStatus(User merchant, QrPaymentStatus status);

    @Query("SELECT COUNT(qp) FROM QrPayment qp WHERE qp.merchant = :merchant AND qp.status = 'COMPLETED'")
    long countCompletedByMerchant(User merchant);

    @Query("SELECT COALESCE(SUM(qp.amount), 0) FROM QrPayment qp WHERE qp.merchant = :merchant AND qp.status = 'COMPLETED'")
    java.math.BigDecimal sumCompletedAmountByMerchant(User merchant);
}
