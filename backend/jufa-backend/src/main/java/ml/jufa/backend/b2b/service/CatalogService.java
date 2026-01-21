package ml.jufa.backend.b2b.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.b2b.dto.*;
import ml.jufa.backend.b2b.entity.Product;
import ml.jufa.backend.b2b.entity.ProductCategory;
import ml.jufa.backend.b2b.repository.ProductCategoryRepository;
import ml.jufa.backend.b2b.repository.ProductRepository;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import ml.jufa.backend.merchant.entity.MerchantType;
import ml.jufa.backend.merchant.entity.WholesalerRetailer;
import ml.jufa.backend.merchant.repository.MerchantProfileRepository;
import ml.jufa.backend.merchant.repository.WholesalerRetailerRepository;
import ml.jufa.backend.user.entity.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CatalogService {

    private static final String UPLOAD_DIR = "uploads/products/";
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    private final ProductRepository productRepository;
    private final ProductCategoryRepository categoryRepository;
    private final MerchantProfileRepository merchantRepository;
    private final WholesalerRetailerRepository relationRepository;

    public List<CategoryResponse> getCategories(UUID wholesalerId) {
        MerchantProfile wholesaler = getWholesaler(wholesalerId);
        return categoryRepository.findByWholesalerAndActiveTrueOrderByDisplayOrderAsc(wholesaler)
                .stream()
                .map(CategoryResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public CategoryResponse createCategory(User user, CategoryRequest request) {
        MerchantProfile wholesaler = getWholesalerProfile(user);

        ProductCategory category = ProductCategory.builder()
                .wholesaler(wholesaler)
                .name(request.getName())
                .description(request.getDescription())
                .imageUrl(request.getImageUrl())
                .displayOrder(request.getDisplayOrder())
                .active(request.getActive())
                .build();

        categoryRepository.save(category);
        log.info("Category created: {} for wholesaler {}", category.getName(), wholesaler.getBusinessName());
        return CategoryResponse.fromEntity(category);
    }

    @Transactional
    public CategoryResponse updateCategory(User user, UUID categoryId, CategoryRequest request) {
        MerchantProfile wholesaler = getWholesalerProfile(user);
        ProductCategory category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new JufaException("JUFA-B2B-001", "Catégorie non trouvée"));

        if (!category.getWholesaler().getId().equals(wholesaler.getId())) {
            throw new JufaException("JUFA-B2B-002", "Accès non autorisé");
        }

        category.setName(request.getName());
        category.setDescription(request.getDescription());
        category.setImageUrl(request.getImageUrl());
        category.setDisplayOrder(request.getDisplayOrder());
        category.setActive(request.getActive());

        categoryRepository.save(category);
        return CategoryResponse.fromEntity(category);
    }

    public Page<ProductResponse> getProducts(UUID wholesalerId, UUID categoryId, String search, 
                                              User retailerUser, Pageable pageable) {
        MerchantProfile wholesaler = getWholesaler(wholesalerId);
        BigDecimal discountRate = getDiscountRate(retailerUser, wholesaler);

        Page<Product> products;
        if (search != null && !search.isBlank()) {
            products = productRepository.searchProducts(wholesaler, search.trim(), pageable);
        } else if (categoryId != null) {
            ProductCategory category = categoryRepository.findById(categoryId)
                    .orElseThrow(() -> new JufaException("JUFA-B2B-001", "Catégorie non trouvée"));
            products = productRepository.findByWholesalerAndCategoryAndActiveTrue(wholesaler, category, pageable);
        } else {
            products = productRepository.findByWholesalerAndActiveTrue(wholesaler, pageable);
        }

        return products.map(p -> ProductResponse.fromEntity(p, discountRate));
    }

    public List<ProductResponse> getFeaturedProducts(UUID wholesalerId, User retailerUser) {
        MerchantProfile wholesaler = getWholesaler(wholesalerId);
        BigDecimal discountRate = getDiscountRate(retailerUser, wholesaler);

        return productRepository.findByWholesalerAndFeaturedTrueAndActiveTrue(wholesaler)
                .stream()
                .map(p -> ProductResponse.fromEntity(p, discountRate))
                .collect(Collectors.toList());
    }

    public ProductResponse getProduct(UUID productId, User retailerUser) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new JufaException("JUFA-B2B-003", "Produit non trouvé"));

        BigDecimal discountRate = getDiscountRate(retailerUser, product.getWholesaler());
        return ProductResponse.fromEntity(product, discountRate);
    }

    @Transactional
    public ProductResponse createProduct(User user, ProductRequest request) {
        MerchantProfile wholesaler = getWholesalerProfile(user);

        productRepository.findByWholesalerAndSku(wholesaler, request.getSku())
                .ifPresent(p -> {
                    throw new JufaException("JUFA-B2B-004", "SKU déjà utilisé");
                });

        ProductCategory category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new JufaException("JUFA-B2B-001", "Catégorie non trouvée"));
        }

        Product product = Product.builder()
                .wholesaler(wholesaler)
                .category(category)
                .sku(request.getSku())
                .name(request.getName())
                .description(request.getDescription())
                .unit(request.getUnit())
                .unitPrice(request.getUnitPrice())
                .wholesalePrice(request.getWholesalePrice())
                .minOrderQuantity(request.getMinOrderQuantity())
                .stockQuantity(request.getStockQuantity())
                .lowStockThreshold(request.getLowStockThreshold())
                .imageUrl(request.getImageUrl())
                .active(request.getActive())
                .featured(request.getFeatured())
                .build();

        productRepository.save(product);
        log.info("Product created: {} (SKU: {}) for wholesaler {}", 
                product.getName(), product.getSku(), wholesaler.getBusinessName());
        return ProductResponse.fromEntity(product);
    }

    @Transactional
    public ProductResponse updateProduct(User user, UUID productId, ProductRequest request) {
        MerchantProfile wholesaler = getWholesalerProfile(user);
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new JufaException("JUFA-B2B-003", "Produit non trouvé"));

        if (!product.getWholesaler().getId().equals(wholesaler.getId())) {
            throw new JufaException("JUFA-B2B-002", "Accès non autorisé");
        }

        ProductCategory category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new JufaException("JUFA-B2B-001", "Catégorie non trouvée"));
        }

        product.setCategory(category);
        product.setSku(request.getSku());
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setUnit(request.getUnit());
        product.setUnitPrice(request.getUnitPrice());
        product.setWholesalePrice(request.getWholesalePrice());
        product.setMinOrderQuantity(request.getMinOrderQuantity());
        product.setStockQuantity(request.getStockQuantity());
        product.setLowStockThreshold(request.getLowStockThreshold());
        product.setImageUrl(request.getImageUrl());
        product.setActive(request.getActive());
        product.setFeatured(request.getFeatured());

        productRepository.save(product);
        return ProductResponse.fromEntity(product);
    }

    @Transactional
    public void updateStock(User user, UUID productId, Integer quantity) {
        MerchantProfile wholesaler = getWholesalerProfile(user);
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new JufaException("JUFA-B2B-003", "Produit non trouvé"));

        if (!product.getWholesaler().getId().equals(wholesaler.getId())) {
            throw new JufaException("JUFA-B2B-002", "Accès non autorisé");
        }

        product.setStockQuantity(quantity);
        productRepository.save(product);
        log.info("Stock updated for product {}: {}", product.getSku(), quantity);
    }

    public List<ProductResponse> getLowStockProducts(User user) {
        MerchantProfile wholesaler = getWholesalerProfile(user);
        return productRepository.findLowStockProducts(wholesaler)
                .stream()
                .map(ProductResponse::fromEntity)
                .collect(Collectors.toList());
    }

    private MerchantProfile getWholesaler(UUID wholesalerId) {
        MerchantProfile merchant = merchantRepository.findById(wholesalerId)
                .orElseThrow(() -> new JufaException("JUFA-B2B-005", "Grossiste non trouvé"));

        if (merchant.getMerchantType() != MerchantType.WHOLESALER) {
            throw new JufaException("JUFA-B2B-006", "Ce marchand n'est pas un grossiste");
        }
        return merchant;
    }

    private MerchantProfile getWholesalerProfile(User user) {
        MerchantProfile merchant = merchantRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-B2B-007", "Profil marchand non trouvé"));

        if (merchant.getMerchantType() != MerchantType.WHOLESALER) {
            throw new JufaException("JUFA-B2B-006", "Cette action est réservée aux grossistes");
        }
        return merchant;
    }

    private BigDecimal getDiscountRate(User user, MerchantProfile wholesaler) {
        if (user == null) return BigDecimal.ZERO;

        MerchantProfile retailer = merchantRepository.findByUser(user).orElse(null);
        if (retailer == null || retailer.getMerchantType() != MerchantType.RETAILER) {
            return BigDecimal.ZERO;
        }

        return relationRepository.findByWholesalerAndRetailerAndStatus(
                wholesaler, retailer, WholesalerRetailer.RelationStatus.ACTIVE)
                .map(WholesalerRetailer::getDiscountRate)
                .orElse(BigDecimal.ZERO);
    }

    public String uploadProductImage(User user, MultipartFile file) {
        getWholesalerProfile(user);

        if (file.isEmpty()) {
            throw new JufaException("JUFA-B2B-010", "Le fichier est vide");
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            throw new JufaException("JUFA-B2B-011", "Le fichier dépasse la taille maximale de 5MB");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new JufaException("JUFA-B2B-012", "Le fichier doit être une image");
        }

        try {
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String extension = getFileExtension(file.getOriginalFilename());
            String fileName = UUID.randomUUID().toString() + extension;
            Path filePath = uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath);

            log.info("Product image uploaded: {}", fileName);
            return baseUrl + "/api/uploads/products/" + fileName;
        } catch (IOException e) {
            log.error("Failed to upload product image", e);
            throw new JufaException("JUFA-B2B-013", "Erreur lors de l'upload de l'image");
        }
    }

    private String getFileExtension(String filename) {
        if (filename == null) return ".jpg";
        int dotIndex = filename.lastIndexOf('.');
        return dotIndex > 0 ? filename.substring(dotIndex) : ".jpg";
    }
}
