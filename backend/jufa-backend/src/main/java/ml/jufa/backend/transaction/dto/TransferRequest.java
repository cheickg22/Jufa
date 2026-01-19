package ml.jufa.backend.transaction.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class TransferRequest {
    
    @NotBlank(message = "Receiver phone is required")
    private String receiverPhone;
    
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "100", message = "Minimum transfer amount is 100 XOF")
    private BigDecimal amount;
    
    private String description;
    
    private String pin;
}
