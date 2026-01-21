package ml.jufa.backend.merchant.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Data
public class AddRetailerRequest {

    @NotNull(message = "Retailer ID is required")
    private UUID retailerId;

    private BigDecimal creditLimit;
    private Integer paymentTermsDays;
    private BigDecimal discountRate;
}
