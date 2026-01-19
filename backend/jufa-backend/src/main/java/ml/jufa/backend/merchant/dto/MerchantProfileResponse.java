package ml.jufa.backend.merchant.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.merchant.entity.MerchantProfile;
import ml.jufa.backend.merchant.entity.MerchantType;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MerchantProfileResponse {

    private UUID id;
    private UUID userId;
    private String phone;
    private MerchantType merchantType;
    private String businessName;
    private String businessCategory;
    private String rccmNumber;
    private String nifNumber;
    private String address;
    private String city;
    private BigDecimal gpsLat;
    private BigDecimal gpsLng;
    private String logoUrl;
    private Boolean verified;
    private BigDecimal rating;

    public static MerchantProfileResponse fromEntity(MerchantProfile profile) {
        return MerchantProfileResponse.builder()
                .id(profile.getId())
                .userId(profile.getUser().getId())
                .phone(profile.getUser().getPhone())
                .merchantType(profile.getMerchantType())
                .businessName(profile.getBusinessName())
                .businessCategory(profile.getBusinessCategory())
                .rccmNumber(profile.getRccmNumber())
                .nifNumber(profile.getNifNumber())
                .address(profile.getAddress())
                .city(profile.getCity())
                .gpsLat(profile.getGpsLat())
                .gpsLng(profile.getGpsLng())
                .logoUrl(profile.getLogoUrl())
                .verified(profile.getVerified())
                .rating(profile.getRating())
                .build();
    }
}
