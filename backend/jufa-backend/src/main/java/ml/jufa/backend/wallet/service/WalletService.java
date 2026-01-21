package ml.jufa.backend.wallet.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ml.jufa.backend.common.exception.JufaException;
import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.wallet.dto.WalletResponse;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import ml.jufa.backend.wallet.repository.WalletRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WalletService {

    private final WalletRepository walletRepository;

    public List<WalletResponse> getUserWallets(User user) {
        return walletRepository.findByUser(user).stream()
            .map(WalletResponse::fromEntity)
            .collect(Collectors.toList());
    }

    public WalletResponse getWalletById(UUID walletId, User user) {
        Wallet wallet = walletRepository.findById(walletId)
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));
        
        if (!wallet.getUser().getId().equals(user.getId())) {
            throw new JufaException("JUFA-WALLET-002", "Access denied to this wallet");
        }
        
        return WalletResponse.fromEntity(wallet);
    }

    public WalletResponse getWalletByType(User user, WalletType walletType) {
        Wallet wallet = walletRepository.findByUserAndWalletType(user, walletType)
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));
        
        return WalletResponse.fromEntity(wallet);
    }

    @Transactional
    public Wallet createWallet(User user, WalletType walletType) {
        walletRepository.findByUserAndWalletType(user, walletType)
            .ifPresent(w -> {
                throw new JufaException("JUFA-WALLET-003", "Wallet of this type already exists");
            });

        Wallet wallet = Wallet.builder()
            .user(user)
            .walletType(walletType)
            .build();

        return walletRepository.save(wallet);
    }

    @Transactional
    public WalletResponse creditWallet(UUID walletId, BigDecimal amount, User user) {
        Wallet wallet = walletRepository.findWithLockById(walletId)
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));
        
        if (!wallet.getUser().getId().equals(user.getId())) {
            throw new JufaException("JUFA-WALLET-002", "Access denied to this wallet");
        }

        if (wallet.getStatus() != Wallet.WalletStatus.ACTIVE) {
            throw new JufaException("JUFA-WALLET-004", "Wallet is not active");
        }

        wallet.credit(amount);
        walletRepository.save(wallet);
        
        log.info("Credited {} {} to wallet {}", amount, wallet.getCurrency(), walletId);
        
        return WalletResponse.fromEntity(wallet);
    }

    @Transactional
    public WalletResponse debitWallet(UUID walletId, BigDecimal amount, User user) {
        Wallet wallet = walletRepository.findWithLockById(walletId)
            .orElseThrow(() -> new JufaException("JUFA-WALLET-001", "Wallet not found"));
        
        if (!wallet.getUser().getId().equals(user.getId())) {
            throw new JufaException("JUFA-WALLET-002", "Access denied to this wallet");
        }

        if (wallet.getStatus() != Wallet.WalletStatus.ACTIVE) {
            throw new JufaException("JUFA-WALLET-004", "Wallet is not active");
        }

        if (wallet.getAvailableBalance().compareTo(amount) < 0) {
            throw new JufaException("JUFA-WALLET-005", "Insufficient balance");
        }

        wallet.debit(amount);
        walletRepository.save(wallet);
        
        log.info("Debited {} {} from wallet {}", amount, wallet.getCurrency(), walletId);
        
        return WalletResponse.fromEntity(wallet);
    }

    public BigDecimal getTotalBalance(User user) {
        return walletRepository.findByUser(user).stream()
            .map(Wallet::getBalance)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
