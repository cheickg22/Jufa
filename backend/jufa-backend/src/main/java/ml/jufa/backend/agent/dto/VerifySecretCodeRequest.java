package ml.jufa.backend.agent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VerifySecretCodeRequest {

    @NotBlank(message = "Le code secret est obligatoire")
    @Pattern(regexp = "^\\d{4}$", message = "Le code secret doit contenir 4 chiffres")
    private String secretCode;
}
