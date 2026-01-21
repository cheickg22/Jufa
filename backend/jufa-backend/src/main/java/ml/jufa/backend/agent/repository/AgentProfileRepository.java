package ml.jufa.backend.agent.repository;

import ml.jufa.backend.agent.entity.AgentProfile;
import ml.jufa.backend.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface AgentProfileRepository extends JpaRepository<AgentProfile, UUID> {

    Optional<AgentProfile> findByUser(User user);

    Optional<AgentProfile> findByUserId(UUID userId);

    Optional<AgentProfile> findByAgentCode(String agentCode);

    boolean existsByUser(User user);

    boolean existsByAgentCode(String agentCode);
}
