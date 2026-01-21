package ml.jufa.backend.agent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.agent.entity.AgentTransaction;
import ml.jufa.backend.agent.entity.AgentTransactionStatus;
import ml.jufa.backend.agent.entity.AgentTransactionType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentTransactionResponse {

    private String id;
    private String reference;
    private AgentTransactionType transactionType;
    private String transactionTypeName;
    private AgentTransactionStatus status;
    private String statusName;
    private String customerId;
    private String customerPhone;
    private BigDecimal amount;
    private BigDecimal fee;
    private BigDecimal totalAmount;
    private BigDecimal agentCommission;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;

    public static AgentTransactionResponse fromEntity(AgentTransaction transaction) {
        return AgentTransactionResponse.builder()
                .id(transaction.getId().toString())
                .reference(transaction.getReference())
                .transactionType(transaction.getTransactionType())
                .transactionTypeName(transaction.getTransactionType().getDisplayName())
                .status(transaction.getStatus())
                .statusName(transaction.getStatus().getDisplayName())
                .customerId(transaction.getCustomer().getId().toString())
                .customerPhone(maskPhone(transaction.getCustomerPhone()))
                .amount(transaction.getAmount())
                .fee(transaction.getFee())
                .totalAmount(transaction.getTotalAmount())
                .agentCommission(transaction.getAgentCommission())
                .description(transaction.getDescription())
                .createdAt(transaction.getCreatedAt())
                .completedAt(transaction.getCompletedAt())
                .build();
    }

    private static String maskPhone(String phone) {
        if (phone == null || phone.length() < 4) return phone;
        return phone.substring(0, 2) + "****" + phone.substring(phone.length() - 2);
    }
}
