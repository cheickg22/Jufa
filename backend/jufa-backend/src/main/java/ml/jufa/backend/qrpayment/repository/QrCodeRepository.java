package ml.jufa.backend.qrpayment.repository;

import ml.jufa.backend.qrpayment.entity.QrCode;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface QrCodeRepository extends JpaRepository<QrCode, UUID> {

    Optional<QrCode> findByQrToken(String qrToken);

    List<QrCode> findByMerchantAndActiveOrderByCreatedAtDesc(User merchant, Boolean active);

    List<QrCode> findByMerchantOrderByCreatedAtDesc(User merchant);

    boolean existsByQrToken(String qrToken);
}
