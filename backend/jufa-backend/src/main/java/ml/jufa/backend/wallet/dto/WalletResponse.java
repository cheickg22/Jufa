package ml.jufa.backend.wallet.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletResponse {
    
    private UUID id;
    private WalletType walletType;
    private String currency;
    private BigDecimal balance;
    private BigDecimal availableBalance;
    private Wallet.WalletStatus status;
    private LocalDateTime createdAt;
    
    public static WalletResponse fromEntity(Wallet wallet) {
        return WalletResponse.builder()
            .id(wallet.getId())
            .walletType(wallet.getWalletType())
            .currency(wallet.getCurrency())
            .balance(wallet.getBalance())
            .availableBalance(wallet.getAvailableBalance())
            .status(wallet.getStatus())
            .createdAt(wallet.getCreatedAt())
            .build();
    }
}
