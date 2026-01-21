package ml.jufa.backend.qrpayment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.qrpayment.entity.QrPayment;
import ml.jufa.backend.qrpayment.entity.QrPaymentStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QrPaymentResponse {

    private UUID id;
    private UUID qrCodeId;
    private BigDecimal amount;
    private QrPaymentStatus status;
    private String transactionReference;
    private PayerInfo payer;
    private MerchantInfo merchant;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PayerInfo {
        private UUID id;
        private String phone;
        private String name;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MerchantInfo {
        private UUID id;
        private String phone;
        private String businessName;
    }

    public static QrPaymentResponse fromEntity(QrPayment payment) {
        String payerName = null;
        if (payment.getPayer().getProfile() != null) {
            payerName = payment.getPayer().getProfile().getFirstName();
        }

        String merchantName = null;
        if (payment.getMerchant().getProfile() != null) {
            merchantName = payment.getMerchant().getProfile().getBusinessName();
        }

        return QrPaymentResponse.builder()
                .id(payment.getId())
                .qrCodeId(payment.getQrCode().getId())
                .amount(payment.getAmount())
                .status(payment.getStatus())
                .transactionReference(payment.getTransaction() != null ? payment.getTransaction().getReference() : null)
                .payer(PayerInfo.builder()
                        .id(payment.getPayer().getId())
                        .phone(payment.getPayer().getPhone())
                        .name(payerName)
                        .build())
                .merchant(MerchantInfo.builder()
                        .id(payment.getMerchant().getId())
                        .phone(payment.getMerchant().getPhone())
                        .businessName(merchantName)
                        .build())
                .completedAt(payment.getCompletedAt())
                .createdAt(payment.getCreatedAt())
                .build();
    }
}
