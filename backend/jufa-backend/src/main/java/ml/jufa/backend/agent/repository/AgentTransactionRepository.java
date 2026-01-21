package ml.jufa.backend.agent.repository;

import ml.jufa.backend.agent.entity.AgentTransaction;
import ml.jufa.backend.agent.entity.AgentTransactionStatus;
import ml.jufa.backend.agent.entity.AgentTransactionType;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AgentTransactionRepository extends JpaRepository<AgentTransaction, UUID> {

    Optional<AgentTransaction> findByReference(String reference);

    Page<AgentTransaction> findByAgentOrderByCreatedAtDesc(User agent, Pageable pageable);

    Page<AgentTransaction> findByAgentAndStatusOrderByCreatedAtDesc(User agent, AgentTransactionStatus status, Pageable pageable);

    Page<AgentTransaction> findByAgentAndTransactionTypeOrderByCreatedAtDesc(User agent, AgentTransactionType type, Pageable pageable);

    Page<AgentTransaction> findByCustomerOrderByCreatedAtDesc(User customer, Pageable pageable);

    @Query("SELECT COUNT(t) FROM AgentTransaction t WHERE t.agent = :agent AND t.status = :status")
    long countByAgentAndStatus(User agent, AgentTransactionStatus status);

    @Query("SELECT SUM(t.amount) FROM AgentTransaction t WHERE t.agent = :agent AND t.status = 'COMPLETED' AND t.transactionType = :type AND t.createdAt >= :startDate")
    BigDecimal sumAmountByAgentAndTypeAndDateAfter(User agent, AgentTransactionType type, LocalDateTime startDate);

    @Query("SELECT COUNT(t) FROM AgentTransaction t WHERE t.agent = :agent AND t.status = 'COMPLETED' AND t.createdAt >= :startDate")
    long countCompletedByAgentAfter(User agent, LocalDateTime startDate);

    @Query("SELECT SUM(t.agentCommission) FROM AgentTransaction t WHERE t.agent = :agent AND t.status = 'COMPLETED' AND t.createdAt >= :startDate")
    BigDecimal sumCommissionByAgentAfter(User agent, LocalDateTime startDate);
}
