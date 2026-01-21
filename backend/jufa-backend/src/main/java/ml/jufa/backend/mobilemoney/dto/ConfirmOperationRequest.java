package ml.jufa.backend.mobilemoney.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ConfirmOperationRequest {

    @NotBlank(message = "Reference is required")
    private String reference;

    private String otp;
}
