package ml.jufa.backend.qrpayment.entity;

import jakarta.persistence.*;
import lombok.*;
import ml.jufa.backend.common.entity.BaseEntity;
import ml.jufa.backend.user.entity.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "qr_codes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QrCode extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "merchant_id", nullable = false)
    private User merchant;

    @Column(name = "qr_token", nullable = false, unique = true, length = 64)
    private String qrToken;

    @Enumerated(EnumType.STRING)
    @Column(name = "qr_type", nullable = false)
    private QrCodeType qrType;

    @Column(precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(length = 255)
    private String description;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @Builder.Default
    private Boolean active = true;

    @Column(name = "scan_count")
    @Builder.Default
    private Integer scanCount = 0;

    public boolean isExpired() {
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
    }

    public boolean isValid() {
        return active && !isExpired();
    }

    public void incrementScanCount() {
        this.scanCount++;
    }
}
