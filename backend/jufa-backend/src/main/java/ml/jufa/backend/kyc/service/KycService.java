package ml.jufa.backend.kyc.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.kyc.dto.KycDocumentResponse;
import ml.jufa.backend.kyc.dto.KycStatusResponse;
import ml.jufa.backend.kyc.entity.DocumentStatus;
import ml.jufa.backend.kyc.entity.DocumentType;
import ml.jufa.backend.kyc.entity.KycDocument;
import ml.jufa.backend.kyc.repository.KycDocumentRepository;
import ml.jufa.backend.notification.service.PushNotificationService;
import ml.jufa.backend.user.entity.KycLevel;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class KycService {

    private final KycDocumentRepository kycDocumentRepository;
    private final UserRepository userRepository;
    private final PushNotificationService pushNotificationService;
    
    private static final String UPLOAD_DIR = "uploads/kyc/";

    public KycStatusResponse getKycStatus(User user) {
        List<KycDocument> documents = kycDocumentRepository.findByUser(user);
        
        long approved = documents.stream().filter(d -> d.getStatus() == DocumentStatus.APPROVED).count();
        long pending = documents.stream().filter(d -> d.getStatus() == DocumentStatus.PENDING || d.getStatus() == DocumentStatus.UNDER_REVIEW).count();
        long rejected = documents.stream().filter(d -> d.getStatus() == DocumentStatus.REJECTED).count();
        
        KycLevel nextLevel = getNextLevel(user.getKycLevel());
        List<String> requiredDocs = getRequiredDocuments(nextLevel, user);
        KycStatusResponse.KycLimits limits = KycStatusResponse.getLimits(user.getKycLevel());
        
        return KycStatusResponse.builder()
            .currentLevel(user.getKycLevel())
            .nextLevel(nextLevel)
            .requiredDocuments(requiredDocs)
            .submittedDocuments(documents.stream().map(KycDocumentResponse::fromEntity).collect(Collectors.toList()))
            .approvedCount((int) approved)
            .pendingCount((int) pending)
            .rejectedCount((int) rejected)
            .dailyLimit(limits.getDailyLimit())
            .monthlyLimit(limits.getMonthlyLimit())
            .build();
    }

    @Transactional
    public KycDocumentResponse uploadDocument(User user, DocumentType documentType, MultipartFile file) {
        if (file.isEmpty()) {
            throw new JufaException("JUFA-KYC-001", "File is empty");
        }

        String contentType = file.getContentType();
        if (contentType == null || (!contentType.startsWith("image/") && !contentType.equals("application/pdf"))) {
            throw new JufaException("JUFA-KYC-002", "Only images and PDFs are allowed");
        }

        if (file.getSize() > 10 * 1024 * 1024) {
            throw new JufaException("JUFA-KYC-003", "File size must be less than 10MB");
        }

        kycDocumentRepository.findByUserAndDocumentType(user, documentType)
            .filter(d -> d.getStatus() == DocumentStatus.PENDING || d.getStatus() == DocumentStatus.UNDER_REVIEW)
            .ifPresent(d -> {
                throw new JufaException("JUFA-KYC-004", "Document of this type is already pending review");
            });

        String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
        String fileUrl = saveFile(file, user.getId().toString(), fileName);

        KycDocument document = KycDocument.builder()
            .user(user)
            .documentType(documentType)
            .fileUrl(fileUrl)
            .fileName(file.getOriginalFilename())
            .fileSize(file.getSize())
            .mimeType(contentType)
            .status(DocumentStatus.PENDING)
            .build();

        document = kycDocumentRepository.save(document);
        
        log.info("KYC document uploaded: {} for user {}", documentType, user.getPhone());
        
        return KycDocumentResponse.fromEntity(document);
    }

    @Transactional
    public KycDocumentResponse reviewDocument(UUID documentId, boolean approved, String reason, String reviewerEmail) {
        KycDocument document = kycDocumentRepository.findById(documentId)
            .orElseThrow(() -> new JufaException("JUFA-KYC-005", "Document not found"));

        document.setStatus(approved ? DocumentStatus.APPROVED : DocumentStatus.REJECTED);
        document.setRejectionReason(approved ? null : reason);
        document.setReviewedAt(LocalDateTime.now());
        document.setReviewedBy(reviewerEmail);

        kycDocumentRepository.save(document);

        User user = document.getUser();
        if (approved) {
            KycLevel oldLevel = user.getKycLevel();
            checkAndUpgradeKycLevel(user);
            if (user.getKycLevel().ordinal() > oldLevel.ordinal()) {
                pushNotificationService.sendKycApproved(user, user.getKycLevel().name());
            }
        } else {
            pushNotificationService.sendKycRejected(user, reason != null ? reason : "Document non conforme");
        }

        log.info("KYC document {} {} by {}", documentId, approved ? "approved" : "rejected", reviewerEmail);

        return KycDocumentResponse.fromEntity(document);
    }

    public List<KycDocumentResponse> getPendingDocuments() {
        return kycDocumentRepository.findByStatus(DocumentStatus.PENDING).stream()
            .map(KycDocumentResponse::fromEntity)
            .collect(Collectors.toList());
    }

    private void checkAndUpgradeKycLevel(User user) {
        List<KycDocument> approvedDocs = kycDocumentRepository.findByUserAndStatus(user, DocumentStatus.APPROVED);
        List<DocumentType> approvedTypes = approvedDocs.stream()
            .map(KycDocument::getDocumentType)
            .collect(Collectors.toList());

        KycLevel newLevel = calculateKycLevel(approvedTypes, user);
        
        if (newLevel.ordinal() > user.getKycLevel().ordinal()) {
            user.setKycLevel(newLevel);
            userRepository.save(user);
            log.info("User {} upgraded to KYC {}", user.getPhone(), newLevel);
        }
    }

    private KycLevel calculateKycLevel(List<DocumentType> approvedTypes, User user) {
        boolean hasId = approvedTypes.stream().anyMatch(t -> 
            t == DocumentType.NATIONAL_ID || t == DocumentType.PASSPORT || 
            t == DocumentType.DRIVER_LICENSE || t == DocumentType.VOTER_CARD);
        boolean hasSelfie = approvedTypes.contains(DocumentType.SELFIE);
        boolean hasAddress = approvedTypes.contains(DocumentType.PROOF_OF_ADDRESS);
        boolean hasRccm = approvedTypes.contains(DocumentType.RCCM);
        boolean hasNif = approvedTypes.contains(DocumentType.NIF);
        boolean hasBankStatement = approvedTypes.contains(DocumentType.BANK_STATEMENT);

        if (hasId && hasSelfie && hasAddress && hasRccm && hasNif && hasBankStatement) {
            return KycLevel.LEVEL_3;
        } else if (hasId && hasSelfie && hasAddress) {
            return KycLevel.LEVEL_2;
        } else if (hasId && hasSelfie) {
            return KycLevel.LEVEL_1;
        }
        
        return KycLevel.LEVEL_0;
    }

    private KycLevel getNextLevel(KycLevel current) {
        return switch (current) {
            case LEVEL_0 -> KycLevel.LEVEL_1;
            case LEVEL_1 -> KycLevel.LEVEL_2;
            case LEVEL_2 -> KycLevel.LEVEL_3;
            case LEVEL_3 -> KycLevel.LEVEL_3;
        };
    }

    private List<String> getRequiredDocuments(KycLevel targetLevel, User user) {
        List<String> required = new ArrayList<>();
        
        List<KycDocument> existing = kycDocumentRepository.findByUserAndStatus(user, DocumentStatus.APPROVED);
        List<DocumentType> approved = existing.stream().map(KycDocument::getDocumentType).toList();

        if (targetLevel.ordinal() >= KycLevel.LEVEL_1.ordinal()) {
            if (!hasAnyIdDocument(approved)) {
                required.add("Pièce d'identité (CNI, Passeport, Permis ou Carte d'électeur)");
            }
            if (!approved.contains(DocumentType.SELFIE)) {
                required.add("Selfie avec pièce d'identité");
            }
        }
        
        if (targetLevel.ordinal() >= KycLevel.LEVEL_2.ordinal()) {
            if (!approved.contains(DocumentType.PROOF_OF_ADDRESS)) {
                required.add("Justificatif de domicile (facture récente)");
            }
        }

        if (targetLevel.ordinal() >= KycLevel.LEVEL_3.ordinal()) {
            if (!approved.contains(DocumentType.RCCM)) {
                required.add("RCCM (Registre de Commerce)");
            }
            if (!approved.contains(DocumentType.NIF)) {
                required.add("NIF (Numéro d'Identification Fiscale)");
            }
            if (!approved.contains(DocumentType.BANK_STATEMENT)) {
                required.add("Relevé bancaire des 3 derniers mois");
            }
        }

        return required;
    }

    private boolean hasAnyIdDocument(List<DocumentType> types) {
        return types.stream().anyMatch(t -> 
            t == DocumentType.NATIONAL_ID || t == DocumentType.PASSPORT || 
            t == DocumentType.DRIVER_LICENSE || t == DocumentType.VOTER_CARD);
    }

    private String saveFile(MultipartFile file, String userId, String fileName) {
        try {
            Path uploadPath = Paths.get(UPLOAD_DIR + userId);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            Path filePath = uploadPath.resolve(fileName);
            Files.write(filePath, file.getBytes());
            return filePath.toString();
        } catch (IOException e) {
            log.error("Failed to save file", e);
            throw new JufaException("JUFA-KYC-006", "Failed to save file");
        }
    }
}
