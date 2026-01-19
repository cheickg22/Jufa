package ml.jufa.backend.agent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.agent.entity.AgentProfile;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentProfileResponse {

    private UUID id;
    private String agentCode;
    private String fullName;
    private String businessName;
    private String phone;
    private String city;
    private String address;
    private BigDecimal depositCommissionRate;
    private BigDecimal withdrawalCommissionRate;
    private Boolean verified;
    private Boolean hasSecretCode;

    public static AgentProfileResponse fromEntity(AgentProfile profile) {
        return AgentProfileResponse.builder()
                .id(profile.getId())
                .agentCode(profile.getAgentCode())
                .fullName(profile.getFullName())
                .businessName(profile.getBusinessName())
                .phone(profile.getUser() != null ? profile.getUser().getPhone() : null)
                .city(profile.getCity())
                .address(profile.getAddress())
                .depositCommissionRate(profile.getDepositCommissionRate())
                .withdrawalCommissionRate(profile.getWithdrawalCommissionRate())
                .verified(profile.getVerified())
                .hasSecretCode(profile.hasSecretCode())
                .build();
    }
}
