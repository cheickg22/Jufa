package ml.jufa.backend.agent.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CashInRequest {

    @NotBlank(message = "Le numéro de téléphone du client est requis")
    private String customerPhone;

    @NotNull(message = "Le montant est requis")
    @DecimalMin(value = "100", message = "Le montant minimum est 100 XOF")
    private BigDecimal amount;

    private String description;
}
