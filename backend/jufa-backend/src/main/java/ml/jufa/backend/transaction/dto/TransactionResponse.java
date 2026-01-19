package ml.jufa.backend.transaction.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.transaction.entity.Transaction;
import ml.jufa.backend.transaction.entity.TransactionStatus;
import ml.jufa.backend.transaction.entity.TransactionType;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionResponse {
    
    private UUID id;
    private String reference;
    private TransactionType type;
    private TransactionStatus status;
    private BigDecimal amount;
    private BigDecimal fee;
    private String currency;
    private String description;
    private UUID senderWalletId;
    private UUID receiverWalletId;
    private String senderPhone;
    private String receiverPhone;
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;
    
    public static TransactionResponse fromEntity(Transaction tx) {
        return TransactionResponse.builder()
            .id(tx.getId())
            .reference(tx.getReference())
            .type(tx.getType())
            .status(tx.getStatus())
            .amount(tx.getAmount())
            .fee(tx.getFee())
            .currency(tx.getCurrency())
            .description(tx.getDescription())
            .senderWalletId(tx.getSenderWallet() != null ? tx.getSenderWallet().getId() : null)
            .receiverWalletId(tx.getReceiverWallet() != null ? tx.getReceiverWallet().getId() : null)
            .senderPhone(tx.getSenderWallet() != null ? tx.getSenderWallet().getUser().getPhone() : null)
            .receiverPhone(tx.getReceiverWallet() != null ? tx.getReceiverWallet().getUser().getPhone() : null)
            .createdAt(tx.getCreatedAt())
            .completedAt(tx.getCompletedAt())
            .build();
    }
}
