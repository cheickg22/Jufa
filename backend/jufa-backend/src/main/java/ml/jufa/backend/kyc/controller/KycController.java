package ml.jufa.backend.kyc.controller;

import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.kyc.dto.KycDocumentResponse;
import ml.jufa.backend.kyc.dto.KycStatusResponse;
import ml.jufa.backend.kyc.entity.DocumentType;
import ml.jufa.backend.kyc.service.KycService;
import ml.jufa.backend.user.entity.User;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/kyc")
@RequiredArgsConstructor
public class KycController {

    private final KycService kycService;

    @GetMapping("/status")
    public ResponseEntity<ApiResponse<KycStatusResponse>> getKycStatus(
            @AuthenticationPrincipal User user) {
        KycStatusResponse status = kycService.getKycStatus(user);
        return ResponseEntity.ok(ApiResponse.success(status));
    }

    @PostMapping(value = "/documents", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<KycDocumentResponse>> uploadDocument(
            @AuthenticationPrincipal User user,
            @RequestParam("documentType") DocumentType documentType,
            @RequestParam("file") MultipartFile file) {
        KycDocumentResponse response = kycService.uploadDocument(user, documentType, file);
        return ResponseEntity.ok(ApiResponse.success(response, "Document uploaded successfully"));
    }

    @GetMapping("/documents")
    public ResponseEntity<ApiResponse<List<KycDocumentResponse>>> getMyDocuments(
            @AuthenticationPrincipal User user) {
        KycStatusResponse status = kycService.getKycStatus(user);
        return ResponseEntity.ok(ApiResponse.success(status.getSubmittedDocuments()));
    }

    @GetMapping("/documents/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<KycDocumentResponse>>> getPendingDocuments() {
        List<KycDocumentResponse> pending = kycService.getPendingDocuments();
        return ResponseEntity.ok(ApiResponse.success(pending));
    }

    @PostMapping("/documents/{documentId}/review")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<KycDocumentResponse>> reviewDocument(
            @PathVariable UUID documentId,
            @RequestParam boolean approved,
            @RequestParam(required = false) String reason,
            @AuthenticationPrincipal User admin) {
        KycDocumentResponse response = kycService.reviewDocument(documentId, approved, reason, admin.getEmail());
        return ResponseEntity.ok(ApiResponse.success(response, approved ? "Document approved" : "Document rejected"));
    }
}
