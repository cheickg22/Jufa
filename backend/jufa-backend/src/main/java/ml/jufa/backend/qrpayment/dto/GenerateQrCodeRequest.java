package ml.jufa.backend.qrpayment.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import ml.jufa.backend.qrpayment.entity.QrCodeType;

import java.math.BigDecimal;

@Data
public class GenerateQrCodeRequest {

    @NotNull(message = "QR code type is required")
    private QrCodeType qrType;

    @DecimalMin(value = "0", message = "Amount must be positive")
    private BigDecimal amount;

    private String description;

    private Integer expiresInMinutes;
}
