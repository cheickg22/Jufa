package ml.jufa.backend.b2b.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CategoryRequest {

    @NotBlank(message = "Category name is required")
    @Size(max = 100)
    private String name;

    private String description;

    private String imageUrl;

    private Integer displayOrder = 0;

    private Boolean active = true;
}
