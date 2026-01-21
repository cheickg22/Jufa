package ml.jufa.backend.b2b.repository;

import ml.jufa.backend.b2b.entity.ProductCategory;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductCategoryRepository extends JpaRepository<ProductCategory, UUID> {

    List<ProductCategory> findByWholesalerAndActiveTrueOrderByDisplayOrderAsc(MerchantProfile wholesaler);

    List<ProductCategory> findByWholesalerOrderByDisplayOrderAsc(MerchantProfile wholesaler);
}
