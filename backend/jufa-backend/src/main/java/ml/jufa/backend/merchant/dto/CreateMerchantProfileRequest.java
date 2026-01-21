package ml.jufa.backend.merchant.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import ml.jufa.backend.merchant.entity.MerchantType;

import java.math.BigDecimal;

@Data
public class CreateMerchantProfileRequest {

    @NotNull(message = "Merchant type is required")
    private MerchantType merchantType;

    @NotBlank(message = "Business name is required")
    private String businessName;

    private String businessCategory;
    private String rccmNumber;
    private String nifNumber;
    private String address;
    private String city;
    private BigDecimal gpsLat;
    private BigDecimal gpsLng;
}
