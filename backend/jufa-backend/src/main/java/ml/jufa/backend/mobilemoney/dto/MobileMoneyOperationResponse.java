package ml.jufa.backend.mobilemoney.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyOperation;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyOperationStatus;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyOperationType;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyProvider;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MobileMoneyOperationResponse {

    private String id;
    private String reference;
    private MobileMoneyOperationType operationType;
    private MobileMoneyProvider provider;
    private String providerName;
    private MobileMoneyOperationStatus status;
    private String phoneNumber;
    private BigDecimal amount;
    private BigDecimal fee;
    private BigDecimal totalAmount;
    private String currency;
    private String description;
    private String failureReason;
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;
    private LocalDateTime expiresAt;

    public static MobileMoneyOperationResponse fromEntity(MobileMoneyOperation operation) {
        return MobileMoneyOperationResponse.builder()
                .id(operation.getId().toString())
                .reference(operation.getReference())
                .operationType(operation.getOperationType())
                .provider(operation.getProvider())
                .providerName(operation.getProvider().getDisplayName())
                .status(operation.getStatus())
                .phoneNumber(maskPhoneNumber(operation.getPhoneNumber()))
                .amount(operation.getAmount())
                .fee(operation.getFee())
                .totalAmount(operation.getTotalAmount())
                .currency(operation.getCurrency())
                .description(operation.getDescription())
                .failureReason(operation.getFailureReason())
                .createdAt(operation.getCreatedAt())
                .completedAt(operation.getCompletedAt())
                .expiresAt(operation.getExpiresAt())
                .build();
    }

    private static String maskPhoneNumber(String phone) {
        if (phone == null || phone.length() < 4) return phone;
        return phone.substring(0, 2) + "****" + phone.substring(phone.length() - 2);
    }
}
