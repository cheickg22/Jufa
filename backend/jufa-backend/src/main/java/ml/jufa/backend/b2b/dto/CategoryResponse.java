package ml.jufa.backend.b2b.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.b2b.entity.ProductCategory;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryResponse {

    private String id;
    private String name;
    private String description;
    private String imageUrl;
    private Integer displayOrder;
    private boolean active;

    public static CategoryResponse fromEntity(ProductCategory category) {
        return CategoryResponse.builder()
                .id(category.getId().toString())
                .name(category.getName())
                .description(category.getDescription())
                .imageUrl(category.getImageUrl())
                .displayOrder(category.getDisplayOrder())
                .active(category.getActive())
                .build();
    }
}
