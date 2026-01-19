package ml.jufa.backend.agent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.agent.dto.*;
import ml.jufa.backend.agent.entity.AgentTransactionType;
import ml.jufa.backend.agent.service.AgentService;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/v1/agent")
@RequiredArgsConstructor
@Tag(name = "Agent", description = "Interface agent pour dépôts/retraits cash")
public class AgentController {

    private final AgentService agentService;

    @GetMapping("/dashboard")
    @Operation(summary = "Tableau de bord agent")
    public ResponseEntity<ApiResponse<AgentDashboardResponse>> getDashboard(
            @AuthenticationPrincipal User agent) {
        AgentDashboardResponse dashboard = agentService.getDashboard(agent);
        return ResponseEntity.ok(ApiResponse.success(dashboard));
    }

    @PostMapping("/cash-in")
    @Operation(summary = "Dépôt cash pour un client")
    public ResponseEntity<ApiResponse<AgentTransactionResponse>> processCashIn(
            @AuthenticationPrincipal User agent,
            @Valid @RequestBody CashInRequest request) {
        AgentTransactionResponse response = agentService.processCashIn(agent, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Dépôt effectué avec succès"));
    }

    @PostMapping("/cash-out")
    @Operation(summary = "Retrait cash pour un client")
    public ResponseEntity<ApiResponse<AgentTransactionResponse>> processCashOut(
            @AuthenticationPrincipal User agent,
            @Valid @RequestBody CashOutRequest request) {
        AgentTransactionResponse response = agentService.processCashOut(agent, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Retrait effectué avec succès"));
    }

    @GetMapping("/fees/cash-in")
    @Operation(summary = "Calculer les frais de dépôt")
    public ResponseEntity<ApiResponse<FeeCalculationResponse>> calculateCashInFees(
            @RequestParam BigDecimal amount) {
        FeeCalculationResponse fees = agentService.calculateCashInFees(amount);
        return ResponseEntity.ok(ApiResponse.success(fees));
    }

    @GetMapping("/fees/cash-out")
    @Operation(summary = "Calculer les frais de retrait")
    public ResponseEntity<ApiResponse<FeeCalculationResponse>> calculateCashOutFees(
            @RequestParam BigDecimal amount) {
        FeeCalculationResponse fees = agentService.calculateCashOutFees(amount);
        return ResponseEntity.ok(ApiResponse.success(fees));
    }

    @GetMapping("/transactions")
    @Operation(summary = "Historique des transactions")
    public ResponseEntity<ApiResponse<Page<AgentTransactionResponse>>> getTransactions(
            @AuthenticationPrincipal User agent,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<AgentTransactionResponse> transactions = agentService.getTransactionHistory(agent, pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }

    @GetMapping("/transactions/cash-in")
    @Operation(summary = "Historique des dépôts")
    public ResponseEntity<ApiResponse<Page<AgentTransactionResponse>>> getCashInTransactions(
            @AuthenticationPrincipal User agent,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<AgentTransactionResponse> transactions = agentService.getTransactionsByType(
                agent, AgentTransactionType.CASH_IN, pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }

    @GetMapping("/transactions/cash-out")
    @Operation(summary = "Historique des retraits")
    public ResponseEntity<ApiResponse<Page<AgentTransactionResponse>>> getCashOutTransactions(
            @AuthenticationPrincipal User agent,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<AgentTransactionResponse> transactions = agentService.getTransactionsByType(
                agent, AgentTransactionType.CASH_OUT, pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }

    @GetMapping("/reports")
    @Operation(summary = "Rapports journaliers")
    public ResponseEntity<ApiResponse<List<AgentDailyReportResponse>>> getDailyReports(
            @AuthenticationPrincipal User agent,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<AgentDailyReportResponse> reports = agentService.getDailyReports(agent, startDate, endDate);
        return ResponseEntity.ok(ApiResponse.success(reports));
    }

    @GetMapping("/reports/last-30-days")
    @Operation(summary = "Rapports des 30 derniers jours")
    public ResponseEntity<ApiResponse<List<AgentDailyReportResponse>>> getLast30DaysReports(
            @AuthenticationPrincipal User agent) {
        List<AgentDailyReportResponse> reports = agentService.getLast30DaysReports(agent);
        return ResponseEntity.ok(ApiResponse.success(reports));
    }

    @GetMapping("/profile")
    @Operation(summary = "Profil de l'agent")
    public ResponseEntity<ApiResponse<AgentProfileResponse>> getProfile(
            @AuthenticationPrincipal User agent) {
        AgentProfileResponse profile = agentService.getProfile(agent);
        return ResponseEntity.ok(ApiResponse.success(profile));
    }

    @PostMapping("/verify-secret-code")
    @Operation(summary = "Vérifier le code secret")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> verifySecretCode(
            @AuthenticationPrincipal User agent,
            @Valid @RequestBody VerifySecretCodeRequest request) {
        boolean valid = agentService.verifySecretCode(agent, request.getSecretCode());
        return ResponseEntity.ok(ApiResponse.success(Map.of("success", valid)));
    }

    @PostMapping("/update-secret-code")
    @Operation(summary = "Mettre à jour le code secret")
    public ResponseEntity<ApiResponse<Void>> updateSecretCode(
            @AuthenticationPrincipal User agent,
            @Valid @RequestBody UpdateSecretCodeRequest request) {
        agentService.updateSecretCode(agent, request.getOldSecretCode(), request.getNewSecretCode());
        return ResponseEntity.ok(ApiResponse.success(null, "Code secret mis à jour"));
    }

    @GetMapping("/search-client")
    @Operation(summary = "Rechercher un client par numéro de téléphone")
    public ResponseEntity<ApiResponse<ClientSearchResponse>> searchClient(
            @AuthenticationPrincipal User agent,
            @RequestParam String phone) {
        ClientSearchResponse client = agentService.searchClient(agent, phone);
        return ResponseEntity.ok(ApiResponse.success(client));
    }
}
