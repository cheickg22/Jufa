package ml.jufa.backend.qrpayment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.qrpayment.entity.QrCode;
import ml.jufa.backend.qrpayment.entity.QrCodeType;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QrCodeResponse {

    private UUID id;
    private String qrToken;
    private QrCodeType qrType;
    private BigDecimal amount;
    private String description;
    private LocalDateTime expiresAt;
    private Boolean active;
    private Integer scanCount;
    private MerchantInfo merchant;
    private LocalDateTime createdAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MerchantInfo {
        private UUID id;
        private String phone;
        private String businessName;
    }

    public static QrCodeResponse fromEntity(QrCode qrCode) {
        String businessName = null;
        if (qrCode.getMerchant().getProfile() != null) {
            businessName = qrCode.getMerchant().getProfile().getBusinessName();
        }

        return QrCodeResponse.builder()
                .id(qrCode.getId())
                .qrToken(qrCode.getQrToken())
                .qrType(qrCode.getQrType())
                .amount(qrCode.getAmount())
                .description(qrCode.getDescription())
                .expiresAt(qrCode.getExpiresAt())
                .active(qrCode.getActive())
                .scanCount(qrCode.getScanCount())
                .merchant(MerchantInfo.builder()
                        .id(qrCode.getMerchant().getId())
                        .phone(qrCode.getMerchant().getPhone())
                        .businessName(businessName)
                        .build())
                .createdAt(qrCode.getCreatedAt())
                .build();
    }
}
