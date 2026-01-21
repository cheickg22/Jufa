package ml.jufa.backend.mobilemoney.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.mobilemoney.dto.*;
import ml.jufa.backend.mobilemoney.service.MobileMoneyService;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/mobile-money")
@RequiredArgsConstructor
@Tag(name = "Mobile Money", description = "Dépôt et retrait via Mobile Money")
public class MobileMoneyController {

    private final MobileMoneyService mobileMoneyService;

    @GetMapping("/providers")
    @Operation(summary = "Liste des providers Mobile Money disponibles")
    public ResponseEntity<ApiResponse<List<ProviderInfoResponse>>> getProviders() {
        List<ProviderInfoResponse> providers = mobileMoneyService.getProviders();
        return ResponseEntity.ok(ApiResponse.success(providers));
    }

    @PostMapping("/deposit")
    @Operation(summary = "Initier un dépôt via Mobile Money")
    public ResponseEntity<ApiResponse<MobileMoneyOperationResponse>> initiateDeposit(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody DepositRequest request) {
        MobileMoneyOperationResponse response = mobileMoneyService.initiateDeposit(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Dépôt initié. Veuillez confirmer le paiement."));
    }

    @PostMapping("/deposit/confirm")
    @Operation(summary = "Confirmer un dépôt après paiement Mobile Money")
    public ResponseEntity<ApiResponse<MobileMoneyOperationResponse>> confirmDeposit(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody ConfirmOperationRequest request) {
        MobileMoneyOperationResponse response = mobileMoneyService.confirmDeposit(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Dépôt confirmé avec succès"));
    }

    @PostMapping("/withdrawal")
    @Operation(summary = "Initier un retrait vers Mobile Money")
    public ResponseEntity<ApiResponse<MobileMoneyOperationResponse>> initiateWithdrawal(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody WithdrawalRequest request) {
        MobileMoneyOperationResponse response = mobileMoneyService.initiateWithdrawal(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Retrait en cours de traitement"));
    }

    @PostMapping("/cancel/{reference}")
    @Operation(summary = "Annuler une opération en attente")
    public ResponseEntity<ApiResponse<MobileMoneyOperationResponse>> cancelOperation(
            @AuthenticationPrincipal User user,
            @PathVariable String reference) {
        MobileMoneyOperationResponse response = mobileMoneyService.cancelOperation(user, reference);
        return ResponseEntity.ok(ApiResponse.success(response, "Opération annulée"));
    }

    @GetMapping("/operations/{reference}")
    @Operation(summary = "Détails d'une opération")
    public ResponseEntity<ApiResponse<MobileMoneyOperationResponse>> getOperation(
            @AuthenticationPrincipal User user,
            @PathVariable String reference) {
        MobileMoneyOperationResponse response = mobileMoneyService.getOperation(user, reference);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/operations")
    @Operation(summary = "Historique de toutes les opérations Mobile Money")
    public ResponseEntity<ApiResponse<Page<MobileMoneyOperationResponse>>> getOperationHistory(
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<MobileMoneyOperationResponse> history = mobileMoneyService.getOperationHistory(user, pageable);
        return ResponseEntity.ok(ApiResponse.success(history));
    }

    @GetMapping("/deposits")
    @Operation(summary = "Historique des dépôts")
    public ResponseEntity<ApiResponse<Page<MobileMoneyOperationResponse>>> getDepositHistory(
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<MobileMoneyOperationResponse> history = mobileMoneyService.getDepositHistory(user, pageable);
        return ResponseEntity.ok(ApiResponse.success(history));
    }

    @GetMapping("/withdrawals")
    @Operation(summary = "Historique des retraits")
    public ResponseEntity<ApiResponse<Page<MobileMoneyOperationResponse>>> getWithdrawalHistory(
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<MobileMoneyOperationResponse> history = mobileMoneyService.getWithdrawalHistory(user, pageable);
        return ResponseEntity.ok(ApiResponse.success(history));
    }
}
