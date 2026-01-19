package ml.jufa.backend.mobilemoney.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.mobilemoney.dto.*;
import ml.jufa.backend.mobilemoney.entity.*;
import ml.jufa.backend.mobilemoney.repository.MobileMoneyOperationRepository;
import ml.jufa.backend.notification.service.PushNotificationService;
import ml.jufa.backend.transaction.entity.Transaction;
import ml.jufa.backend.transaction.entity.TransactionStatus;
import ml.jufa.backend.transaction.entity.TransactionType;
import ml.jufa.backend.transaction.repository.TransactionRepository;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import ml.jufa.backend.wallet.repository.WalletRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MobileMoneyService {

    private final MobileMoneyOperationRepository operationRepository;
    private final WalletRepository walletRepository;
    private final TransactionRepository transactionRepository;
    private final PushNotificationService pushNotificationService;

    private static final BigDecimal DEPOSIT_FEE_PERCENT = new BigDecimal("0.00");
    private static final BigDecimal WITHDRAWAL_FEE_PERCENT = new BigDecimal("0.015");
    private static final BigDecimal MIN_DEPOSIT = new BigDecimal("100");
    private static final BigDecimal MAX_DEPOSIT = new BigDecimal("5000000");
    private static final BigDecimal MIN_WITHDRAWAL = new BigDecimal("500");
    private static final BigDecimal MAX_WITHDRAWAL = new BigDecimal("2000000");
    private static final int OPERATION_EXPIRY_MINUTES = 15;

    public List<ProviderInfoResponse> getProviders() {
        return Arrays.stream(MobileMoneyProvider.values())
                .map(provider -> ProviderInfoResponse.builder()
                        .provider(provider)
                        .name(provider.getDisplayName())
                        .code(provider.getCode())
                        .depositEnabled(true)
                        .withdrawalEnabled(true)
                        .minDeposit(MIN_DEPOSIT)
                        .maxDeposit(MAX_DEPOSIT)
                        .minWithdrawal(MIN_WITHDRAWAL)
                        .maxWithdrawal(MAX_WITHDRAWAL)
                        .depositFeePercent(DEPOSIT_FEE_PERCENT.multiply(new BigDecimal("100")))
                        .withdrawalFeePercent(WITHDRAWAL_FEE_PERCENT.multiply(new BigDecimal("100")))
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public MobileMoneyOperationResponse initiateDeposit(User user, DepositRequest request) {
        validateDepositAmount(request.getAmount());

        BigDecimal fee = calculateDepositFee(request.getAmount());

        MobileMoneyOperation operation = MobileMoneyOperation.builder()
                .reference(generateReference("DEP"))
                .operationType(MobileMoneyOperationType.DEPOSIT)
                .provider(request.getProvider())
                .status(MobileMoneyOperationStatus.PENDING)
                .user(user)
                .phoneNumber(request.getPhoneNumber())
                .amount(request.getAmount())
                .fee(fee)
                .description("Dépôt via " + request.getProvider().getDisplayName())
                .expiresAt(LocalDateTime.now().plusMinutes(OPERATION_EXPIRY_MINUTES))
                .build();

        operationRepository.save(operation);
        log.info("Deposit initiated: {} XOF via {} for user {}", 
                request.getAmount(), request.getProvider(), user.getPhone());

        initiateProviderDeposit(operation);

        return MobileMoneyOperationResponse.fromEntity(operation);
    }

    @Transactional
    public MobileMoneyOperationResponse initiateWithdrawal(User user, WithdrawalRequest request) {
        validateWithdrawalAmount(request.getAmount());

        Wallet wallet = getDefaultWallet(user);
        BigDecimal fee = calculateWithdrawalFee(request.getAmount());
        BigDecimal totalDebit = request.getAmount().add(fee);

        if (wallet.getAvailableBalance().compareTo(totalDebit) < 0) {
            throw new JufaException("JUFA-MOMO-003", "Solde insuffisant");
        }

        Wallet lockedWallet = walletRepository.findWithLockById(wallet.getId())
                .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));

        lockedWallet.debit(totalDebit);
        walletRepository.save(lockedWallet);

        MobileMoneyOperation operation = MobileMoneyOperation.builder()
                .reference(generateReference("WDR"))
                .operationType(MobileMoneyOperationType.WITHDRAWAL)
                .provider(request.getProvider())
                .status(MobileMoneyOperationStatus.PROCESSING)
                .user(user)
                .phoneNumber(request.getPhoneNumber())
                .amount(request.getAmount())
                .fee(fee)
                .description("Retrait vers " + request.getProvider().getDisplayName())
                .expiresAt(LocalDateTime.now().plusMinutes(OPERATION_EXPIRY_MINUTES))
                .build();

        operationRepository.save(operation);
        log.info("Withdrawal initiated: {} XOF via {} for user {}", 
                request.getAmount(), request.getProvider(), user.getPhone());

        processWithdrawalAsync(operation, lockedWallet);

        return MobileMoneyOperationResponse.fromEntity(operation);
    }

    @Transactional
    public MobileMoneyOperationResponse confirmDeposit(User user, ConfirmOperationRequest request) {
        MobileMoneyOperation operation = operationRepository.findByReference(request.getReference())
                .orElseThrow(() -> new JufaException("JUFA-MOMO-004", "Opération non trouvée"));

        if (!operation.getUser().getId().equals(user.getId())) {
            throw new JufaException("JUFA-MOMO-005", "Accès non autorisé");
        }

        if (operation.getOperationType() != MobileMoneyOperationType.DEPOSIT) {
            throw new JufaException("JUFA-MOMO-006", "Type d'opération invalide");
        }

        if (operation.getStatus() != MobileMoneyOperationStatus.AWAITING_CONFIRMATION) {
            throw new JufaException("JUFA-MOMO-007", "L'opération ne peut pas être confirmée");
        }

        if (operation.getExpiresAt().isBefore(LocalDateTime.now())) {
            operation.expire();
            operationRepository.save(operation);
            throw new JufaException("JUFA-MOMO-008", "L'opération a expiré");
        }

        boolean verified = verifyProviderPayment(operation, request.getOtp());
        if (!verified) {
            throw new JufaException("JUFA-MOMO-009", "Vérification du paiement échouée");
        }

        Wallet wallet = getDefaultWallet(user);
        Wallet lockedWallet = walletRepository.findWithLockById(wallet.getId())
                .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));

        BigDecimal netAmount = operation.getAmount().subtract(operation.getFee());
        lockedWallet.credit(netAmount);
        walletRepository.save(lockedWallet);

        String providerTxId = "PROV-" + System.currentTimeMillis();
        operation.complete(providerTxId);
        operationRepository.save(operation);

        createDepositTransaction(operation, lockedWallet);

        pushNotificationService.sendTransactionReceived(user, netAmount, 
                operation.getProvider().getDisplayName(), operation.getReference());

        log.info("Deposit completed: {} XOF (net: {}) for user {}", 
                operation.getAmount(), netAmount, user.getPhone());

        return MobileMoneyOperationResponse.fromEntity(operation);
    }

    @Transactional
    public MobileMoneyOperationResponse cancelOperation(User user, String reference) {
        MobileMoneyOperation operation = operationRepository.findByReference(reference)
                .orElseThrow(() -> new JufaException("JUFA-MOMO-004", "Opération non trouvée"));

        if (!operation.getUser().getId().equals(user.getId())) {
            throw new JufaException("JUFA-MOMO-005", "Accès non autorisé");
        }

        if (operation.getStatus() == MobileMoneyOperationStatus.COMPLETED) {
            throw new JufaException("JUFA-MOMO-010", "Impossible d'annuler une opération complétée");
        }

        if (operation.getStatus() == MobileMoneyOperationStatus.CANCELLED) {
            throw new JufaException("JUFA-MOMO-011", "L'opération est déjà annulée");
        }

        if (operation.getOperationType() == MobileMoneyOperationType.WITHDRAWAL &&
                operation.getStatus() == MobileMoneyOperationStatus.PROCESSING) {
            Wallet wallet = getDefaultWallet(user);
            Wallet lockedWallet = walletRepository.findWithLockById(wallet.getId())
                    .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));
            
            lockedWallet.credit(operation.getTotalAmount());
            walletRepository.save(lockedWallet);
        }

        operation.cancel();
        operationRepository.save(operation);

        log.info("Operation cancelled: {} for user {}", reference, user.getPhone());

        return MobileMoneyOperationResponse.fromEntity(operation);
    }

    public MobileMoneyOperationResponse getOperation(User user, String reference) {
        MobileMoneyOperation operation = operationRepository.findByReference(reference)
                .orElseThrow(() -> new JufaException("JUFA-MOMO-004", "Opération non trouvée"));

        if (!operation.getUser().getId().equals(user.getId())) {
            throw new JufaException("JUFA-MOMO-005", "Accès non autorisé");
        }

        return MobileMoneyOperationResponse.fromEntity(operation);
    }

    public Page<MobileMoneyOperationResponse> getOperationHistory(User user, Pageable pageable) {
        return operationRepository.findByUserOrderByCreatedAtDesc(user, pageable)
                .map(MobileMoneyOperationResponse::fromEntity);
    }

    public Page<MobileMoneyOperationResponse> getDepositHistory(User user, Pageable pageable) {
        return operationRepository.findByUserAndOperationTypeOrderByCreatedAtDesc(
                        user, MobileMoneyOperationType.DEPOSIT, pageable)
                .map(MobileMoneyOperationResponse::fromEntity);
    }

    public Page<MobileMoneyOperationResponse> getWithdrawalHistory(User user, Pageable pageable) {
        return operationRepository.findByUserAndOperationTypeOrderByCreatedAtDesc(
                        user, MobileMoneyOperationType.WITHDRAWAL, pageable)
                .map(MobileMoneyOperationResponse::fromEntity);
    }

    public BigDecimal calculateDepositFee(BigDecimal amount) {
        return amount.multiply(DEPOSIT_FEE_PERCENT).setScale(0, RoundingMode.CEILING);
    }

    public BigDecimal calculateWithdrawalFee(BigDecimal amount) {
        return amount.multiply(WITHDRAWAL_FEE_PERCENT).setScale(0, RoundingMode.CEILING);
    }

    private void validateDepositAmount(BigDecimal amount) {
        if (amount.compareTo(MIN_DEPOSIT) < 0) {
            throw new JufaException("JUFA-MOMO-001", 
                    "Le montant minimum de dépôt est " + MIN_DEPOSIT + " XOF");
        }
        if (amount.compareTo(MAX_DEPOSIT) > 0) {
            throw new JufaException("JUFA-MOMO-002", 
                    "Le montant maximum de dépôt est " + MAX_DEPOSIT + " XOF");
        }
    }

    private void validateWithdrawalAmount(BigDecimal amount) {
        if (amount.compareTo(MIN_WITHDRAWAL) < 0) {
            throw new JufaException("JUFA-MOMO-001", 
                    "Le montant minimum de retrait est " + MIN_WITHDRAWAL + " XOF");
        }
        if (amount.compareTo(MAX_WITHDRAWAL) > 0) {
            throw new JufaException("JUFA-MOMO-002", 
                    "Le montant maximum de retrait est " + MAX_WITHDRAWAL + " XOF");
        }
    }

    private Wallet getDefaultWallet(User user) {
        WalletType walletType = switch (user.getUserType()) {
            case MERCHANT -> WalletType.B2B;
            case AGENT -> WalletType.AGENT;
            default -> WalletType.B2C;
        };
        
        return walletRepository.findByUserAndWalletType(user, walletType)
                .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));
    }

    private void initiateProviderDeposit(MobileMoneyOperation operation) {
        log.info("[MOCK] Initiating deposit with {}: {} XOF from {}", 
                operation.getProvider(), operation.getAmount(), operation.getPhoneNumber());

        String mockProviderRef = "PREF-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        operation.markAsAwaitingConfirmation(mockProviderRef);
        operationRepository.save(operation);

        log.info("[MOCK] Deposit awaiting confirmation. Provider ref: {}", mockProviderRef);
    }

    @Async
    protected void processWithdrawalAsync(MobileMoneyOperation operation, Wallet wallet) {
        try {
            Thread.sleep(2000);

            log.info("[MOCK] Processing withdrawal with {}: {} XOF to {}", 
                    operation.getProvider(), operation.getAmount(), operation.getPhoneNumber());

            String providerTxId = "WTX-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            
            operation.complete(providerTxId);
            operationRepository.save(operation);

            createWithdrawalTransaction(operation, wallet);

            pushNotificationService.sendTransactionSent(operation.getUser(), operation.getAmount(), 
                    operation.getProvider().getDisplayName(), operation.getReference());

            log.info("[MOCK] Withdrawal completed. Provider TX: {}", providerTxId);

        } catch (Exception e) {
            log.error("Withdrawal failed: {}", e.getMessage());
            operation.fail(e.getMessage());
            operationRepository.save(operation);

            wallet.credit(operation.getTotalAmount());
            walletRepository.save(wallet);

            pushNotificationService.sendTransactionFailed(operation.getUser(), operation.getAmount(), 
                    e.getMessage(), operation.getReference());
        }
    }

    private boolean verifyProviderPayment(MobileMoneyOperation operation, String otp) {
        log.info("[MOCK] Verifying payment for operation {}. OTP: {}", 
                operation.getReference(), otp != null ? "provided" : "not provided");
        return true;
    }

    private void createDepositTransaction(MobileMoneyOperation operation, Wallet wallet) {
        Transaction transaction = Transaction.builder()
                .reference(operation.getReference())
                .type(TransactionType.MOMO_DEPOSIT)
                .status(TransactionStatus.COMPLETED)
                .receiverWallet(wallet)
                .amount(operation.getAmount().subtract(operation.getFee()))
                .fee(operation.getFee())
                .description(operation.getDescription())
                .metadata("{\"provider\":\"" + operation.getProvider().getCode() + 
                        "\",\"providerTxId\":\"" + operation.getProviderTransactionId() + "\"}")
                .build();
        transaction.complete();
        transactionRepository.save(transaction);
    }

    private void createWithdrawalTransaction(MobileMoneyOperation operation, Wallet wallet) {
        Transaction transaction = Transaction.builder()
                .reference(operation.getReference())
                .type(TransactionType.MOMO_WITHDRAWAL)
                .status(TransactionStatus.COMPLETED)
                .senderWallet(wallet)
                .amount(operation.getAmount())
                .fee(operation.getFee())
                .description(operation.getDescription())
                .metadata("{\"provider\":\"" + operation.getProvider().getCode() + 
                        "\",\"providerTxId\":\"" + operation.getProviderTransactionId() + 
                        "\",\"phone\":\"" + operation.getPhoneNumber() + "\"}")
                .build();
        transaction.complete();
        transactionRepository.save(transaction);
    }

    private String generateReference(String prefix) {
        return prefix + System.currentTimeMillis() + 
                String.format("%04d", (int)(Math.random() * 10000));
    }
}
