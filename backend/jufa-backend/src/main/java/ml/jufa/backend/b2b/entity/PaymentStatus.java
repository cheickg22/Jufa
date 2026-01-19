package ml.jufa.backend.b2b.entity;

public enum PaymentStatus {
    PENDING("En attente"),
    PARTIAL("Partiel"),
    PAID("Payé"),
    CREDIT("À crédit"),
    OVERDUE("En retard");

    private final String displayName;

    PaymentStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
