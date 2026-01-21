package ml.jufa.backend.b2b.repository;

import ml.jufa.backend.b2b.entity.Product;
import ml.jufa.backend.b2b.entity.ProductCategory;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {

    Page<Product> findByWholesalerAndActiveTrue(MerchantProfile wholesaler, Pageable pageable);

    Page<Product> findByWholesalerAndCategoryAndActiveTrue(
            MerchantProfile wholesaler, ProductCategory category, Pageable pageable);

    List<Product> findByWholesalerAndFeaturedTrueAndActiveTrue(MerchantProfile wholesaler);

    Optional<Product> findByWholesalerAndSku(MerchantProfile wholesaler, String sku);

    @Query("SELECT p FROM Product p WHERE p.wholesaler = :wholesaler AND p.active = true " +
           "AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :search, '%')) " +
           "OR LOWER(p.sku) LIKE LOWER(CONCAT('%', :search, '%')))")
    Page<Product> searchProducts(
            @Param("wholesaler") MerchantProfile wholesaler,
            @Param("search") String search,
            Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.wholesaler = :wholesaler AND p.stockQuantity <= p.lowStockThreshold")
    List<Product> findLowStockProducts(@Param("wholesaler") MerchantProfile wholesaler);

    long countByWholesalerAndActiveTrue(MerchantProfile wholesaler);
}
