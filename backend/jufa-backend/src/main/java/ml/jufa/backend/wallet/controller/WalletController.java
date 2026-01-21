package ml.jufa.backend.wallet.controller;

import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.wallet.dto.WalletResponse;
import ml.jufa.backend.wallet.service.WalletService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/wallets")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<WalletResponse>>> getMyWallets(
            @AuthenticationPrincipal User user) {
        List<WalletResponse> wallets = walletService.getUserWallets(user);
        return ResponseEntity.ok(ApiResponse.success(wallets));
    }

    @GetMapping("/{walletId}")
    public ResponseEntity<ApiResponse<WalletResponse>> getWallet(
            @PathVariable UUID walletId,
            @AuthenticationPrincipal User user) {
        WalletResponse wallet = walletService.getWalletById(walletId, user);
        return ResponseEntity.ok(ApiResponse.success(wallet));
    }

    @GetMapping("/balance")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getTotalBalance(
            @AuthenticationPrincipal User user) {
        BigDecimal totalBalance = walletService.getTotalBalance(user);
        return ResponseEntity.ok(ApiResponse.success(Map.of(
            "totalBalance", totalBalance,
            "currency", "XOF"
        )));
    }
}
