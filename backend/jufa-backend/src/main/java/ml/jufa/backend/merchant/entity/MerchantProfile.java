package ml.jufa.backend.merchant.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;

@Entity
@Table(name = "merchant_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MerchantProfile extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "merchant_type", nullable = false)
    private MerchantType merchantType;

    @Column(name = "business_name", nullable = false)
    private String businessName;

    @Column(name = "business_category", length = 100)
    private String businessCategory;

    @Column(name = "rccm_number", length = 50)
    private String rccmNumber;

    @Column(name = "nif_number", length = 50)
    private String nifNumber;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(length = 100)
    private String city;

    @Column(name = "gps_lat", precision = 10, scale = 8)
    private BigDecimal gpsLat;

    @Column(name = "gps_lng", precision = 11, scale = 8)
    private BigDecimal gpsLng;

    @Column(name = "logo_url", columnDefinition = "TEXT")
    private String logoUrl;

    @Builder.Default
    private Boolean verified = false;

    @Column(precision = 2, scale = 1)
    @Builder.Default
    private BigDecimal rating = BigDecimal.ZERO;
}
