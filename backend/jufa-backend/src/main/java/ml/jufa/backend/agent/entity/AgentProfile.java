package ml.jufa.backend.agent.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;

@Entity
@Table(name = "agent_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgentProfile extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "agent_code", unique = true, length = 20)
    private String agentCode;

    @Column(name = "secret_code_hash")
    private String secretCodeHash;

    @Column(name = "business_name")
    private String businessName;

    @Column(length = 100)
    private String city;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(name = "deposit_commission_rate", precision = 5, scale = 2)
    @Builder.Default
    private BigDecimal depositCommissionRate = new BigDecimal("1.0");

    @Column(name = "withdrawal_commission_rate", precision = 5, scale = 2)
    @Builder.Default
    private BigDecimal withdrawalCommissionRate = new BigDecimal("1.5");

    @Column(name = "verified")
    @Builder.Default
    private Boolean verified = false;

    public boolean hasSecretCode() {
        return secretCodeHash != null && !secretCodeHash.isEmpty();
    }

    public String getFullName() {
        if (user != null && user.getProfile() != null) {
            String firstName = user.getProfile().getFirstName();
            String lastName = user.getProfile().getLastName();
            if (firstName != null || lastName != null) {
                return ((firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "")).trim();
            }
        }
        return businessName != null ? businessName : user != null ? user.getPhone() : null;
    }
}
