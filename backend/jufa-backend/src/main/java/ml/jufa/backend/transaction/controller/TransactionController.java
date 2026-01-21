package ml.jufa.backend.transaction.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.transaction.dto.TransactionResponse;
import ml.jufa.backend.transaction.dto.TransferRequest;
import ml.jufa.backend.transaction.service.TransactionService;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/v1/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping("/transfer")
    public ResponseEntity<ApiResponse<TransactionResponse>> transfer(
            @Valid @RequestBody TransferRequest request,
            @AuthenticationPrincipal User user) {
        TransactionResponse response = transactionService.transfer(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Transfer completed successfully"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Page<TransactionResponse>>> getHistory(
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<TransactionResponse> transactions = transactionService.getTransactionHistory(user, pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }

    @GetMapping("/{transactionId}")
    public ResponseEntity<ApiResponse<TransactionResponse>> getTransaction(
            @PathVariable UUID transactionId,
            @AuthenticationPrincipal User user) {
        TransactionResponse response = transactionService.getTransaction(transactionId, user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/reference/{reference}")
    public ResponseEntity<ApiResponse<TransactionResponse>> getByReference(
            @PathVariable String reference,
            @AuthenticationPrincipal User user) {
        TransactionResponse response = transactionService.getTransactionByReference(reference, user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/wallet/{walletId}")
    public ResponseEntity<ApiResponse<Page<TransactionResponse>>> getWalletTransactions(
            @PathVariable UUID walletId,
            @AuthenticationPrincipal User user,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<TransactionResponse> transactions = transactionService.getWalletTransactions(walletId, user, pageable);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }
}
