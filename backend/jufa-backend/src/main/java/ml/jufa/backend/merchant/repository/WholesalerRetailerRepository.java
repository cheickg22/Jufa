package ml.jufa.backend.merchant.repository;

import ml.jufa.backend.merchant.entity.MerchantProfile;
import ml.jufa.backend.merchant.entity.WholesalerRetailer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface WholesalerRetailerRepository extends JpaRepository<WholesalerRetailer, UUID> {

    List<WholesalerRetailer> findByWholesaler(MerchantProfile wholesaler);

    List<WholesalerRetailer> findByRetailer(MerchantProfile retailer);

    List<WholesalerRetailer> findByWholesalerAndStatus(MerchantProfile wholesaler, WholesalerRetailer.RelationStatus status);

    List<WholesalerRetailer> findByRetailerAndStatus(MerchantProfile retailer, WholesalerRetailer.RelationStatus status);

    Optional<WholesalerRetailer> findByWholesalerAndRetailer(MerchantProfile wholesaler, MerchantProfile retailer);

    Optional<WholesalerRetailer> findByWholesalerAndRetailerAndStatus(MerchantProfile wholesaler, MerchantProfile retailer, WholesalerRetailer.RelationStatus status);

    boolean existsByWholesalerAndRetailer(MerchantProfile wholesaler, MerchantProfile retailer);

    @Query("SELECT wr FROM WholesalerRetailer wr WHERE wr.wholesaler.id = :wholesalerId AND wr.status = 'ACTIVE'")
    List<WholesalerRetailer> findActiveRetailersByWholesalerId(UUID wholesalerId);

    @Query("SELECT wr FROM WholesalerRetailer wr WHERE wr.retailer.id = :retailerId AND wr.status = 'ACTIVE'")
    List<WholesalerRetailer> findActiveWholesalersByRetailerId(UUID retailerId);
}
