package ml.jufa.backend.agent.entity;

public enum AgentTransactionType {
    CASH_IN("Dépôt Cash"),
    CASH_OUT("Retrait Cash");

    private final String displayName;

    AgentTransactionType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
