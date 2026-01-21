package ml.jufa.backend.kyc.repository;

import ml.jufa.backend.kyc.entity.DocumentStatus;
import ml.jufa.backend.kyc.entity.DocumentType;
import ml.jufa.backend.kyc.entity.KycDocument;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface KycDocumentRepository extends JpaRepository<KycDocument, UUID> {
    
    List<KycDocument> findByUser(User user);
    
    List<KycDocument> findByUserId(UUID userId);
    
    Optional<KycDocument> findByUserAndDocumentType(User user, DocumentType documentType);
    
    List<KycDocument> findByUserAndStatus(User user, DocumentStatus status);
    
    List<KycDocument> findByStatus(DocumentStatus status);
    
    long countByUserAndStatus(User user, DocumentStatus status);
    
    boolean existsByUserAndDocumentTypeAndStatus(User user, DocumentType documentType, DocumentStatus status);
}
