package ml.jufa.backend.merchant.repository;

import ml.jufa.backend.merchant.entity.MerchantProfile;
import ml.jufa.backend.merchant.entity.MerchantType;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MerchantProfileRepository extends JpaRepository<MerchantProfile, UUID> {

    Optional<MerchantProfile> findByUser(User user);

    Optional<MerchantProfile> findByUserId(UUID userId);

    List<MerchantProfile> findByMerchantType(MerchantType merchantType);

    List<MerchantProfile> findByMerchantTypeAndVerified(MerchantType merchantType, Boolean verified);

    @Query("SELECT m FROM MerchantProfile m WHERE m.merchantType = 'WHOLESALER' AND m.city = :city")
    List<MerchantProfile> findVerifiedWholesalersByCity(String city);

    @Query("SELECT m FROM MerchantProfile m WHERE m.merchantType = 'WHOLESALER'")
    List<MerchantProfile> findAllVerifiedWholesalers();

    boolean existsByUser(User user);
}
