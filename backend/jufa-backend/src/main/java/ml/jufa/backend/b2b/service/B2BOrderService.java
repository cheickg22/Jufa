package ml.jufa.backend.b2b.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.b2b.dto.*;
import ml.jufa.backend.b2b.entity.*;
import ml.jufa.backend.b2b.repository.B2BOrderRepository;
import ml.jufa.backend.b2b.repository.ProductRepository;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import ml.jufa.backend.merchant.entity.MerchantType;
import ml.jufa.backend.merchant.entity.WholesalerRetailer;
import ml.jufa.backend.merchant.repository.MerchantProfileRepository;
import ml.jufa.backend.merchant.repository.WholesalerRetailerRepository;
import ml.jufa.backend.notification.service.PushNotificationService;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class B2BOrderService {

    private final B2BOrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final MerchantProfileRepository merchantRepository;
    private final WholesalerRetailerRepository relationRepository;
    private final PushNotificationService notificationService;

    @Transactional
    public OrderResponse createOrder(User user, CreateOrderRequest request) {
        MerchantProfile retailer = getRetailerProfile(user);
        MerchantProfile wholesaler = merchantRepository.findById(request.getWholesalerId())
                .orElseThrow(() -> new JufaException("JUFA-B2B-005", "Grossiste non trouvé"));

        if (wholesaler.getMerchantType() != MerchantType.WHOLESALER) {
            throw new JufaException("JUFA-B2B-006", "Ce marchand n'est pas un grossiste");
        }

        WholesalerRetailer relation = relationRepository.findByWholesalerAndRetailerAndStatus(
                wholesaler, retailer, WholesalerRetailer.RelationStatus.ACTIVE)
                .orElseThrow(() -> new JufaException("JUFA-B2B-008", 
                        "Vous n'avez pas de relation active avec ce grossiste"));

        B2BOrder order = B2BOrder.builder()
                .reference(generateReference())
                .wholesaler(wholesaler)
                .retailer(retailer)
                .relation(relation)
                .status(OrderStatus.PENDING)
                .paymentStatus(PaymentStatus.PENDING)
                .notes(request.getNotes())
                .deliveryAddress(request.getDeliveryAddress() != null ? 
                        request.getDeliveryAddress() : retailer.getAddress())
                .expectedDeliveryDate(request.getExpectedDeliveryDate())
                .useCredit(request.getUseCredit())
                .discountAmount(BigDecimal.ZERO)
                .build();

        BigDecimal discountRate = relation.getDiscountRate();

        for (OrderItemRequest itemRequest : request.getItems()) {
            Product product = productRepository.findById(itemRequest.getProductId())
                    .orElseThrow(() -> new JufaException("JUFA-B2B-003", "Produit non trouvé"));

            if (!product.getWholesaler().getId().equals(wholesaler.getId())) {
                throw new JufaException("JUFA-B2B-009", 
                        "Le produit " + product.getName() + " n'appartient pas à ce grossiste");
            }

            if (!product.isInStock() || product.getStockQuantity() < itemRequest.getQuantity()) {
                throw new JufaException("JUFA-B2B-010", 
                        "Stock insuffisant pour " + product.getName());
            }

            if (itemRequest.getQuantity() < product.getMinOrderQuantity()) {
                throw new JufaException("JUFA-B2B-011", 
                        "Quantité minimum pour " + product.getName() + ": " + product.getMinOrderQuantity());
            }

            BigDecimal unitPrice = product.getEffectivePrice(discountRate);

            OrderItem item = OrderItem.builder()
                    .product(product)
                    .productName(product.getName())
                    .productSku(product.getSku())
                    .quantity(itemRequest.getQuantity())
                    .unitPrice(unitPrice)
                    .discountRate(discountRate)
                    .build();

            order.addItem(item);
        }

        if (request.getUseCredit() != null && request.getUseCredit()) {
            BigDecimal availableCredit = relation.getAvailableCredit();
            if (order.getTotalAmount().compareTo(availableCredit) > 0) {
                throw new JufaException("JUFA-B2B-012", 
                        "Crédit insuffisant. Disponible: " + availableCredit + " XOF");
            }
            order.setPaymentStatus(PaymentStatus.CREDIT);
        }

        orderRepository.save(order);
        log.info("B2B Order created: {} from {} to {}", 
                order.getReference(), retailer.getBusinessName(), wholesaler.getBusinessName());

        notificationService.sendMerchantRelationRequest(wholesaler.getUser(), 
                "Nouvelle commande de " + retailer.getBusinessName());

        return OrderResponse.fromEntity(order);
    }

    @Transactional
    public OrderResponse confirmOrder(User user, String orderReference) {
        MerchantProfile wholesaler = getWholesalerProfile(user);
        B2BOrder order = getOrderByReference(orderReference);

        if (!order.getWholesaler().getId().equals(wholesaler.getId())) {
            throw new JufaException("JUFA-B2B-002", "Accès non autorisé");
        }

        if (order.getStatus() != OrderStatus.PENDING) {
            throw new JufaException("JUFA-B2B-013", "Cette commande ne peut pas être confirmée");
        }

        for (OrderItem item : order.getItems()) {
            Product product = item.getProduct();
            if (product.getStockQuantity() < item.getQuantity()) {
                throw new JufaException("JUFA-B2B-010", 
                        "Stock insuffisant pour " + product.getName());
            }
            product.setStockQuantity(product.getStockQuantity() - item.getQuantity());
            productRepository.save(product);
        }

        if (order.getUseCredit()) {
            WholesalerRetailer relation = order.getRelation();
            relation.setCreditUsed(relation.getCreditUsed().add(order.getTotalAmount()));
            relationRepository.save(relation);
        }

        order.confirm();
        orderRepository.save(order);

        log.info("B2B Order confirmed: {}", order.getReference());
        return OrderResponse.fromEntity(order);
    }

    @Transactional
    public OrderResponse updateOrderStatus(User user, String orderReference, OrderStatus newStatus) {
        MerchantProfile wholesaler = getWholesalerProfile(user);
        B2BOrder order = getOrderByReference(orderReference);

        if (!order.getWholesaler().getId().equals(wholesaler.getId())) {
            throw new JufaException("JUFA-B2B-002", "Accès non autorisé");
        }

        switch (newStatus) {
            case PROCESSING -> {
                if (order.getStatus() != OrderStatus.CONFIRMED) {
                    throw new JufaException("JUFA-B2B-014", "Statut invalide");
                }
                order.setStatus(OrderStatus.PROCESSING);
            }
            case READY -> {
                if (order.getStatus() != OrderStatus.PROCESSING) {
                    throw new JufaException("JUFA-B2B-014", "Statut invalide");
                }
                order.setStatus(OrderStatus.READY);
            }
            case SHIPPED -> order.ship();
            case DELIVERED -> {
                order.deliver();
                if (order.getPaymentStatus() == PaymentStatus.CREDIT) {
                    order.setAmountPaid(order.getTotalAmount());
                    order.setPaymentStatus(PaymentStatus.PAID);
                }
            }
            default -> throw new JufaException("JUFA-B2B-014", "Transition de statut invalide");
        }

        orderRepository.save(order);
        log.info("B2B Order {} status updated to {}", order.getReference(), newStatus);
        return OrderResponse.fromEntity(order);
    }

    @Transactional
    public OrderResponse cancelOrder(User user, String orderReference, String reason) {
        B2BOrder order = getOrderByReference(orderReference);
        MerchantProfile merchant = merchantRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-B2B-007", "Profil marchand non trouvé"));

        boolean isWholesaler = order.getWholesaler().getId().equals(merchant.getId());
        boolean isRetailer = order.getRetailer().getId().equals(merchant.getId());

        if (!isWholesaler && !isRetailer) {
            throw new JufaException("JUFA-B2B-002", "Accès non autorisé");
        }

        if (!order.getStatus().canCancel()) {
            throw new JufaException("JUFA-B2B-015", "Cette commande ne peut plus être annulée");
        }

        if (order.getStatus() == OrderStatus.CONFIRMED) {
            for (OrderItem item : order.getItems()) {
                Product product = item.getProduct();
                product.setStockQuantity(product.getStockQuantity() + item.getQuantity());
                productRepository.save(product);
            }

            if (order.getUseCredit() && order.getRelation() != null) {
                WholesalerRetailer relation = order.getRelation();
                relation.setCreditUsed(relation.getCreditUsed().subtract(order.getTotalAmount()));
                relationRepository.save(relation);
            }
        }

        order.cancel(reason);
        orderRepository.save(order);

        log.info("B2B Order {} cancelled: {}", order.getReference(), reason);
        return OrderResponse.fromEntity(order);
    }

    public Page<OrderResponse> getWholesalerOrders(User user, OrderStatus status, Pageable pageable) {
        MerchantProfile wholesaler = getWholesalerProfile(user);

        Page<B2BOrder> orders = status != null ?
                orderRepository.findByWholesalerAndStatusOrderByCreatedAtDesc(wholesaler, status, pageable) :
                orderRepository.findByWholesalerOrderByCreatedAtDesc(wholesaler, pageable);

        return orders.map(OrderResponse::fromEntity);
    }

    public Page<OrderResponse> getRetailerOrders(User user, OrderStatus status, Pageable pageable) {
        MerchantProfile retailer = getRetailerProfile(user);

        Page<B2BOrder> orders = status != null ?
                orderRepository.findByRetailerAndStatusOrderByCreatedAtDesc(retailer, status, pageable) :
                orderRepository.findByRetailerOrderByCreatedAtDesc(retailer, pageable);

        return orders.map(OrderResponse::fromEntity);
    }

    public OrderResponse getOrder(User user, String orderReference) {
        B2BOrder order = getOrderByReference(orderReference);
        MerchantProfile merchant = merchantRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-B2B-007", "Profil marchand non trouvé"));

        boolean hasAccess = order.getWholesaler().getId().equals(merchant.getId()) ||
                order.getRetailer().getId().equals(merchant.getId());

        if (!hasAccess) {
            throw new JufaException("JUFA-B2B-002", "Accès non autorisé");
        }

        return OrderResponse.fromEntity(order);
    }

    public long countPendingOrders(User user) {
        MerchantProfile wholesaler = getWholesalerProfile(user);
        return orderRepository.countByWholesalerAndStatus(wholesaler, OrderStatus.PENDING);
    }

    private B2BOrder getOrderByReference(String reference) {
        return orderRepository.findByReference(reference)
                .orElseThrow(() -> new JufaException("JUFA-B2B-016", "Commande non trouvée"));
    }

    private MerchantProfile getWholesalerProfile(User user) {
        MerchantProfile merchant = merchantRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-B2B-007", "Profil marchand non trouvé"));

        if (merchant.getMerchantType() != MerchantType.WHOLESALER) {
            throw new JufaException("JUFA-B2B-006", "Cette action est réservée aux grossistes");
        }
        return merchant;
    }

    private MerchantProfile getRetailerProfile(User user) {
        MerchantProfile merchant = merchantRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-B2B-007", "Profil marchand non trouvé"));

        if (merchant.getMerchantType() != MerchantType.RETAILER) {
            throw new JufaException("JUFA-B2B-017", "Cette action est réservée aux détaillants");
        }
        return merchant;
    }

    private String generateReference() {
        return "CMD" + System.currentTimeMillis() + 
                String.format("%04d", (int)(Math.random() * 10000));
    }
}
