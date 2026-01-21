package ml.jufa.backend.mobilemoney.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import ml.jufa.backend.mobilemoney.entity.MobileMoneyProvider;

import java.math.BigDecimal;

@Data
public class WithdrawalRequest {

    @NotNull(message = "Provider is required")
    private MobileMoneyProvider provider;

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^[0-9]{8,15}$", message = "Invalid phone number format")
    private String phoneNumber;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "500", message = "Minimum withdrawal is 500 XOF")
    @DecimalMax(value = "2000000", message = "Maximum withdrawal is 2,000,000 XOF")
    private BigDecimal amount;
}
