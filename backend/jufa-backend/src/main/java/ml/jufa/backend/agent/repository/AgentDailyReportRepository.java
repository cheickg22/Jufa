package ml.jufa.backend.agent.repository;

import ml.jufa.backend.agent.entity.AgentDailyReport;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AgentDailyReportRepository extends JpaRepository<AgentDailyReport, UUID> {

    Optional<AgentDailyReport> findByAgentAndReportDate(User agent, LocalDate reportDate);

    Page<AgentDailyReport> findByAgentOrderByReportDateDesc(User agent, Pageable pageable);

    List<AgentDailyReport> findByAgentAndReportDateBetweenOrderByReportDateDesc(User agent, LocalDate startDate, LocalDate endDate);

    @Query("SELECT r FROM AgentDailyReport r WHERE r.agent = :agent ORDER BY r.reportDate DESC LIMIT 30")
    List<AgentDailyReport> findLast30DaysByAgent(User agent);
}
