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
public class UpdateSecretCodeRequest {

    @Pattern(regexp = "^\\d{4}$", message = "L'ancien code secret doit contenir 4 chiffres")
    private String oldSecretCode;

    @NotBlank(message = "Le nouveau code secret est obligatoire")
    @Pattern(regexp = "^\\d{4}$", message = "Le nouveau code secret doit contenir 4 chiffres")
    private String newSecretCode;
}
