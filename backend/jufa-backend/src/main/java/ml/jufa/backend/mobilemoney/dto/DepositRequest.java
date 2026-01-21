package ml.jufa.backend.mobilemoney.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyProvider;

import java.math.BigDecimal;

@Data
public class DepositRequest {

    @NotNull(message = "Provider is required")
    private MobileMoneyProvider provider;

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^[0-9]{8,15}$", message = "Invalid phone number format")
    private String phoneNumber;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "100", message = "Minimum deposit is 100 XOF")
    @DecimalMax(value = "5000000", message = "Maximum deposit is 5,000,000 XOF")
    private BigDecimal amount;
}
