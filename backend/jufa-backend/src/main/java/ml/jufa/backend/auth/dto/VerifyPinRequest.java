package ml.jufa.backend.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class VerifyPinRequest {
    
    @NotBlank(message = "PIN is required")
    @Size(min = 4, max = 6, message = "PIN must be 4-6 digits")
    private String pin;
}
