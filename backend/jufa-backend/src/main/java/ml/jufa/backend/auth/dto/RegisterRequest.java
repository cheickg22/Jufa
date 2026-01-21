package ml.jufa.backend.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;
import ml.jufa.backend.user.entity.UserType;

@Data
public class RegisterRequest {
    
    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+223[0-9]{8}$", message = "Invalid Mali phone number format")
    private String phone;
    
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;
    
    private UserType userType = UserType.INDIVIDUAL;
}
