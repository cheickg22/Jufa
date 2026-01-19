package ml.jufa.backend.agent.repository;

import ml.jufa.backend.agent.entity.AgentCommission;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface AgentCommissionRepository extends JpaRepository<AgentCommission, UUID> {

    Page<AgentCommission> findByAgentOrderByCommissionDateDesc(User agent, Pageable pageable);

    List<AgentCommission> findByAgentAndStatus(User agent, AgentCommission.CommissionStatus status);

    @Query("SELECT SUM(c.amount) FROM AgentCommission c WHERE c.agent = :agent AND c.status = 'CREDITED'")
    BigDecimal sumPendingCommissionByAgent(User agent);

    @Query("SELECT SUM(c.amount) FROM AgentCommission c WHERE c.agent = :agent AND c.commissionDate BETWEEN :startDate AND :endDate")
    BigDecimal sumCommissionByAgentBetweenDates(User agent, LocalDate startDate, LocalDate endDate);

    @Query("SELECT SUM(c.amount) FROM AgentCommission c WHERE c.agent = :agent")
    BigDecimal sumTotalCommissionByAgent(User agent);
}
