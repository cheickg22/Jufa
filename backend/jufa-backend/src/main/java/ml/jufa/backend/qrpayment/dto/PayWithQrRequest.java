package ml.jufa.backend.qrpayment.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class PayWithQrRequest {

    @NotBlank(message = "QR token is required")
    private String qrToken;

    @DecimalMin(value = "1", message = "Amount must be at least 1")
    private BigDecimal amount;

    private String description;
}
