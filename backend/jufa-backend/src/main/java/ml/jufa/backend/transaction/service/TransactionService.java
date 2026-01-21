package ml.jufa.backend.transaction.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.notification.service.PushNotificationService;
import ml.jufa.backend.transaction.dto.TransactionResponse;
import ml.jufa.backend.transaction.dto.TransferRequest;
import ml.jufa.backend.transaction.entity.Transaction;
import ml.jufa.backend.transaction.entity.TransactionStatus;
import ml.jufa.backend.transaction.entity.TransactionType;
import ml.jufa.backend.transaction.repository.TransactionRepository;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.user.repository.UserRepository;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import ml.jufa.backend.wallet.repository.WalletRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final WalletRepository walletRepository;
    private final UserRepository userRepository;
    private final PushNotificationService pushNotificationService;

    private static final BigDecimal TRANSFER_FEE_RATE = new BigDecimal("0.01");
    private static final BigDecimal MAX_FEE = new BigDecimal("5000");

    @Transactional
    public TransactionResponse transfer(User sender, TransferRequest request) {
        User receiver = userRepository.findByPhone(request.getReceiverPhone())
            .orElseThrow(() -> new JufaException("JUFA-TX-001", "Receiver not found"));

        if (sender.getId().equals(receiver.getId())) {
            throw new JufaException("JUFA-TX-002", "Cannot transfer to yourself");
        }

        Wallet senderWallet = walletRepository.findByUserAndWalletType(sender, getDefaultWalletType(sender))
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Sender wallet not found"));

        Wallet receiverWallet = walletRepository.findByUserAndWalletType(receiver, getDefaultWalletType(receiver))
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Receiver wallet not found"));

        if (senderWallet.getStatus() != Wallet.WalletStatus.ACTIVE) {
            throw new JufaException("JUFA-WALLET-004", "Your wallet is not active");
        }

        if (receiverWallet.getStatus() != Wallet.WalletStatus.ACTIVE) {
            throw new JufaException("JUFA-WALLET-004", "Receiver wallet is not active");
        }

        BigDecimal fee = calculateFee(request.getAmount());
        BigDecimal totalAmount = request.getAmount().add(fee);

        if (senderWallet.getAvailableBalance().compareTo(totalAmount) < 0) {
            throw new JufaException("JUFA-WALLET-005", "Insufficient balance");
        }

        Wallet lockedSenderWallet = walletRepository.findWithLockById(senderWallet.getId())
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));
        Wallet lockedReceiverWallet = walletRepository.findWithLockById(receiverWallet.getId())
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));

        Transaction transaction = Transaction.builder()
            .reference(generateReference())
            .type(TransactionType.TRANSFER)
            .status(TransactionStatus.PROCESSING)
            .senderWallet(lockedSenderWallet)
            .receiverWallet(lockedReceiverWallet)
            .amount(request.getAmount())
            .fee(fee)
            .description(request.getDescription())
            .build();

        try {
            lockedSenderWallet.debit(totalAmount);
            lockedReceiverWallet.credit(request.getAmount());

            walletRepository.save(lockedSenderWallet);
            walletRepository.save(lockedReceiverWallet);

            transaction.complete();
            transactionRepository.save(transaction);

            log.info("Transfer completed: {} XOF from {} to {}", 
                request.getAmount(), sender.getPhone(), receiver.getPhone());

            pushNotificationService.sendTransactionSent(sender, request.getAmount(), 
                receiver.getPhone(), transaction.getReference());
            pushNotificationService.sendTransactionReceived(receiver, request.getAmount(), 
                sender.getPhone(), transaction.getReference());

            return TransactionResponse.fromEntity(transaction);

        } catch (Exception e) {
            transaction.fail(e.getMessage());
            transactionRepository.save(transaction);
            
            pushNotificationService.sendTransactionFailed(sender, request.getAmount(), 
                e.getMessage(), transaction.getReference());
            
            throw new JufaException("JUFA-TX-003", "Transfer failed: " + e.getMessage());
        }
    }

    public Page<TransactionResponse> getTransactionHistory(User user, Pageable pageable) {
        Wallet wallet = walletRepository.findByUserAndWalletType(user, getDefaultWalletType(user))
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));

        return transactionRepository.findByWalletId(wallet.getId(), pageable)
            .map(TransactionResponse::fromEntity);
    }

    public Page<TransactionResponse> getWalletTransactions(UUID walletId, User user, Pageable pageable) {
        Wallet wallet = walletRepository.findById(walletId)
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));

        if (!wallet.getUser().getId().equals(user.getId())) {
            throw new JufaException("JUFA-WALLET-002", "Access denied");
        }

        return transactionRepository.findByWalletId(walletId, pageable)
            .map(TransactionResponse::fromEntity);
    }

    public TransactionResponse getTransaction(UUID transactionId, User user) {
        Transaction transaction = transactionRepository.findById(transactionId)
            .orElseThrow(() -> new JufaException("JUFA-TX-004", "Transaction not found"));

        boolean isSender = transaction.getSenderWallet() != null && 
            transaction.getSenderWallet().getUser().getId().equals(user.getId());
        boolean isReceiver = transaction.getReceiverWallet() != null && 
            transaction.getReceiverWallet().getUser().getId().equals(user.getId());

        if (!isSender && !isReceiver) {
            throw new JufaException("JUFA-TX-005", "Access denied to this transaction");
        }

        return TransactionResponse.fromEntity(transaction);
    }

    public TransactionResponse getTransactionByReference(String reference, User user) {
        Transaction transaction = transactionRepository.findByReference(reference)
            .orElseThrow(() -> new JufaException("JUFA-TX-004", "Transaction not found"));

        boolean isSender = transaction.getSenderWallet() != null && 
            transaction.getSenderWallet().getUser().getId().equals(user.getId());
        boolean isReceiver = transaction.getReceiverWallet() != null && 
            transaction.getReceiverWallet().getUser().getId().equals(user.getId());

        if (!isSender && !isReceiver) {
            throw new JufaException("JUFA-TX-005", "Access denied to this transaction");
        }

        return TransactionResponse.fromEntity(transaction);
    }

    private WalletType getDefaultWalletType(User user) {
        return switch (user.getUserType()) {
            case MERCHANT -> WalletType.B2B;
            case AGENT -> WalletType.AGENT;
            default -> WalletType.B2C;
        };
    }

    private BigDecimal calculateFee(BigDecimal amount) {
        BigDecimal fee = amount.multiply(TRANSFER_FEE_RATE);
        return fee.compareTo(MAX_FEE) > 0 ? MAX_FEE : fee;
    }

    private String generateReference() {
        return "JUF" + System.currentTimeMillis() + 
            String.format("%04d", (int)(Math.random() * 10000));
    }
}
