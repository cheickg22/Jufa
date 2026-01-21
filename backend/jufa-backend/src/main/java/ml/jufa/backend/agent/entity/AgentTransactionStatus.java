package ml.jufa.backend.agent.entity;

public enum AgentTransactionStatus {
    PENDING("En attente"),
    COMPLETED("Terminée"),
    CANCELLED("Annulée"),
    FAILED("Échouée");

    private final String displayName;

    AgentTransactionStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
