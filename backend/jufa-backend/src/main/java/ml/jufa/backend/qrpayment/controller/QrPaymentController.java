package ml.jufa.backend.qrpayment.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ml.jufa.backend.common.dto.ApiResponse;
import ml.jufa.backend.qrpayment.dto.*;
import ml.jufa.backend.qrpayment.service.QrPaymentService;
import ml.jufa.backend.user.entity.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/qr")
@RequiredArgsConstructor
public class QrPaymentController {

    private final QrPaymentService qrPaymentService;

    @PostMapping("/generate")
    public ResponseEntity<ApiResponse<QrCodeResponse>> generateQrCode(
            @Valid @RequestBody GenerateQrCodeRequest request,
            @AuthenticationPrincipal User user) {
        QrCodeResponse response = qrPaymentService.generateQrCode(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "QR code generated successfully"));
    }

    @GetMapping("/scan/{qrToken}")
    public ResponseEntity<ApiResponse<QrCodeResponse>> scanQrCode(
            @PathVariable String qrToken) {
        QrCodeResponse response = qrPaymentService.getQrCodeInfo(qrToken);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/pay")
    public ResponseEntity<ApiResponse<QrPaymentResponse>> payWithQrCode(
            @Valid @RequestBody PayWithQrRequest request,
            @AuthenticationPrincipal User user) {
        QrPaymentResponse response = qrPaymentService.payWithQrCode(user, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Payment completed successfully"));
    }

    @GetMapping("/my-codes")
    public ResponseEntity<ApiResponse<List<QrCodeResponse>>> getMyQrCodes(
            @AuthenticationPrincipal User user) {
        List<QrCodeResponse> response = qrPaymentService.getMyQrCodes(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/payments")
    public ResponseEntity<ApiResponse<List<QrPaymentResponse>>> getMyPayments(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User user) {
        List<QrPaymentResponse> response = qrPaymentService.getMyQrPayments(user, page, size);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/received")
    public ResponseEntity<ApiResponse<List<QrPaymentResponse>>> getReceivedPayments(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User user) {
        List<QrPaymentResponse> response = qrPaymentService.getReceivedPayments(user, page, size);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/codes/{qrCodeId}")
    public ResponseEntity<ApiResponse<Void>> deactivateQrCode(
            @PathVariable UUID qrCodeId,
            @AuthenticationPrincipal User user) {
        qrPaymentService.deactivateQrCode(user, qrCodeId);
        return ResponseEntity.ok(ApiResponse.success(null, "QR code deactivated"));
    }
}
