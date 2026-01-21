package ml.jufa.backend.b2b.entity;

public enum OrderStatus {
    DRAFT("Brouillon"),
    PENDING("En attente"),
    CONFIRMED("Confirmée"),
    PROCESSING("En préparation"),
    READY("Prête"),
    SHIPPED("Expédiée"),
    DELIVERED("Livrée"),
    CANCELLED("Annulée"),
    REFUNDED("Remboursée");

    private final String displayName;

    OrderStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    public boolean canCancel() {
        return this == DRAFT || this == PENDING || this == CONFIRMED;
    }

    public boolean canModify() {
        return this == DRAFT || this == PENDING;
    }

    public boolean isTerminal() {
        return this == DELIVERED || this == CANCELLED || this == REFUNDED;
    }
}
