package ml.jufa.backend.agent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.wallet.entity.Wallet;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientSearchResponse {

    private String phone;
    private String name;
    private String walletNumber;
    private BigDecimal balance;

    public static ClientSearchResponse fromUserAndWallet(User user, Wallet wallet) {
        String name = null;
        if (user.getProfile() != null) {
            String firstName = user.getProfile().getFirstName();
            String lastName = user.getProfile().getLastName();
            if (firstName != null || lastName != null) {
                name = ((firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "")).trim();
            }
        }

        return ClientSearchResponse.builder()
                .phone(user.getPhone())
                .name(name)
                .walletNumber(wallet != null ? wallet.getId().toString() : null)
                .balance(wallet != null ? wallet.getBalance() : BigDecimal.ZERO)
                .build();
    }
}
