package ml.jufa.backend.b2b.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.b2b.dto.*;
import ml.jufa.backend.b2b.service.CatalogService;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/b2b/catalog")
@RequiredArgsConstructor
@Tag(name = "B2B Catalog", description = "Gestion du catalogue produits")
public class CatalogController {

    private final CatalogService catalogService;

    @GetMapping("/categories/{wholesalerId}")
    @Operation(summary = "Liste des catégories d'un grossiste")
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> getCategories(
            @PathVariable UUID wholesalerId) {
        List<CategoryResponse> categories = catalogService.getCategories(wholesalerId);
        return ResponseEntity.ok(ApiResponse.success(categories));
    }

    @PostMapping("/categories")
    @Operation(summary = "Créer une catégorie (grossiste)")
    public ResponseEntity<ApiResponse<CategoryResponse>> createCategory(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CategoryRequest request) {
        CategoryResponse category = catalogService.createCategory(user, request);
        return ResponseEntity.ok(ApiResponse.success(category, "Catégorie créée"));
    }

    @PutMapping("/categories/{categoryId}")
    @Operation(summary = "Modifier une catégorie (grossiste)")
    public ResponseEntity<ApiResponse<CategoryResponse>> updateCategory(
            @AuthenticationPrincipal User user,
            @PathVariable UUID categoryId,
            @Valid @RequestBody CategoryRequest request) {
        CategoryResponse category = catalogService.updateCategory(user, categoryId, request);
        return ResponseEntity.ok(ApiResponse.success(category, "Catégorie modifiée"));
    }

    @GetMapping("/products/{wholesalerId}")
    @Operation(summary = "Liste des produits d'un grossiste")
    public ResponseEntity<ApiResponse<Page<ProductResponse>>> getProducts(
            @PathVariable UUID wholesalerId,
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(required = false) String search,
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<ProductResponse> products = catalogService.getProducts(
                wholesalerId, categoryId, search, user, pageable);
        return ResponseEntity.ok(ApiResponse.success(products));
    }

    @GetMapping("/products/{wholesalerId}/featured")
    @Operation(summary = "Produits en vedette d'un grossiste")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getFeaturedProducts(
            @PathVariable UUID wholesalerId,
            @AuthenticationPrincipal User user) {
        List<ProductResponse> products = catalogService.getFeaturedProducts(wholesalerId, user);
        return ResponseEntity.ok(ApiResponse.success(products));
    }

    @GetMapping("/product/{productId}")
    @Operation(summary = "Détails d'un produit")
    public ResponseEntity<ApiResponse<ProductResponse>> getProduct(
            @PathVariable UUID productId,
            @AuthenticationPrincipal User user) {
        ProductResponse product = catalogService.getProduct(productId, user);
        return ResponseEntity.ok(ApiResponse.success(product));
    }

    @PostMapping("/products")
    @Operation(summary = "Créer un produit (grossiste)")
    public ResponseEntity<ApiResponse<ProductResponse>> createProduct(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody ProductRequest request) {
        ProductResponse product = catalogService.createProduct(user, request);
        return ResponseEntity.ok(ApiResponse.success(product, "Produit créé"));
    }

    @PutMapping("/products/{productId}")
    @Operation(summary = "Modifier un produit (grossiste)")
    public ResponseEntity<ApiResponse<ProductResponse>> updateProduct(
            @AuthenticationPrincipal User user,
            @PathVariable UUID productId,
            @Valid @RequestBody ProductRequest request) {
        ProductResponse product = catalogService.updateProduct(user, productId, request);
        return ResponseEntity.ok(ApiResponse.success(product, "Produit modifié"));
    }

    @PatchMapping("/products/{productId}/stock")
    @Operation(summary = "Mettre à jour le stock (grossiste)")
    public ResponseEntity<ApiResponse<Void>> updateStock(
            @AuthenticationPrincipal User user,
            @PathVariable UUID productId,
            @RequestParam Integer quantity) {
        catalogService.updateStock(user, productId, quantity);
        return ResponseEntity.ok(ApiResponse.success(null, "Stock mis à jour"));
    }

    @GetMapping("/products/low-stock")
    @Operation(summary = "Produits en stock bas (grossiste)")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getLowStockProducts(
            @AuthenticationPrincipal User user) {
        List<ProductResponse> products = catalogService.getLowStockProducts(user);
        return ResponseEntity.ok(ApiResponse.success(products));
    }

    @PostMapping(value = "/products/upload-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload image produit (grossiste)")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadProductImage(
            @AuthenticationPrincipal User user,
            @RequestParam("file") MultipartFile file) {
        String imageUrl = catalogService.uploadProductImage(user, file);
        return ResponseEntity.ok(ApiResponse.success(Map.of("imageUrl", imageUrl), "Image uploadée"));
    }
}
