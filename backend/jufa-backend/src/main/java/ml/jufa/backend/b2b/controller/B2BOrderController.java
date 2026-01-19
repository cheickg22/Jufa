package ml.jufa.backend.b2b.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.b2b.dto.*;
import ml.jufa.backend.b2b.entity.OrderStatus;
import ml.jufa.backend.b2b.service.B2BOrderService;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/b2b/orders")
@RequiredArgsConstructor
@Tag(name = "B2B Orders", description = "Gestion des commandes B2B")
public class B2BOrderController {

    private final B2BOrderService orderService;

    @PostMapping
    @Operation(summary = "Créer une commande (détaillant)")
    public ResponseEntity<ApiResponse<OrderResponse>> createOrder(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CreateOrderRequest request) {
        OrderResponse order = orderService.createOrder(user, request);
        return ResponseEntity.ok(ApiResponse.success(order, "Commande créée avec succès"));
    }

    @GetMapping("/wholesaler")
    @Operation(summary = "Commandes reçues (grossiste)")
    public ResponseEntity<ApiResponse<Page<OrderResponse>>> getWholesalerOrders(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) OrderStatus status,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<OrderResponse> orders = orderService.getWholesalerOrders(user, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(orders));
    }

    @GetMapping("/retailer")
    @Operation(summary = "Mes commandes (détaillant)")
    public ResponseEntity<ApiResponse<Page<OrderResponse>>> getRetailerOrders(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) OrderStatus status,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<OrderResponse> orders = orderService.getRetailerOrders(user, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(orders));
    }

    @GetMapping("/{reference}")
    @Operation(summary = "Détails d'une commande")
    public ResponseEntity<ApiResponse<OrderResponse>> getOrder(
            @AuthenticationPrincipal User user,
            @PathVariable String reference) {
        OrderResponse order = orderService.getOrder(user, reference);
        return ResponseEntity.ok(ApiResponse.success(order));
    }

    @PostMapping("/{reference}/confirm")
    @Operation(summary = "Confirmer une commande (grossiste)")
    public ResponseEntity<ApiResponse<OrderResponse>> confirmOrder(
            @AuthenticationPrincipal User user,
            @PathVariable String reference) {
        OrderResponse order = orderService.confirmOrder(user, reference);
        return ResponseEntity.ok(ApiResponse.success(order, "Commande confirmée"));
    }

    @PatchMapping("/{reference}/status")
    @Operation(summary = "Mettre à jour le statut (grossiste)")
    public ResponseEntity<ApiResponse<OrderResponse>> updateStatus(
            @AuthenticationPrincipal User user,
            @PathVariable String reference,
            @RequestParam OrderStatus status) {
        OrderResponse order = orderService.updateOrderStatus(user, reference, status);
        return ResponseEntity.ok(ApiResponse.success(order, "Statut mis à jour"));
    }

    @PostMapping("/{reference}/cancel")
    @Operation(summary = "Annuler une commande")
    public ResponseEntity<ApiResponse<OrderResponse>> cancelOrder(
            @AuthenticationPrincipal User user,
            @PathVariable String reference,
            @RequestParam(required = false) String reason) {
        OrderResponse order = orderService.cancelOrder(user, reference, reason);
        return ResponseEntity.ok(ApiResponse.success(order, "Commande annulée"));
    }

    @GetMapping("/pending-count")
    @Operation(summary = "Nombre de commandes en attente (grossiste)")
    public ResponseEntity<ApiResponse<Long>> getPendingCount(
            @AuthenticationPrincipal User user) {
        long count = orderService.countPendingOrders(user);
        return ResponseEntity.ok(ApiResponse.success(count));
    }
}
