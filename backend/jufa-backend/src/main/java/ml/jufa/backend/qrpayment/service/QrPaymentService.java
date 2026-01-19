package ml.jufa.backend.qrpayment.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.qrpayment.dto.*;
import ml.jufa.backend.qrpayment.entity.*;
import ml.jufa.backend.qrpayment.repository.QrCodeRepository;
import ml.jufa.backend.qrpayment.repository.QrPaymentRepository;
import ml.jufa.backend.transaction.dto.TransferRequest;
import ml.jufa.backend.transaction.dto.TransactionResponse;
import ml.jufa.backend.transaction.service.TransactionService;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class QrPaymentService {

    private final QrCodeRepository qrCodeRepository;
    private final QrPaymentRepository qrPaymentRepository;
    private final TransactionService transactionService;
    private static final SecureRandom secureRandom = new SecureRandom();

    @Transactional
    public QrCodeResponse generateQrCode(User merchant, GenerateQrCodeRequest request) {
        String qrToken = generateUniqueToken();

        LocalDateTime expiresAt = null;
        if (request.getQrType() == QrCodeType.DYNAMIC && request.getExpiresInMinutes() != null) {
            expiresAt = LocalDateTime.now().plusMinutes(request.getExpiresInMinutes());
        }

        QrCode qrCode = QrCode.builder()
                .merchant(merchant)
                .qrToken(qrToken)
                .qrType(request.getQrType())
                .amount(request.getAmount())
                .description(request.getDescription())
                .expiresAt(expiresAt)
                .active(true)
                .scanCount(0)
                .build();

        qrCode = qrCodeRepository.save(qrCode);
        log.info("QR code generated for merchant {}: {}", merchant.getPhone(), qrToken);

        return QrCodeResponse.fromEntity(qrCode);
    }

    public QrCodeResponse getQrCodeInfo(String qrToken) {
        QrCode qrCode = qrCodeRepository.findByQrToken(qrToken)
                .orElseThrow(() -> new JufaException("JUFA-QR-001", "QR code not found"));

        if (!qrCode.isValid()) {
            throw new JufaException("JUFA-QR-002", "QR code is expired or inactive");
        }

        qrCode.incrementScanCount();
        qrCodeRepository.save(qrCode);

        return QrCodeResponse.fromEntity(qrCode);
    }

    @Transactional
    public QrPaymentResponse payWithQrCode(User payer, PayWithQrRequest request) {
        QrCode qrCode = qrCodeRepository.findByQrToken(request.getQrToken())
                .orElseThrow(() -> new JufaException("JUFA-QR-001", "QR code not found"));

        if (!qrCode.isValid()) {
            throw new JufaException("JUFA-QR-002", "QR code is expired or inactive");
        }

        if (qrCode.getMerchant().getId().equals(payer.getId())) {
            throw new JufaException("JUFA-QR-003", "Cannot pay to your own QR code");
        }

        BigDecimal paymentAmount;
        if (qrCode.getQrType() == QrCodeType.DYNAMIC && qrCode.getAmount() != null) {
            paymentAmount = qrCode.getAmount();
        } else {
            if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
                throw new JufaException("JUFA-QR-004", "Amount is required for static QR codes");
            }
            paymentAmount = request.getAmount();
        }

        QrPayment qrPayment = QrPayment.builder()
                .qrCode(qrCode)
                .payer(payer)
                .merchant(qrCode.getMerchant())
                .amount(paymentAmount)
                .status(QrPaymentStatus.PENDING)
                .build();

        qrPayment = qrPaymentRepository.save(qrPayment);

        try {
            TransferRequest transferRequest = new TransferRequest();
            transferRequest.setReceiverPhone(qrCode.getMerchant().getPhone());
            transferRequest.setAmount(paymentAmount);
            transferRequest.setDescription(request.getDescription() != null ? 
                    request.getDescription() : 
                    "Paiement QR - " + (qrCode.getDescription() != null ? qrCode.getDescription() : qrCode.getQrToken()));

            TransactionResponse transactionResponse = transactionService.transfer(payer, transferRequest);

            qrPayment.complete(null);
            qrPaymentRepository.save(qrPayment);

            if (qrCode.getQrType() == QrCodeType.DYNAMIC) {
                qrCode.setActive(false);
                qrCodeRepository.save(qrCode);
            }

            log.info("QR payment completed: {} -> {} for {} XOF", 
                    payer.getPhone(), qrCode.getMerchant().getPhone(), paymentAmount);

            return QrPaymentResponse.fromEntity(qrPayment);

        } catch (Exception e) {
            qrPayment.cancel(e.getMessage());
            qrPaymentRepository.save(qrPayment);
            throw e;
        }
    }

    public List<QrCodeResponse> getMyQrCodes(User merchant) {
        return qrCodeRepository.findByMerchantOrderByCreatedAtDesc(merchant).stream()
                .map(QrCodeResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<QrPaymentResponse> getMyQrPayments(User user, int page, int size) {
        return qrPaymentRepository.findByPayerOrMerchantOrderByCreatedAtDesc(user, PageRequest.of(page, size)).stream()
                .map(QrPaymentResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<QrPaymentResponse> getReceivedPayments(User merchant, int page, int size) {
        return qrPaymentRepository.findByMerchantOrderByCreatedAtDesc(merchant, PageRequest.of(page, size)).stream()
                .map(QrPaymentResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deactivateQrCode(User merchant, UUID qrCodeId) {
        QrCode qrCode = qrCodeRepository.findById(qrCodeId)
                .orElseThrow(() -> new JufaException("JUFA-QR-001", "QR code not found"));

        if (!qrCode.getMerchant().getId().equals(merchant.getId())) {
            throw new JufaException("JUFA-QR-005", "Not authorized to deactivate this QR code");
        }

        qrCode.setActive(false);
        qrCodeRepository.save(qrCode);

        log.info("QR code deactivated: {}", qrCodeId);
    }

    private String generateUniqueToken() {
        byte[] randomBytes = new byte[24];
        secureRandom.nextBytes(randomBytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
        
        while (qrCodeRepository.existsByQrToken(token)) {
            secureRandom.nextBytes(randomBytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
        }
        
        return token;
    }
}
