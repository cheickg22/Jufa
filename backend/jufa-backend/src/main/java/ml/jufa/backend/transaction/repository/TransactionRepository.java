package ml.jufa.backend.transaction.repository;

import ml.jufa.backend.transaction.entity.Transaction;
import ml.jufa.backend.transaction.entity.TransactionStatus;
import ml.jufa.backend.wallet.entity.Wallet;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, UUID> {
    
    Optional<Transaction> findByReference(String reference);
    
    Page<Transaction> findBySenderWalletOrReceiverWallet(Wallet sender, Wallet receiver, Pageable pageable);
    
    @Query("SELECT t FROM Transaction t WHERE (t.senderWallet.id = :walletId OR t.receiverWallet.id = :walletId) ORDER BY t.createdAt DESC")
    Page<Transaction> findByWalletId(@Param("walletId") UUID walletId, Pageable pageable);
    
    @Query("SELECT t FROM Transaction t WHERE (t.senderWallet.id = :walletId OR t.receiverWallet.id = :walletId) AND t.createdAt BETWEEN :from AND :to ORDER BY t.createdAt DESC")
    Page<Transaction> findByWalletIdAndDateRange(
        @Param("walletId") UUID walletId,
        @Param("from") LocalDateTime from,
        @Param("to") LocalDateTime to,
        Pageable pageable
    );
    
    long countBySenderWalletAndStatusAndCreatedAtAfter(Wallet wallet, TransactionStatus status, LocalDateTime after);
}
