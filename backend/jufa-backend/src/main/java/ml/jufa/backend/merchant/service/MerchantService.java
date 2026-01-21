package ml.jufa.backend.merchant.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.merchant.dto.*;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import ml.jufa.backend.merchant.entity.MerchantType;
import ml.jufa.backend.merchant.entity.WholesalerRetailer;
import ml.jufa.backend.merchant.repository.MerchantProfileRepository;
import ml.jufa.backend.merchant.repository.WholesalerRetailerRepository;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.entity.UserType;
import ml.jufa.backend.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MerchantService {

    private final MerchantProfileRepository merchantProfileRepository;
    private final WholesalerRetailerRepository wholesalerRetailerRepository;
    private final UserRepository userRepository;

    @Transactional
    public MerchantProfileResponse createMerchantProfile(User user, CreateMerchantProfileRequest request) {
        if (merchantProfileRepository.existsByUser(user)) {
            throw new JufaException("JUFA-MERCHANT-001", "Merchant profile already exists");
        }

        if (user.getUserType() != UserType.MERCHANT) {
            user.setUserType(UserType.MERCHANT);
            userRepository.save(user);
        }

        MerchantProfile profile = MerchantProfile.builder()
                .user(user)
                .merchantType(request.getMerchantType())
                .businessName(request.getBusinessName())
                .businessCategory(request.getBusinessCategory())
                .rccmNumber(request.getRccmNumber())
                .nifNumber(request.getNifNumber())
                .address(request.getAddress())
                .city(request.getCity())
                .gpsLat(request.getGpsLat())
                .gpsLng(request.getGpsLng())
                .verified(false)
                .rating(BigDecimal.ZERO)
                .build();

        profile = merchantProfileRepository.save(profile);
        log.info("Merchant profile created for user {}: {}", user.getPhone(), request.getBusinessName());

        return MerchantProfileResponse.fromEntity(profile);
    }

    public MerchantProfileResponse getMyMerchantProfile(User user) {
        MerchantProfile profile = merchantProfileRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-002", "Merchant profile not found"));
        return MerchantProfileResponse.fromEntity(profile);
    }

    public List<MerchantProfileResponse> getWholesalers(String city) {
        List<MerchantProfile> wholesalers;
        if (city != null && !city.isEmpty()) {
            wholesalers = merchantProfileRepository.findVerifiedWholesalersByCity(city);
        } else {
            wholesalers = merchantProfileRepository.findAllVerifiedWholesalers();
        }
        return wholesalers.stream()
                .map(MerchantProfileResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public RetailerRelationResponse addRetailer(User wholesalerUser, AddRetailerRequest request) {
        MerchantProfile wholesaler = merchantProfileRepository.findByUser(wholesalerUser)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-002", "Wholesaler profile not found"));

        if (wholesaler.getMerchantType() != MerchantType.WHOLESALER) {
            throw new JufaException("JUFA-MERCHANT-003", "Only wholesalers can add retailers");
        }

        MerchantProfile retailer = merchantProfileRepository.findById(request.getRetailerId())
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-004", "Retailer not found"));

        if (retailer.getMerchantType() != MerchantType.RETAILER) {
            throw new JufaException("JUFA-MERCHANT-005", "Target merchant is not a retailer");
        }

        if (wholesalerRetailerRepository.existsByWholesalerAndRetailer(wholesaler, retailer)) {
            throw new JufaException("JUFA-MERCHANT-006", "Relationship already exists");
        }

        WholesalerRetailer relation = WholesalerRetailer.builder()
                .wholesaler(wholesaler)
                .retailer(retailer)
                .status(WholesalerRetailer.RelationStatus.PENDING)
                .creditLimit(request.getCreditLimit() != null ? request.getCreditLimit() : BigDecimal.ZERO)
                .creditUsed(BigDecimal.ZERO)
                .paymentTermsDays(request.getPaymentTermsDays() != null ? request.getPaymentTermsDays() : 0)
                .discountRate(request.getDiscountRate() != null ? request.getDiscountRate() : BigDecimal.ZERO)
                .build();

        relation = wholesalerRetailerRepository.save(relation);
        log.info("Retailer relation created: {} -> {}", wholesaler.getBusinessName(), retailer.getBusinessName());

        return RetailerRelationResponse.fromEntity(relation);
    }

    public List<RetailerRelationResponse> getMyRetailers(User user) {
        MerchantProfile wholesaler = merchantProfileRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-002", "Merchant profile not found"));

        if (wholesaler.getMerchantType() != MerchantType.WHOLESALER) {
            throw new JufaException("JUFA-MERCHANT-003", "Only wholesalers have retailers");
        }

        return wholesalerRetailerRepository.findByWholesaler(wholesaler).stream()
                .map(RetailerRelationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<RetailerRelationResponse> getMyWholesalers(User user) {
        MerchantProfile retailer = merchantProfileRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-002", "Merchant profile not found"));

        return wholesalerRetailerRepository.findByRetailer(retailer).stream()
                .map(RetailerRelationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public RetailerRelationResponse approveRelation(User retailerUser, UUID relationId) {
        WholesalerRetailer relation = wholesalerRetailerRepository.findById(relationId)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-007", "Relation not found"));

        MerchantProfile retailer = merchantProfileRepository.findByUser(retailerUser)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-002", "Merchant profile not found"));

        if (!relation.getRetailer().getId().equals(retailer.getId())) {
            throw new JufaException("JUFA-MERCHANT-008", "Not authorized to approve this relation");
        }

        if (relation.getStatus() != WholesalerRetailer.RelationStatus.PENDING) {
            throw new JufaException("JUFA-MERCHANT-009", "Relation is not pending");
        }

        relation.setStatus(WholesalerRetailer.RelationStatus.ACTIVE);
        relation.setApprovedAt(LocalDateTime.now());
        relation = wholesalerRetailerRepository.save(relation);

        log.info("Relation approved: {} -> {}", relation.getWholesaler().getBusinessName(), retailer.getBusinessName());

        return RetailerRelationResponse.fromEntity(relation);
    }

    @Transactional
    public RetailerRelationResponse updateRelation(User wholesalerUser, UUID relationId, UpdateRetailerRelationRequest request) {
        WholesalerRetailer relation = wholesalerRetailerRepository.findById(relationId)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-007", "Relation not found"));

        MerchantProfile wholesaler = merchantProfileRepository.findByUser(wholesalerUser)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-002", "Merchant profile not found"));

        if (!relation.getWholesaler().getId().equals(wholesaler.getId())) {
            throw new JufaException("JUFA-MERCHANT-008", "Not authorized to update this relation");
        }

        if (request.getCreditLimit() != null) {
            relation.setCreditLimit(request.getCreditLimit());
        }
        if (request.getPaymentTermsDays() != null) {
            relation.setPaymentTermsDays(request.getPaymentTermsDays());
        }
        if (request.getDiscountRate() != null) {
            relation.setDiscountRate(request.getDiscountRate());
        }

        relation = wholesalerRetailerRepository.save(relation);
        return RetailerRelationResponse.fromEntity(relation);
    }

    @Transactional
    public void suspendRelation(User user, UUID relationId) {
        WholesalerRetailer relation = wholesalerRetailerRepository.findById(relationId)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-007", "Relation not found"));

        MerchantProfile merchant = merchantProfileRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-002", "Merchant profile not found"));

        if (!relation.getWholesaler().getId().equals(merchant.getId()) &&
            !relation.getRetailer().getId().equals(merchant.getId())) {
            throw new JufaException("JUFA-MERCHANT-008", "Not authorized to suspend this relation");
        }

        relation.setStatus(WholesalerRetailer.RelationStatus.SUSPENDED);
        wholesalerRetailerRepository.save(relation);

        log.info("Relation suspended: {} <-> {}", relation.getWholesaler().getBusinessName(), relation.getRetailer().getBusinessName());
    }

    public MerchantDashboardResponse getDashboard(User user) {
        MerchantProfile profile = merchantProfileRepository.findByUser(user)
                .orElseThrow(() -> new JufaException("JUFA-MERCHANT-002", "Merchant profile not found"));

        int activeRelations;
        int pendingRelations;
        BigDecimal totalCreditGiven = BigDecimal.ZERO;
        BigDecimal totalCreditUsed = BigDecimal.ZERO;

        if (profile.getMerchantType() == MerchantType.WHOLESALER) {
            List<WholesalerRetailer> relations = wholesalerRetailerRepository.findByWholesaler(profile);
            activeRelations = (int) relations.stream().filter(r -> r.getStatus() == WholesalerRetailer.RelationStatus.ACTIVE).count();
            pendingRelations = (int) relations.stream().filter(r -> r.getStatus() == WholesalerRetailer.RelationStatus.PENDING).count();
            totalCreditGiven = relations.stream().map(WholesalerRetailer::getCreditLimit).reduce(BigDecimal.ZERO, BigDecimal::add);
            totalCreditUsed = relations.stream().map(WholesalerRetailer::getCreditUsed).reduce(BigDecimal.ZERO, BigDecimal::add);
        } else {
            List<WholesalerRetailer> relations = wholesalerRetailerRepository.findByRetailer(profile);
            activeRelations = (int) relations.stream().filter(r -> r.getStatus() == WholesalerRetailer.RelationStatus.ACTIVE).count();
            pendingRelations = (int) relations.stream().filter(r -> r.getStatus() == WholesalerRetailer.RelationStatus.PENDING).count();
            totalCreditGiven = relations.stream().map(WholesalerRetailer::getCreditLimit).reduce(BigDecimal.ZERO, BigDecimal::add);
            totalCreditUsed = relations.stream().map(WholesalerRetailer::getCreditUsed).reduce(BigDecimal.ZERO, BigDecimal::add);
        }

        return MerchantDashboardResponse.builder()
                .profile(MerchantProfileResponse.fromEntity(profile))
                .activeRelations(activeRelations)
                .pendingRelations(pendingRelations)
                .totalCreditGiven(totalCreditGiven)
                .totalCreditUsed(totalCreditUsed)
                .availableCredit(totalCreditGiven.subtract(totalCreditUsed))
                .build();
    }
}
