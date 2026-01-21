package ml.jufa.backend.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateProfileRequest {
    
    @Size(max = 100, message = "First name must be less than 100 characters")
    private String firstName;
    
    @Size(max = 100, message = "Last name must be less than 100 characters")
    private String lastName;
    
    @Email(message = "Invalid email format")
    private String email;
    
    @Size(max = 255, message = "Business name must be less than 255 characters")
    private String businessName;
    
    @Size(max = 100, message = "City must be less than 100 characters")
    private String city;
    
    private String address;
}
