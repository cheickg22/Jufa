package ml.jufa.backend.wallet.repository;

import ml.jufa.backend.user.entity.User;
import ml.jufa.backend.wallet.entity.Wallet;
import ml.jufa.backend.wallet.entity.WalletType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, UUID> {
    
    List<Wallet> findByUser(User user);
    
    List<Wallet> findByUserId(UUID userId);
    
    Optional<Wallet> findByUserAndWalletType(User user, WalletType walletType);
    
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<Wallet> findWithLockById(UUID id);
}
