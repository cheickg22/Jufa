package ml.jufa.backend.kyc.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import ml.jufa.backend.kyc.entity.DocumentStatus;
import ml.jufa.backend.kyc.entity.DocumentType;
import ml.jufa.backend.kyc.entity.KycDocument;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KycDocumentResponse {
    
    private UUID id;
    private DocumentType documentType;
    private String fileName;
    private DocumentStatus status;
    private String rejectionReason;
    private LocalDateTime createdAt;
    private LocalDateTime reviewedAt;
    
    public static KycDocumentResponse fromEntity(KycDocument doc) {
        return KycDocumentResponse.builder()
            .id(doc.getId())
            .documentType(doc.getDocumentType())
            .fileName(doc.getFileName())
            .status(doc.getStatus())
            .rejectionReason(doc.getRejectionReason())
            .createdAt(doc.getCreatedAt())
            .reviewedAt(doc.getReviewedAt())
            .build();
    }
}
