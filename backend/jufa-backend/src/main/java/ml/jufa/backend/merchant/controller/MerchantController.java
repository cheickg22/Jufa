package ml.jufa.backend.merchant.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.merchant.dto.*;
import ml.jufa.backend.merchant.service.MerchantService;
import ml.jufa.backend.user.entity.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/merchants")
@RequiredArgsConstructor
public class MerchantController {

    private final MerchantService merchantService;

    @PostMapping("/profile")
    public ResponseEntity<ApiResponse<MerchantProfileResponse>> createProfile(
            @Valid @RequestBody CreateMerchantProfileRequest request,
            @AuthenticationPrincipal User user) {
        MerchantProfileResponse response = merchantService.createMerchantProfile(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Merchant profile created successfully"));
    }

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<MerchantProfileResponse>> getMyProfile(
            @AuthenticationPrincipal User user) {
        MerchantProfileResponse response = merchantService.getMyMerchantProfile(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<MerchantDashboardResponse>> getDashboard(
            @AuthenticationPrincipal User user) {
        MerchantDashboardResponse response = merchantService.getDashboard(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/wholesalers")
    public ResponseEntity<ApiResponse<List<MerchantProfileResponse>>> getWholesalers(
            @RequestParam(required = false) String city) {
        List<MerchantProfileResponse> response = merchantService.getWholesalers(city);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/retailers")
    public ResponseEntity<ApiResponse<RetailerRelationResponse>> addRetailer(
            @Valid @RequestBody AddRetailerRequest request,
            @AuthenticationPrincipal User user) {
        RetailerRelationResponse response = merchantService.addRetailer(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Retailer invitation sent"));
    }

    @GetMapping("/retailers")
    public ResponseEntity<ApiResponse<List<RetailerRelationResponse>>> getMyRetailers(
            @AuthenticationPrincipal User user) {
        List<RetailerRelationResponse> response = merchantService.getMyRetailers(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/my-wholesalers")
    public ResponseEntity<ApiResponse<List<RetailerRelationResponse>>> getMyWholesalers(
            @AuthenticationPrincipal User user) {
        List<RetailerRelationResponse> response = merchantService.getMyWholesalers(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/relations/{relationId}/approve")
    public ResponseEntity<ApiResponse<RetailerRelationResponse>> approveRelation(
            @PathVariable UUID relationId,
            @AuthenticationPrincipal User user) {
        RetailerRelationResponse response = merchantService.approveRelation(user, relationId);
        return ResponseEntity.ok(ApiResponse.success(response, "Relation approved"));
    }

    @PutMapping("/relations/{relationId}")
    public ResponseEntity<ApiResponse<RetailerRelationResponse>> updateRelation(
            @PathVariable UUID relationId,
            @Valid @RequestBody UpdateRetailerRelationRequest request,
            @AuthenticationPrincipal User user) {
        RetailerRelationResponse response = merchantService.updateRelation(user, relationId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Relation updated"));
    }

    @PostMapping("/relations/{relationId}/suspend")
    public ResponseEntity<ApiResponse<Void>> suspendRelation(
            @PathVariable UUID relationId,
            @AuthenticationPrincipal User user) {
        merchantService.suspendRelation(user, relationId);
        return ResponseEntity.ok(ApiResponse.success(null, "Relation suspended"));
    }
}
